---
title: "04 ThreadLocal"
date: 2023-07-19T16:22:32+08:00
lastmod: 2023-07-19T16:22:32+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- juc
description: ""
weight:
slug: ""
draft: false # 是否为草稿
comments: true # 本页面是否显示评论
reward: true # 打赏
mermaid: true #是否开启mermaid
showToc: true # 显示目录
TocOpen: true # 自动展开目录
hidemeta: false # 是否隐藏文章的元信息，如发布日期、作者等
disableShare: true # 底部不显示分享栏
showbreadcrumbs: true #顶部显示路径
cover:
    image: "" #图片路径例如：posts/tech/123/123.png
    caption: "" #图片底部描述
    alt: ""
    relative: false
---

# 定义

ThreadLocal提供线程局部变量。这些变量与正常的变量不同，因为每一个线程在访问ThreadLocal实例的时候（通过其get或set方法）都有自己的、独立初始化的变量副本。ThreadLocal实例通常是类中的私有静态字段，使用它的目的是希望将状态（例如，用户ID或事务ID）与线程关联起来。

- 每个ThreadLocl都是自己专属的本地变量副本,不存在多线程间共享的问题
- 每个线程对该值都是各自线程互相独立访问的

## 初始化

```java
ThreadLocal<Integer> tl1 = new ThreadLocal<Integer>() {
  @Override
  protected Integer initialValue() {
    return 2;
  }
};
ThreadLocal<Integer> tl2 = ThreadLocal.withInitial(() -> 2);
```

? 为什么要加remove方法

防止内存泄露

# 实践

## 不安全的SimpleDateFormat

### 问题演示

```java
class SimpleDateFormatDemo {

  public static final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

  public static Date parseSdf(String dataStr) throws ParseException {
    return sdf.parse(dataStr);
  }

  public static void main(String[] args) throws ParseException {
    for (int i = 0; i < 5; i++) {
      new Thread(() -> {
        try {
          System.out.println(parseSdf("2023-07-20 11:08:10"));
        } catch (ParseException e) {
          e.printStackTrace();
        }
      }, String.valueOf(i)).start();
    }
  }
}
```

### 原因分析

SimpleDateFormat类内部有一个Calendar对象引用,它用来储存和这个SimpleDateFormat相关的日期信息,例如sdf.parse(dateStr),sdf.format(date) 诸如此类的方法参数传入的日期相关String,Date等等, 都是交由Calendar引用来储存的.这样就会导致一个问题如果你的SimpleDateFormat是个static的, 那么多个thread 之间就会共享这个SimpleDateFormat, 同时也是共享这个Calendar引用。

### 解决措施1 - 局部变量

将将`SimpleDateFormat`定义成局部变量。

缺点:：**每调用一次方法就会创建一个SimpleDateFormat对象，方法结束又要作为垃圾回收。**

### 解决措施2 - ThreadLocal

```java
class SimpleDateFormatDemo {

  public static final ThreadLocal<SimpleDateFormat> tlsdf = ThreadLocal.withInitial(
      () -> new SimpleDateFormat("yyyy-MM-mm HH:mm:ss"));

  public static Date parseSdf(String dataStr) throws ParseException {
    return tlsdf.get().parse(dataStr);
  }

  public static void remove() {
    tlsdf.remove();
  }

  public static void main(String[] args) throws ParseException {
    for (int i = 0; i < 5; i++) {
      new Thread(() -> {
        try {
          System.out.println(parseSdf("2023-07-20 11:08:10"));
        } catch (ParseException e) {
          e.printStackTrace();
        } finally {
          remove();
        }
      }, String.valueOf(i)).start();
    }
  }
}
```

### 解决措施3

- 加锁
- 第三发时间库
- 如果是JDK8应用，用`Instant` 代替Date, `LocalDateTime` 代替`Calendar` `DateTimeFormatter`代替`SimpleDateFormat`

# 源码分析

## Thread 	TheadLocal 	ThreadLocalMap关系

Thread内部有一个ThreadLocal:各自线程都有

TheadLocal内部有`ThreadLocalMap`，ThreadLocalMap 含有entry 键值对,键类型：ThreadLocal

```java
// set方法
public void set(T value) {
    	// 获取当前线程
        Thread t = Thread.currentThread();
    	// 获取ThreadLocalMap
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            map.set(this, value);
        } else {
            createMap(t, value);
        }
    }
    void createMap(Thread t, T firstValue) {
        t.threadLocals = new ThreadLocalMap(this, firstValue);
    }
    ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
        table = new Entry[INITIAL_CAPACITY];
        int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);
        table[i] = new Entry(firstKey, firstValue);
        size = 1;
        setThreshold(INITIAL_CAPACITY);
    }

// get方法
    public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        return setInitialValue();
    }
```

# 内存泄露问题

内存泄露：**不再会被使用的对象或者变量占用的内存不能给回收**

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/A6224E26-D453-4AF3-B553-30AAB8AE253D.png)

## 强引用

**当内存不足，JVM开始垃圾回收，对于强引用的对象，就算是出现了OOM也不会对该对象进行回收，默认支持模式**

强引用是我们最常见的普通对象引用，只要还有强引用指向一个对象，就能表明对象还“活着”，垃圾收集器不会碰这种对象。在 Java 中最常见的就是强引用，把一个对象赋给一个引用变量，这个引用变量就是一个强引用。当一个对象被强引用变量引用时，它处于可达状态，它是不可能被垃圾回收机制回收的，即使该对象以后永远都不会被用到JVM也不会回收。因此强引用是造成Java内存泄漏的主要原因之一。

对于一个普通的对象，如果没有其他的引用关系，只要超过了引用的作用域或者显式地将相应（强）引用赋值为 null，一般认为就是可以被垃圾收集的了(当然具体回收时机还是要看垃圾收集策略)。

## 软引用

软引用相对强引用弱化了一些引用，需要引用**java.lang.ref.SoftReference**类来实现，可以让对象豁免一些垃圾收集。**系统内存充足不会回收，系统内存不足会被回收**

**软引用通常用在对内存敏感的程序中，比如高速缓存就有用到软引用，内存够用的时候就保留，不够用就回收！**

## 弱引用

弱引用需要用**java.lang.ref.WeakReference**类来实现，它比软引用的生存期更短。只要垃圾回收机制一旦运行，不管JVM的内存空间是否充足，都会回收该对象占用的内存

**软引用和弱引用的适用场景**

> 假如有一个应用需要读取大量的本地图片:
>
> - 如果每次读取图片都从硬盘读取则会严重影响性能,
> -  如果一次性全部加载到内存中又可能造成内存溢出。
>
> 此时使用软引用可以解决这个问题。
>
> 设计思路是：用一个HashMap来保存图片的路径和相应图片对象关联的软引用之间的映射关系，在内存不足时，JVM会自动回收这些缓存图片对象所占用的空间，从而有效地避免了OOM的问题。
>
> Map<String. SoftReference<BitMap>> imageCache = new HashMap<String, SoftReference<BitMap>>();

## 虚引用

**虚引用需要`java.lang.ref.PhantomReference`类来实现，需要配合引用队列联合使用**

如果一个对象持有虚引用，那么它就和没有任何引用一样，在任何时候都可能被垃圾回收器回收

虚引用的主要作用是**跟踪对象被垃圾回收的状态**。 仅仅是提供了一种确保对象被 finalize以后，做某些事情的机制。 PhantomReference的get方法总是返回null，因此无法访问对应的引用对象。意义在于，说明一个对象已经进入finalization阶段，可以被gc回收，用来实现比finalization机制更灵活的回收操作。

**换句话说，设置虚引用关联的唯一目的，就是在这个对象被收集器回收的时候收到一个系统通知或者后续添加进一步的处理。**

```java
import java.lang.ref.PhantomReference;
import java.lang.ref.Reference;
import java.lang.ref.ReferenceQueue;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

/**
 * @author Alfred.Ning
 * @since 2023年07月20日 16:07:00
 */
public class WeakReferenceDemo {

  // -Xms9m -Xmx9m
  public static void main(String[] args) {
    ReferenceQueue<Object> referenceQueue = new ReferenceQueue<>();
    PhantomReference<MyObj> objWeakReference = new PhantomReference<>(new MyObj(), referenceQueue);

    ArrayList<byte[]> list = new ArrayList<>();
    new Thread(() -> {
      while (true) {
        byte[] bytes = new byte[1 * 1024 * 1024];
        list.add(bytes);
        try {
          TimeUnit.MICROSECONDS.sleep(5);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
        System.out.println(objWeakReference.get());

      }

    }).start();

    new Thread(() -> {
      while (true) {
        Reference<?> reference = referenceQueue.poll();
        if (reference != null) {
          System.out.println("虚对象死亡，进入队列中");
        }
      }

    }).start();
  }
}

class MyObj {

  @Override
  protected void finalize() throws Throwable {
    System.out.println("my finalized");
  }
}

```

## ThreadLocal如何避免内存泄露

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/A2FF20B8-6573-4C8C-A319-FDEF49C4304C.png)****

### ThreadLocalMap#Entry使用弱引用

调用某一个方法会在栈帧利用存在对象引用，如果是key是强引用就会导致key指向的**ThreadLocal对象及v指向的对象不能被gc回收，造成内存泄漏**；使用弱引用，就可以使ThreadLocal对象在方法执行完毕后顺利被回收且**Entry的key引用指向为null**。

### Entry的key引用指向为null, Value为大对象

ThreadLocalMap使用ThreadLocal的弱引用作为key，如果一个ThreadLocal没有外部强引用他，那么系统gc的时候，这个ThreadLocal势必会被回收，这样一来，**ThreadLocalMap中就会出现key为null的Entry，就没有办法访问这些key为null的Entry的value，如果当前线程再迟迟不结束的话(比如正好用在线程池)，这些key为null的Entry的value就会一直存在一条强引用链。**

虽然弱引用，保**证了key指向的ThreadLocal对象能被及时回收**，**但是v指向的value对象是需要ThreadLocalMap调用get、set时发现key为null时才会去回收整个entry、value**，因此弱引用不能100%保证内存不泄露。我们要在不使用某个ThreadLocal对象后，手动调用remoev方法来删除它，尤其是在线程池中，不仅仅是内存泄露的问题，因为线程池中的线程是重复使用的，意味着这个线程的ThreadLocalMap对象也是重复使用的，如果我们不手动调用remove方法，那么后面的线程就有可能获取到上个线程遗留下来的value值，造成bug。

`set`,`getEntry`,`remove`方法看出，在threadLocal的生命周期里，针对threadLocal存在的内存泄漏的问题，

都会通过`expungeStaleEntry`，`cleanSomeSlots`,`replaceStaleEntry`这三个方法清理掉key为null的脏entry。

**用完在finally中手动清除**

# 总结

- ThreadLocal并不适用线程间共享数据问题
- ThreadLocal适用于线程隔离且方法间共享的问题
- ThreadLocal通过在不同线程内创建独立副本避免了线程安全问题
- 每个线程持有一个只属于自己的专属Map并维护了ThreadLocal对象与具体实例的映射，该Map由于只被持有它的线程访问，故不存在线程安全以及锁的问题
- ThreadLocalMap的Entry对ThreadLocal的引用为弱引用，避免了ThreadLocal对象无法被回收的问题
- 都会通过expungeStaleEntry，cleanSomeSlots,replaceStaleEntry这三个方法**回收键为 null 的 Entry 对象的值（即为具体实例）以及 Entry 对象本身**从而防止内存泄漏，属于安全加固的方法
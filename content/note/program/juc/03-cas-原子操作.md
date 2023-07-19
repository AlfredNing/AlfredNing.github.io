---
title: "03-Cas-原子操作"
date: 2023-07-12T16:20:37+08:00
lastmod: 2023-07-12T16:20:37+08:00
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

# CAS定义

 Compare And Swap：比较并交换
V: 位置内存值
A: 旧的预期值
B: 要修改更新的值

当且仅当V中的值和A值相等，用B值更新V中的值

## 硬件级别保证

CAS底层是一条CPU的原子指令 `cmpxchg`指令，不会造成数据不一致的问题，Java底层提供由`Unsafe`类提供的CAS方法

执行cmpxchg指令的时候，会判断当前系统是否为**多核系统**，如果是就给总线加锁，**只有一个线程会对总线加锁成功，加锁成功之后会执行cas操作**，也就是说**CAS的原子性实际上是CPU实现的**， 其实在这一点上还**是有排他锁的**，只是比起用synchronized， 这里的排他时间要短的多， 所以在多线程情况下性能会比较好

# Unsafe类

是CAS的核心类，Unsafe位于`sun.misc`包中，通过CAS类可以直接通过操作特定内存的数据**，所有的方法都是用native修饰， 也就是说Unsafe类底层都直接调用操作系统底层资源执行相应任务**

![image-20230718112357762](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230718112357762.png)

变量`offSet`代表变量值在内存的地址

变量value用volatile修饰，保证了多线程之间的内存可见性。

## AtomicInteger类

`AtomicInteger`主要是通过**CAS + volatile + native**方法类保证原子操作，从而避免 synchronized 的高开销，执行效率大为提升。

CAS并发原语体现在JAVA语言中就是sun.misc.Unsafe类中的各个方法。调用UnSafe类中的CAS方法，JVM会帮我们实现出**CAS汇编指令**。这是一种完全依赖于**硬件**的功能，通过它实现了原子操作。再次强调，由于CAS是一种系统原语，原语属于操作系统用语范畴，是由若干条指令组成的，用于完成某个功能的一个过程，**并且原语的执行必须是连续的，在执行过程中不允许被中断，也就是说CAS是一条CPU的原子指令，不会造成所谓的数据不一致问题。**

> CAS是靠硬件实现的从而在硬件层面提升效率，最底层还是交给硬件来保证原子性和可见性
>
> 实现方式是基于硬件平台的汇编指令，在intel的CPU中(X86机器上)，使用的是汇编指令cmpxchg指令。 
>
> 核心思想就是：比较要更新变量的值V和预期值E（compare），相等才会将V的值设为新值N（swap）如果不相等自旋再来。

# 原子引用

AtomicInteger原子整型，可以自定义自己的原理引用类型

## 自定义原子引用

```java
import java.util.concurrent.atomic.AtomicReference;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 自定义原子类型引用
 *
 * @author Alfred.Ning
 * @since 2023年07月18日 11:41:00
 */
public class AtomicReferenceDemo {

  public static void main(String[] args) {
    User u1 = new User("u1", 20);
    User u2 = new User("u2", 30);
    AtomicReference<User> userAtomicReference = new AtomicReference<>();
    userAtomicReference.set(u1);
    System.out.println(
        userAtomicReference.compareAndSet(u1, u2) + "\t" + userAtomicReference.get().toString());
    System.out.println(
        userAtomicReference.compareAndSet(u1, u2) + "\t" + userAtomicReference.get().toString());
  }
}

@Data
@AllArgsConstructor
@NoArgsConstructor
class User {

  private String username;
  private int age;
}

```

## 自旋锁

线程指尝试获取锁的时候不会立即阻塞，**采用循环的方式**去获取锁。
当线程被发现出于占用时候，会不断循环判断锁的状态，直到获取。

**这样的好处是减少线程上下文切换的消耗，缺点是循环会消耗CPU**

### 自定义自旋锁

```java
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

/**
 * 自旋锁实现
 *
 * @author Alfred.Ning
 * @since 2023年07月18日 11:46:00
 */
public class SpinLockDemo {

  AtomicReference<Thread> atomicReference = new AtomicReference<>();

  public void myLock() {
    System.out.println(Thread.currentThread().getName() + "线程进入...");
    while (!atomicReference.compareAndSet(null, Thread.currentThread())) {

    }
    System.out.println(Thread.currentThread().getName() + "持有锁..");
  }

  public void myUnlock() {
    atomicReference.compareAndSet(Thread.currentThread(), null);
    System.out.println(Thread.currentThread().getName() + "释放锁..");
  }

  public static void main(String[] args) {
    SpinLockDemo spinLockDemo = new SpinLockDemo();
    new Thread(() -> {
      spinLockDemo.myLock();
      try {
        TimeUnit.SECONDS.sleep(5);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      spinLockDemo.myUnlock();
    }, "t1").start();

//暂停一会儿线程，保证A线程先于B线程启动并完成
    try {
      TimeUnit.SECONDS.sleep(1);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }

    new Thread(() -> {
      spinLockDemo.myLock();
      spinLockDemo.myUnlock();
    }, "t2").start();
  }
}
```

# ABA问题

**自旋锁时间开销大**

## 产生原因

CAS算法实现一个重要前提需要取出内存中某时刻的数据并在当下时刻比较并替换，那么在这个时间差类会导致数据的变化。

比如说一个线程one从内存位置V中取出A，这时候另一个线程two也从内存中取出A，并且线程two进行了一些操作将值变成了B，

然后线程two又将V位置的数据变成A，这时候线程one进行CAS操作发现内存中仍然是A，然后线程one操作成功。

**尽管线程one的CAS操作成功，但是不代表这个过程就是没有问题的。**

## 解决ABA

版本号时间戳原子引用: `AtomicStampedReference`类

```java
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicStampedReference;

/**
 * ABA演示及其解决
 *
 * @author Alfred.Ning
 * @since 2023年07月18日 12:10:00
 */
public class ABADemo {

  static AtomicInteger atomicInteger = new AtomicInteger(100);
  static AtomicStampedReference<Integer> atomicStampedReference = new AtomicStampedReference<Integer>(
      100,
      1);

  public static void main(String[] args) {
    // ABA问题演示
//    abaProblem();

    // ABA解决 版本号机制
    new Thread(() -> {
      int stamp = atomicStampedReference.getStamp();
      System.out.println(Thread.currentThread().getName() + "---默认版本号: " + stamp);
      try {
        TimeUnit.SECONDS.sleep(1);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      atomicStampedReference.compareAndSet(100, 101, stamp, stamp + 1);
      System.out.println(Thread.currentThread().getName() + "---提交一次版本号: " + atomicStampedReference.getStamp());
      atomicStampedReference.compareAndSet(101, 100, atomicStampedReference.getStamp(),
          atomicStampedReference.getStamp() + 1);
      System.out.println(Thread.currentThread().getName() + "---提交二次版本号: " + atomicStampedReference.getStamp());
    }, "t1").start();

    new Thread(() -> {
      int stamp = atomicStampedReference.getStamp();
      System.out.println(Thread.currentThread().getName() + "---默认版本号: " + stamp);
      try {
        TimeUnit.SECONDS.sleep(5);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }

      boolean res = atomicStampedReference.compareAndSet(100, 666, stamp, stamp + 1);

      System.out.println(Thread.currentThread().getName() + "修改成功: " + res + "\t" + atomicStampedReference.getStamp());
    }, "t2").start();
  }

  private static void abaProblem() {
    new Thread(() -> {
      atomicInteger.compareAndSet(100, 101);
      atomicInteger.compareAndSet(101, 100);
    }, "t1").start();

    try {
      TimeUnit.MICROSECONDS.sleep(10);
    } catch (InterruptedException e) {

      e.printStackTrace();
    }

    new Thread(() -> {
      boolean res = atomicInteger.compareAndSet(100, 666);
      System.out.println("修改成功: " + res);
    }, "t2").start();
  }

}
```

# 原子操作类

## 基本类型原子类

- AtomicInteger
- AtomicBoolean
- AtomicLong

**常用API**

- public final int get() //获取当前的值
- public final int getAndSet(int newValue)//获取当前的值，并设置新的值
- public final int getAndIncrement()//获取当前的值，并自增
- public final int getAndDecrement() //获取当前的值，并自减
- public final int getAndAdd(int delta) //获取当前的值，并加上预期的值
- boolean compareAndSet(int expect, int update) //如果输入的数值等于预期值，则以原子方式将该值设置为输入值（update）

```java
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;
import lombok.Data;

/**
 * AtomicInteger + CountDownLatch
 * @author Alfred.Ning
 * @since 2023年07月18日 15:30:00
 */
@Data
class NumberAdd {

  private AtomicInteger atomicInteger = new AtomicInteger();

  public void addPlus() {
    atomicInteger.incrementAndGet();
  }
}

public class AtomicIntegerDemo {

  public static void main(String[] args) throws InterruptedException {
    int size = 50;
    NumberAdd numberAdd = new NumberAdd();
    CountDownLatch cdl = new CountDownLatch(size);

    for (int i = 0; i < size; i++) {
      new Thread(() -> {
        try {
          for (int j = 0; j < 1000; j++) {
            numberAdd.addPlus();
          }
        } catch (Exception e) {
          e.printStackTrace();
        } finally {
          cdl.countDown();
        }
      }).start();
    }

    // 生产不用使用 -》 CountDownLatch
//    try {
//      TimeUnit.SECONDS.sleep(2);
//    } catch (InterruptedException e) {
//      e.printStackTrace();
//    }
    cdl.await();
    System.out.println(numberAdd.getAtomicInteger().get());
  }
}
```

## 数组类型原子类

- AtomicIntegerArray
- AtomicLongArray
- AtomicReferenceArray

## 引用类型原子类

- AtomicReference
- AtomicStampedReference
- AtomicMarkableReference

### AtomicStampedReference 与 AtomicMarkableReference 区别

`AtomicStampedReference` 携带版本号的引用原子类型，可以解决ABA问题，**重点在于修改几次**

`AtomicMarkableReference` 带有标记为的引用原子类型，将状态戳转为bool值，**重在在于是否修改过**

```java
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicMarkableReference;

/**
 * @author Alfred.Ning
 * @since 2023年07月18日 16:33:00
 */
public class AtomicMarkableReferenceDemo {

  static AtomicMarkableReference<Integer> markableReference = new AtomicMarkableReference<Integer>(100, false);

  public static void main(String[] args) {
    new Thread(() -> {
      boolean marked = markableReference.isMarked();
      System.out.println(Thread.currentThread().getName() + "---默认修改表示符号: " + marked);
      try {
        TimeUnit.SECONDS.sleep(1);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      markableReference.compareAndSet(100, 101, marked, !marked);
    }, "t1").start();

    new Thread(() -> {
      boolean marked = markableReference.isMarked();
      System.out.println(Thread.currentThread().getName() + "---默认修改表示符号: " + marked);
      try {
        TimeUnit.SECONDS.sleep(2);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      boolean b = markableReference.compareAndSet(100, 666, marked, !marked);
      System.out.println(Thread.currentThread().getName() + "---修改成功: " + b);
      System.out.println(Thread.currentThread().getName() + "\t" + markableReference.getReference());
      System.out.println(Thread.currentThread().getName() + "\t" + markableReference.isMarked());

    }, "t2").start();
  }
}
```

## 对象的属性修改原子类

- `AtomicIntegerFieldUpdater` ： 原子更新对象中int类型字段的值
- `AtomicLongFieldUpdater`： 原子更新对象中Long类型字段的值
- `AtomicReferenceFieldUpdater` ： 原子更新引用类型字段的值

### 产生

以一种线程安全的方式去操作非线程安全对象的**某些字段/属性**，锁更加轻量级

### 使用要求

1. 更新的对象属性必须使用 public volatile 修饰符。
2. 因为对象的属性修改类型原子类都是抽象类，所以每次使用都必须使用静态方法newUpdater()创建一个更新器，并且需要设置想要更新的类和属性。

```java
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

/**
 * @author Alfred.Ning
 * @since 2023年07月18日 16:59:00
 */
public class AtomicIntegerFieldUpdaterDemo {

  public static void main(String[] args) {
    BankAccount bankAccount = new BankAccount();
    for (int i = 0; i < 1000; i++) {
      new Thread(() -> {
        bankAccount.transfer(bankAccount);
      }, String.valueOf(i)).start();
    }

    try {
      TimeUnit.SECONDS.sleep(1);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    System.out.println("account: " + bankAccount.money);
  }

}

class BankAccount {

  String bankName = "ccb";
  public volatile int money = 0;
  // 操作经常发生变化 易于更新的
  AtomicIntegerFieldUpdater<BankAccount> fieldUpdater = AtomicIntegerFieldUpdater.newUpdater(BankAccount.class,
      "money");

  public void transfer(BankAccount bankAccount) {
    fieldUpdater.incrementAndGet(bankAccount);
  }

}
```

```java
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/**
 * 初始化一次
 * @author Alfred.Ning
 * @since 2023年07月18日 17:04:00
 */

class Myvar {

  public volatile Boolean isInit = Boolean.FALSE;
  AtomicReferenceFieldUpdater<Myvar, Boolean> fieldUpdater = AtomicReferenceFieldUpdater.newUpdater(Myvar.class,
      Boolean.class, "isInit");

  public void init(Myvar myvar) {
    if (fieldUpdater.compareAndSet(myvar, Boolean.FALSE, Boolean.TRUE)) {
      System.out.println(Thread.currentThread().getName() + "\t" + "------start init");
      try {
        TimeUnit.SECONDS.sleep(1);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      System.out.println(Thread.currentThread().getName() + "\t" + "------end init");
    } else {
      System.out.println(Thread.currentThread().getName() + "\t" + "------抢锁失败  ");
    }
  }
}

public class AtomicReferenceFieldUpdaterDemo {

  public static void main(String[] args) {
    Myvar myvar = new Myvar();
    for (int i = 0; i < 5; i++) {
      new Thread(() -> {
        myvar.init(myvar);
      }, String.valueOf(i)).start();
    }
  }

}
```

## 原子操作增强类

- DoubleAccumulator
- DoubleAdder
- LongAccumulator
- LongAdder

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/A44B1ACF-0D04-4D5A-A710-728095FF5B66.png)

- LongAdder只能用来计算加法，且从零开始计算
- LongAccumulator提供了自定义的函数操作

> 对于大数据统计，使用LongAdder

```java
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.LongAccumulator;
import java.util.concurrent.atomic.LongAdder;

/**
 * @author Alfred.Ning
 * @since 2023年07月18日 17:34:00
 */

class ClickNumberNet {

  int number = 0;

  public synchronized void clickBySync() {
    number++;
  }

  AtomicLong atomicLong = new AtomicLong(0);

  public void clickByAtomicLong() {
    atomicLong.incrementAndGet();
  }

  LongAdder longAdder = new LongAdder();

  public void clickByLongAdder() {
    longAdder.increment();
  }

  LongAccumulator longAccumulator = new LongAccumulator((x, y) -> x + y, 0);

  public void clickByLongAccumulator() {
    longAccumulator.accumulate(1);
  }
}

public class LongAdderDemo2 {

  public static void main(String[] args) throws InterruptedException {
    ClickNumberNet clickNumberNet = new ClickNumberNet();

    long startTime;
    long endTime;
    CountDownLatch countDownLatch = new CountDownLatch(50);
    CountDownLatch countDownLatch2 = new CountDownLatch(50);
    CountDownLatch countDownLatch3 = new CountDownLatch(50);
    CountDownLatch countDownLatch4 = new CountDownLatch(50);

    startTime = System.currentTimeMillis();
    for (int i = 1; i <= 50; i++) {
      new Thread(() -> {
        try {
          for (int j = 1; j <= 100 * 10000; j++) {
            clickNumberNet.clickBySync();
          }
        } finally {
          countDownLatch.countDown();
        }
      }, String.valueOf(i)).start();
    }
    countDownLatch.await();
    endTime = System.currentTimeMillis();
    System.out.println(
        "----costTime: " + (endTime - startTime) + " 毫秒" + "\t clickBySync result: " + clickNumberNet.number);

    startTime = System.currentTimeMillis();
    for (int i = 1; i <= 50; i++) {
      new Thread(() -> {
        try {
          for (int j = 1; j <= 100 * 10000; j++) {
            clickNumberNet.clickByAtomicLong();
          }
        } finally {
          countDownLatch2.countDown();
        }
      }, String.valueOf(i)).start();
    }
    countDownLatch2.await();
    endTime = System.currentTimeMillis();
    System.out.println(
        "----costTime: " + (endTime - startTime) + " 毫秒" + "\t clickByAtomicLong result: " + clickNumberNet.atomicLong);

    startTime = System.currentTimeMillis();
    for (int i = 1; i <= 50; i++) {
      new Thread(() -> {
        try {
          for (int j = 1; j <= 100 * 10000; j++) {
            clickNumberNet.clickByLongAdder();
          }
        } finally {
          countDownLatch3.countDown();
        }
      }, String.valueOf(i)).start();
    }
    countDownLatch3.await();
    endTime = System.currentTimeMillis();
    System.out.println("----costTime: " + (endTime - startTime) + " 毫秒" + "\t clickByLongAdder result: "
        + clickNumberNet.longAdder.sum());

    startTime = System.currentTimeMillis();
    for (int i = 1; i <= 50; i++) {
      new Thread(() -> {
        try {
          for (int j = 1; j <= 100 * 10000; j++) {
            clickNumberNet.clickByLongAccumulator();
          }
        } finally {
          countDownLatch4.countDown();
        }
      }, String.valueOf(i)).start();
    }
    countDownLatch4.await();
    endTime = System.currentTimeMillis();
    System.out.println("----costTime: " + (endTime - startTime) + " 毫秒" + "\t clickByLongAccumulator result: "
        + clickNumberNet.longAccumulator.longValue());

  }
}
```



![image-20230718173650061](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230718173650061.png)

## LongAdder快的原因

`abstract class Striped64 extends Number`

LongAdder的基本思路就是**分散热点**，将value值分散到一个**Cell数组**中，不同线程会命中到数组的不同槽中，各个线程只对自己槽中的那个值进行CAS操作，这样热点就被分散了，冲突的概率就小很多。如果要获取真正的long值，只要将各个槽中的变量值累加返回。

sum()会将所有Cell数组中的value和base累加作为返回值，核心的思想就是将之前AtomicLong一个value的更新压力分散到多个value中去，

**从而降级更新热点。**

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/AF25B743-CB20-40D9-9DD9-ABC76B2F1D3B.png)

内部有一个base变量，一个Cell[]数组。

- base变量：非竞态条件下，直接累加到该变量上
- Cell[]数组：竞态条件下，累加个各个线程自己的槽Cell[i]中

LongAdder在无竞争的情况，跟AtomicLong一样，对同一个base进行操作，当出现竞争关系时则是采用化整为零的做法，从空间换时间，用一个数组cells，将一个value拆分进这个数组cells。多个线程需要同时对value进行操作时候，可以对线程id进行hash得到hash值，再根据hash值映射到这个数组cells的某个下标，再对该下标所对应的值进行自增操作。当所有线程操作完毕，将数组cells的所有值和无竞争值base都加起来作为最终结果。

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/0203AB5C-B6F1-4EBE-B970-A67B9BC3325D.png)



![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/E1151568-974E-4F52-B624-2FC8EC7E671F.png)

## AtomicLong 与 LongAdder

### AtomicLong

#### 原理

CAS+自旋

#### 场景

- 低并发下的全局计算
- AtomicLong能保证并发情况下计数的准确性，其内部通过CAS来解决并发安全性的问题。

#### 缺陷

高并发后性能急剧下降，自旋带来的

### LongAdder

#### 原理

- CAS+Base+Cell数组分散
- 空间换时间并分散了热点数据

#### 场景

高并发下的全局计算，适合粗略计算

#### 缺陷

sum求和之后如果还有线程修改结果，最后结果不太准确

# LongAdder源码分析

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/A53885E2-69C4-4244-8E9D-8BB9F6363657.png)



```java
LongAdder#increment -> #add
   /*
   cs是Striped64 的cells数组属性
   b是Striped64 的base属性
   v是当前线程hash到cell存储的值
   m是cell长度减1，hash作为掩码使用
   a是当前线程hash到的cell
   */
    public void add(long x) {
        Cell[] cs; long b, v; int m; Cell c;
    	// 首次线程进来，(cs = cells) != null 一定为false, 走#casBase方法，以cas凡是更新bash值，只有更新失败，走到if中
    	// (cs = cells) != null  为true: 说明出现过线程竞争，Cell数组已经被创建
    	// 更新失败，说明有线程抢先异步修改了base 正在出现竞争
        if ((cs = cells) != null || !casBase(b = base, b + x)) {
            // 该方法返回线程的ThreadLocalRandom字段
            // 通过随机数生成的一个值，对于一个确定的线程这个值是固定的
            int index = getProbe();
            // true为无竞争 false表示竞争激烈，多个hash到同一个cell, 可能要扩容
            boolean uncontended = true;
            // cell为空，说明正在出现竞争，依据上面条件2
            // (m = cs.length - 1) < 0 应该不会出现
            //  (c = cs[index & m]) == null 当前线程所在的cell为空，说明线程还没有初始化过cell，应初始一个cell
            // 更新当前所在线程Cell失败，说明竞争激烈，多个线程Hash到同一个cell,应扩容
            if (cs == null || (m = cs.length - 1) < 0 ||
                (c = cs[index & m]) == null ||
                !(uncontended = c.cas(v = c.value, v + x)))
                longAccumulate(x, null, uncontended, index);
        }
    }
# longAccumulate
    final void longAccumulate(long x, LongBinaryOperator fn,
                              boolean wasUncontended, int index) {
        if (index == 0) {
            ThreadLocalRandom.current(); // force initialization
            index = getProbe();
            wasUncontended = true;
        }
        for (boolean collide = false;;) {       // True if last slot nonempty
            Cell[] cs; Cell c; int n; long v;
            // cell已经被初始化
            if ((cs = cells) != null && (n = cs.length) > 0) {
                // 线程hash值运算之后得到的cell单元为为null，说明cell没有被使用
                if ((c = cs[(n - 1) & index]) == null) {
                     // cell数组正在扩容
                    if (cellsBusy == 0) {       
                        Cell r = new Cell(x);   //创建单元格
                        if (cellsBusy == 0 && casCellsBusy()) { //尝试加锁，成功后cellsBusy = 1
                            try {              
                                Cell[] rs; int m, j;
                                // double check
                                if ((rs = cells) != null &&
                                    (m = rs.length) > 0 &&
                                    rs[j = (m - 1) & index] == null) {
                                    rs[j] = r; // 添加到cell中
                                    break;
                                }
                            } finally {
                                cellsBusy = 0;
                            }
                            continue;           // Slot is now non-empty
                        }
                    }
                    collide = false;
                }
                else if (!wasUncontended)       // CAS already known to fail wasUncontended表示前一次更新cell单元格是否成功
                    wasUncontended = true;      // Continue after rehash 重置为true，后面重新计算线程的hash值
                else if (c.cas(v = c.value,
                               (fn == null) ? v + x : fn.applyAsLong(v, x)))
                    break;
                else if (n >= NCPU || cells != cs) // cells数组大小超过CPU核数，永远不会扩容
                    collide = false;            // At max size or stale
                else if (!collide)
                    collide = true;
                else if (cellsBusy == 0 && casCellsBusy()) { // 尝试加锁扩容
                    try {
                        if (cells == cs)        // 扩容后的大小 = 当前容量 * 2
                            cells = Arrays.copyOf(cs, n << 1);
                    } finally {
                        cellsBusy = 0;
                    }
                    collide = false;
                    continue;                   // Retry with expanded table
                }
                index = advanceProbe(index);
            }
            // cell在没有加锁且没有初始化，尝试加锁，且初始化
            else if (cellsBusy == 0 && cells == cs && casCellsBusy()) {
                try {                           // Initialize table
                    if (cells == cs) {
                        Cell[] rs = new Cell[2];
                        rs[index & 1] = new Cell(x);
                        cells = rs;
                        break;
                    }
                } finally {
                    cellsBusy = 0;
                }
            }
		// cell正在初始化，直接在基数base上面进行累加操作
            else if (casBase(v = base,
                             (fn == null) ? v + x : fn.applyAsLong(v, x)))
                break;
        }
    }    

```

## ? 并发下为什么sum值不精确

sum()会将所有Cell数组中的value和base累加作为返回值。**最终一致性**

**核心的思想就是将之前AtomicLong一个value的更新压力分散到多个value中去，从而降级更新热点。**


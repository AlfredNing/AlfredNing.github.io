---
title: "06 Synchronized与锁升级"
date: 2023-07-22T10:21:34+08:00
lastmod: 2023-07-22T10:21:34+08:00
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

# Syncronized的性能变化

**锁升级**

**无锁 -> 偏向锁 -> 轻量级锁 -> 重量级锁**

## **java5之前，只有Syncronized，操作系统级别的重量锁，性能低下。内核态与用户态的切换**

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/E58E9AFB-3A14-4E48-91F7-4C07500EDA64.png)

>  java的线程是映射到操作系统原生线程之上的，如果要阻塞或唤醒一个线程就需要操作系统介入，需要在户态与核心态之间切换，这种切换会消耗大量的系统资源，因为用户态与内核态都有各自专用的内存空间，专用的寄存器等，用户态切换至内核态需要传递给许多变量、参数给内核，内核也需要保护好用户态在切换时的一些寄存器值、变量等，以便内核态调用结束后切换回用户态继续工作。

Java早期版本，Synchronized依赖于**操作系统底层的Mutex Lock来实现**，挂起线程和恢复线程都需要转入内核态运行，阻塞或唤醒一个Java线程需要操作系统切换CPU状态来完成，这种状态切换需要耗费处理器时间，如果同步代码块中内容过于简单，这种切换的时间可能比用户代码执行的时间还长”，时间成本相对较高。

**Java 6之后，为了减少获得锁和释放锁所带来的性能消耗，引入了轻量级锁和偏向锁**

## ? 为什么为什么每一个对象都可以成为一个锁

![](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/3B945DB0-5CEF-438E-9908-C6A8D1EF9AB6.png)

Monitor可以理解为一种同步工具，也可理解为一种同步机制，常常被描述为一个Java对象。Java对象是天生的Monitor，每一个Java对象都有成为Monitor的潜质，因为在Java的设计中 ，**每一个Java对象自打娘胎里出来就带了一把看不见的锁，它叫做内部锁或者Monitor锁。**

> Monitor的本质是依赖于底层操作系统的Mutex Lock实现，操作系统实现线程之间的切换需要从用户态到内核态的转换，成本非常高。
>
> Mutex Lock 
>
> Monitor是在jvm底层实现的，底层代码是c++。本质是依赖于底层操作系统的Mutex Lock实现，操作系统实现线程之间的切换需要从用户态到内核态的转换，状态转换需要耗费很多的处理器时间成本非常高。所以synchronized是Java语言中的一个重量级操作。
>
> 
>
> Monitor与java对象以及线程是如何关联 ？
>
> 1.如果一个java对象被某个线程锁住，则该java对象的Mark Word字段中LockWord指向monitor的起始地址
>
> 2.Monitor的Owner字段会存放拥有相关联对象锁的线程id
>
> Mutex Lock 的切换需要从用户态转换到核心态中，因此状态转换需要耗费很多的处理器时间。

## java6开始，优化Synchronized

Java 6之后，为了减少获得锁和释放锁所带来的性能消耗，引入了轻量级锁和偏向锁, **逐步升级锁**的过程



![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/231819D9-875E-4EFD-9C61-2E4B75548171.png)

# 无锁演示

程序不会有锁的竞争

![image-20230722180505219](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230722180505219.png)

# 偏向锁

### 定义

大多数情况下，锁不仅不存在多线程竞争，还存在**由同一线程多次获得的情况**。

偏向锁就是在这种情况下出现的，**它的出现是为了解决只有在一个线程执行同步时提高性能。**

### 偏向锁的持有

锁总是被第一个占用它的线程拥有，该线程就是锁的偏向线程

1. 锁第一次拥有，记录偏向线程ID。这样偏向线程就一直持有着锁(后续这个线程进入和退出这段加了同步锁的代码块时，**不需要再次加锁和释放锁**。而是直接比较对象头里面是否存储了指向当前线程的偏向锁)
2. **相等时**：表示偏向锁偏向于当前线程。就不需要再尝试获得锁了，直到竞争发生才释放锁。以后每次同步，检查锁的偏向线程ID与当前线程ID是否一致，如果一致直接进入同步。无需每次加锁解锁都去CAS更新对象头。如果自始至终使用锁的线程只有一个，**很明显偏向锁几乎没有额外开销，性能极高。**
3. **不一致**：发生竞争。锁已经不是总是偏向于同一个线程了，这时候可能需要升级变为轻量级锁，才能保证线程间公平竞争锁。**偏向锁只有遇到其他线程尝试竞争偏向锁时，持有偏向锁的线程才会释放锁，线程是不会主动释放偏向锁的。**

**技术实现**

一个synchronized方法被一个线程抢到了锁时，那这个方法所在的对象就会在其所在的Mark Word中将偏向锁修改状态位，同时还会有占用前54位来存储线程指针作为标识。若该线程再次访问同一个synchronized方法时，该线程只需去对象头的Mark Word 中去判断一下是否有偏向锁指向本身的ID，无需再进入 Monitor 去竞争对象了。

### 演示

```java
import org.openjdk.jol.info.ClassLayout;

/**
 * @author Alfred.Ning
 * @since 2023年07月22日 18:49:00
 */
public class BiasedLockDemo {

  private static Object objectLock = new Object();

  public static void main(String[] args) {

    /**
     *
     -XX:+UseBiasedLocking                       开启偏向锁(默认)
     -XX:-UseBiasedLocking                       关闭偏向锁
     -XX:BiasedLockingStartupDelay=0             关闭延迟(演示偏向锁时需要开启)


     参数说明：
     偏向锁在JDK1.6以上默认开启，开启后程序启动几秒后才会被激活，可以使用JVM参数来关闭延迟 -XX:BiasedLockingStartupDelay=0
     如果确定锁通常处于竞争状态则可通过JVM参数 -XX:-UseBiasedLocking 关闭偏向锁，那么默认会进入轻量级锁

     */
    new Thread(() -> {
      synchronized (objectLock) {
        System.out.println(ClassLayout.parseInstance(objectLock).toPrintable());
      }
    }).start();
  }

}

```

### 偏向锁的撤销

1. 当有另外线程来竞争锁的时候，就不能在使用偏向锁了，要升级为轻量级锁
2. 竞争线程尝试CAS更新对象头失败，会等待到全局安全点（此时不会执行任何代码）撤销偏向锁。

偏向锁使用一种**等到竞争出现才释放锁的机制**，只有当其他线程竞争锁时，持有偏向锁的原来线程才会被撤销。

撤销需要等待全局安全点(该时间点上没有字节码正在执行)，同时检查持有偏向锁的线程是否还在执行：

1. 第一个线程正在执行synchronized方法(处于同步块)，它还没有执行完，其它线程来抢夺，**该偏向锁会被取消掉并出现锁升级**。此时轻量级锁由原持有偏向锁的线程持有，继续执行其同步代码，而正在竞争的线程会进入自旋等待获得该轻量级锁。
2.  第一个线程执行完成synchronized方法(退出同步块)，则将对象头设置成无锁状态并撤销偏向锁，重新偏向 。

# 轻量级锁

轻量级锁：是为了在线程近乎交替执行同步块时提高性能

主要目的：在没有多线程竞争的前提下，通过CAS减少重量锁使用操作系统互斥量来产生的性能消耗。**先自旋在阻塞**

升级时机：当关闭偏向锁功能或多线程竞争偏向锁会导致偏向锁升级为轻量级锁

> 假如线程A已经拿到锁，这时线程B又来抢该对象的锁，由于该对象的锁已经被线程A拿到，当前该锁已是**偏向锁**了。
>
> 而线程B在争抢时发现对象头Mark Word中的线程ID不是线程B自己的线程ID(而是线程A)，那线程B就会进行CAS操作希望能获得锁。
>
> 此时线程B操作中有两种情况：
>
> - 如果锁获取成功，直接替换Mark Word中的线程ID为B自己的ID(A → B)，重新偏向于其他线程(即将偏向锁交给其他线程，相当于当前线程"被"释放了锁)，该锁会保持偏向锁状态，A线程Over，B线程上位；
> - 如果锁获取失败，则偏向锁升级为轻量级锁，此时轻量级锁由原持有偏向锁的线程持有，继续执行其同步代码，而正在竞争的线程B会进入自旋等待获得该轻量级锁。

可以直接关闭偏向锁，进入轻量锁：`-XX:-UseBiasedLocking`

轻量级锁自旋达到一定程度会升级

**java6之前**

1. 默认启用，默认情况下自旋的次数是 10 次。`-XX:PreBlockSpin=10`来修改
2. 自旋线程数超过cpu核数一半

**java6之后**

**自适应策略：** 同一个锁上一次自旋的时间和拥有锁线程的状态来决定

## 轻量锁与偏向锁的区别和不同

- 争夺轻量级锁失败时，自旋尝试抢占锁
- 轻量级锁每次退出同步块都需要释放锁，而偏向锁是在竞争发生时才释放锁

# 重量级锁

有大量的线程参与锁的竞争，冲突性很高

*基于当前版本1.8*

## 锁的对比总结

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/CB0BA457-D474-46D3-B96C-D70013C43859.png)

synchronized锁升级过程总结：**一句话，就是先自旋，不行再阻塞。**

实际上是把之前的悲观锁(重量级锁)变成在一定条件下使用偏向锁以及使用轻量级(自旋锁CAS)的形式

**synchronized在修饰方法和代码块在字节码上实现方式有很大差异，但是内部实现还是基于对象头的MarkWord来实现的。**

JDK1.6之前synchronized使用的是重量级锁，JDK1.6之后进行了优化，拥有了无锁->偏向锁->轻量级锁->重量级锁的升级过程，而不是无论什么情况都使用重量级锁。

**偏向锁**:适用于单线程适用的情况，在不存在锁竞争的时候进入同步方法/代码块则使用偏向锁。

**轻量级锁**：适用于竞争较不激烈的情况(这和乐观锁的使用范围类似)， 存在竞争时升级为轻量级锁，轻量级锁采用的是自旋锁，如果同步方法/代码块执行时间很短的话，采用轻量级锁虽然会占用cpu资源但是相对比使用重量级锁还是更高效。

**重量级锁**：适用于竞争激烈的情况，如果同步方法/代码块执行时间很长，那么使用轻量级锁自旋带来的性能消耗就比使用重量级锁更严重，这时候就需要升级为重量级锁。

# 锁消除

锁消除,JIT会无视它，synchronized(对象锁)不存在了。不正常的

```java
/**
 * @author Alfred.Ning
 * @since 2023年07月22日 19:29:00
 */
public class LockClearUPDemo {

  static Object objectLock = new Object();

  public void m1() {
    Object o = new Object();

    synchronized (o) {
      System.out.println("-----hello LockClearUPDemo" + "\t" + o.hashCode() + "\t" + objectLock.hashCode());
    }
  }

  public static void main(String[] args) {
  }
}
```

# 锁粗化

假如方法中首尾相接，前后相邻的都是同一个锁对象，那JIT编译器就会把这几个synchronized块合并成一个大块，加粗加大范围，一次申请锁使用即可，避免次次的申请和释放锁，提升了性能

```java
/**
 * @author Alfred.Ning
 * @since 2023年07月22日 19:37:00
 */
public class LockWideDemo {

  static final Object obj = new Object();

  public static void main(String[] args) {
    new Thread(() -> {
      synchronized (obj) {
        System.out.println("t1");
      }
      synchronized (obj) {
        System.out.println("t2");
      }
      synchronized (obj) {
        System.out.println("t3");
      }

      // JIT编译生成
      synchronized (obj) {
        System.out.println("t1");
        System.out.println("t2");
        System.out.println("t3");
      }
    }).start();
  }

}

```


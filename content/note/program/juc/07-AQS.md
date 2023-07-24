---
title: "07 AQS"
date: 2023-07-22T20:31:52+08:00
lastmod: 2023-07-22T20:31:52+08:00
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

`AbstractQueuedSynchronizer`: 抽象队列同步器

是用来构建锁或者其它同步器组件的重量级基础框架及整个JUC体系的基石，通过内置的FIFO队列来完成资源获取线程的排队工作，并通过一个int类变量表示持有锁的状态

和AQS相关的

- ReentrantLock
- CountDownLatch
- ReentrantReadWriteLock
- Semaphore

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/666D8FE9-4122-4AC6-939A-36936EBB4AD4.png)

锁: 面向锁的使用者,定义了程序员和锁交互的使用层API

同步器: 面向锁的实现者

抢到资源的线程直接使用处理业务，抢不到资源的必然涉及一种**排队等候机制**。抢占资源失败的线程继续去等待(类似银行业务办理窗口都满了，暂时没有受理窗口的顾客只能去候客区排队等候)，但等候线程仍然保留获取锁的可能且获取锁流程仍在继续(候客区的顾客也在等着叫号，轮到了再去受理窗口办理业务)。

既然说到了排队等候机制，那么就一定会有某种队列形成，这样的队列是什么数据结构呢？

如果共享资源被占用，就需要一定的阻塞等待唤醒机制来保证锁分配。这个机制主要用的是**CLH队列**的变体实现的，将暂时获取不到锁的线程加入到队列中，这个队列就是AQS的抽象表现。它将请求共享资源的线程封装成队列的结点（**Node**），通过CAS、自旋以及LockSupport.park()的方式，维护state变量的状态，使并发达到同步的效果。

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/AECDB8DC-56E9-4B0F-AF1F-13EBB0ACCBF6.png)

# 体系架构

**AQS = int变量 + CLH队列**

![image-20230722210116941](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230722210116941.png)

## Node内部类

![image-20230722210213059](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230722210213059.png)



![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/BDD4A0F0-421D-48BD-ACED-B9E82FDC036E.png)

## 同步队列基本结构

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/60EFECF5-4A36-4EC0-8905-B143A02D2A51.png)

CLH：Craig、Landin and Hagersten 队列，是个单向链表，AQS中的队列是CLH变体的虚拟双向队列（FIFO）

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/3DCA41FC-B03F-4F7D-A9D2-D9B502793931.png)

# ReentrantLock 实现

`ReentrantLock` 底层使用`Sync`实现，对应有非公平`NonfairSync` 和公平`FairSync` 都是继承`AbstractQueuedSynchronizer`

对比公平锁和非公平锁的 `tryAcquire`()方法的实现代码，其实差别就在于非公平锁获取锁时比公平锁中少了一个判断 `!hasQueuedPredecessors()`

hasQueuedPredecessors() 中判断了是否需要排队，导致公平锁和非公平锁的差异如下：

公平锁：公平锁讲究先来先到，线程在获取锁时，如果这个锁的等待队列中已经有线程在等待，那么当前线程就会进入等待队列中；

非公平锁：不管是否有等待队列，如果可以获取锁，则立刻占有锁对象。也就是说队列的第一个排队线程在unpark()，之后还是需要竞争锁（存在线程竞争的情况下）

## 加锁过程

```java
    static final class NonfairSync extends Sync {
        private static final long serialVersionUID = 7316153563782823691L;

        /**
         * Performs lock.  Try immediate barge, backing up to normal
         * acquire on failure.
         */
        final void lock() {
            if (compareAndSetState(0, 1)) // 第一个线程抢占
                setExclusiveOwnerThread(Thread.currentThread());
            else
                acquire(1); // 后续线程抢占
        }

    public final void acquire(int arg) {
        if (!tryAcquire(arg) &&
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }
		//  1.tryAcquire 设置  尝试获取锁
        final boolean nonfairTryAcquire(int acquires) {
            final Thread current = Thread.currentThread();
            int c = getState();
            if (c == 0) {
                if (compareAndSetState(0, acquires)) {
                    setExclusiveOwnerThread(current);
                    return true;
                }
            }
            else if (current == getExclusiveOwnerThread()) {
                int nextc = c + acquires;
                if (nextc < 0) // overflow
                    throw new Error("Maximum lock count exceeded");
                setState(nextc);
                return true;
            }
            return false; // 
        }        
		//  2.addWaiter 设置   创建node节点 进入等待队列
    private Node addWaiter(Node mode) {
        Node node = new Node(Thread.currentThread(), mode);
        // Try the fast path of enq; backup to full enq on failure
        Node pred = tail;
        if (pred != null) {
            node.prev = pred;
            if (compareAndSetTail(pred, node)) {
                pred.next = node;
                return node;
            }
        }
        enq(node);
        return node;
    }        
// 双向链表中，第一个节点为虚节点(也叫哨兵节点)，其实并不存储任何信息，只是占位。真正的第一个有数据的节点，是从第二个节点开始的。        
     private Node enq(final Node node) {
        for (;;) {
            Node t = tail;
            if (t == null) { // Must initialize 第一次初始化 
                if (compareAndSetHead(new Node())) // 哨兵节点 占位
                    tail = head;
            } else {
                node.prev = t;
                if (compareAndSetTail(t, node)) {
                    t.next = node;
                    return t;
                }
            }
        }
    }        
//  3.acquireQueued 设置
    final boolean acquireQueued(final Node node, int arg) {
        boolean failed = true;
        try {
            boolean interrupted = false;
            for (;;) {
                // 前驱节点-哨兵节点
                final Node p = node.predecessor();
                if (p == head && tryAcquire(arg)) {
                    setHead(node);
                    p.next = null; // help GC
                    failed = false;
                    return interrupted;
                }
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    interrupted = true;
            }
        } finally {
            // 异常流程
            if (failed)
                cancelAcquire(node);
        }
    }        
    private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
        int ws = pred.waitStatus;
        if (ws == Node.SIGNAL) // 第二次进入
            /*
             * This node has already set status asking a release
             * to signal it, so it can safely park.
             */
            return true;
        if (ws > 0) {
            /*
             * Predecessor was cancelled. Skip over predecessors and
             * indicate retry.
             */
            do {
                node.prev = pred = pred.prev;
            } while (pred.waitStatus > 0);
            pred.next = node;
        } else {
            /*
             * waitStatus must be 0 or PROPAGATE.  Indicate that we
             * need a signal, but don't park yet.  Caller will need to
             * retry to make sure it cannot acquire before parking.
             */
            // 第一次 修改哨兵节点waitStatus = -1
            compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
        }
        return false;
    }
	// 挂起抢占线程       
    private final boolean parkAndCheckInterrupt() {
        LockSupport.park(this); // 线程给挂起
        return Thread.interrupted();
    }        
```

## 解锁过程

```java
    public void unlock() {
        sync.release(1);
    }
	public final boolean release(int arg) {
        if (tryRelease(arg)) {
            Node h = head;
            if (h != null && h.waitStatus != 0)
                unparkSuccessor(h);
            return true;
        }
        return false;
    }

    protected final boolean tryRelease(int releases) {
        int c = getState() - releases;
        if (Thread.currentThread() != getExclusiveOwnerThread())
            throw new IllegalMonitorStateException();
        boolean free = false;
        if (c == 0) {
            free = true;
            setExclusiveOwnerThread(null);
        }
        setState(c);
        return free;
    }
```

# ReentrantLock、ReentrantReadWriteLock、StampedLock

## 锁演变

> 无锁 ->  独占锁 -> 读写锁 -> 邮戳(票据)锁

无锁： 多线程竞争，数据无序

独占锁：读写操作全部互斥，效率低

读写锁：读写互斥，读读共享

## 读写锁

`ReentrantReadWriteLock`

### 定义

一个资源能被多个**读线程**访问，或者被一个**写线程**访问。但是不能同时存在读写线程。

### 缺点

读写锁不是真正意义上的读写分离，它只允许读读共存，而读写和写写依然是互斥的，大多实际场景是“**读/读”线程间并不存在互斥关系，只有"读/写"线程或"写/写"线程间的操作需要互斥的。因此引入ReentrantReadWriteLock。**

1. 锁饥饿问题：写线程获取不到锁
2. 读的过程中，如果没有释放，写线程不可以获取到锁，必须读完后，才能有机会写

### 适用条件

**只有在读多写少情境之下，读写锁才具有较高的性能体现。**

```java
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

/**
 * @author Alfred.Ning
 * @since 2023年07月24日 08:35:00
 */
public class ReentrantReadWriteLockDemo {

  public static void main(String[] args) {
    Resource resource = new Resource();
    for (int i = 1; i <= 10; i++) {
      int finalI = i;
      new Thread(() -> {
        resource.write(finalI + "", finalI + "");
      }, String.valueOf(i)).start();
    }

    for (int i = 1; i <= 10; i++) {
      int finalI = i;
      new Thread(() -> {
        resource.read(finalI + "");
      }, String.valueOf(i)).start();
    }
  }

}

class Resource {

  private Map<String, String> map = new HashMap<>();
  private Lock lock = new ReentrantLock();
  private ReentrantReadWriteLock rwLock = new ReentrantReadWriteLock();

  public void write(String key, String value) {
//    lock.lock();
    try {
      rwLock.writeLock().lock();
      System.out.println(Thread.currentThread().getName() + " 正在写入");
      map.put(key, value);
      TimeUnit.MICROSECONDS.sleep(400);
      System.out.println(Thread.currentThread().getName() + " 写入完成");

    } catch (InterruptedException e) {
      e.printStackTrace();
    } finally {
//      lock.unlock();
      rwLock.writeLock().unlock();
    }
  }

  public void read(String key) {
//    lock.lock();
    try {
      rwLock.readLock().lock();
      System.out.println(Thread.currentThread().getName() + " 正在读取");
      String value = map.get(key);
      System.out.println(Thread.currentThread().getName() + " 正在读取完成：" + value);
    } finally {
//      lock.unlock();
      rwLock.readLock().unlock();
    }

  }
}
```

### 锁降级

**锁的严苛程度变强叫做升级，反之叫做降级**

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/71CE3B64-7971-41F9-B64C-0C1EAD5AB203.png)

**将写入锁降级为读锁**，为了当前线程感知到数据变化，目的是**保证数据可见性**，写后立即读。

**悲观锁：**写锁必须在所有读锁完成之后进行操作 

**线程获取读锁是不能直接升级为写入锁的。**

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/B4C3735A-71BD-4B2D-8381-E8AF8C46CA34.png)

在ReentrantReadWriteLock中，当读锁被使用时，如果有线程尝试获取写锁，该写线程会被阻塞。所以，需要释放所有读锁，才可获取写锁。

即ReadWriteLock读的过程中不允许写，只有等待线程都释放了读锁，当前线程才能获取写锁，也就是写入必须等待。

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/EE2B6855-0906-4E18-B229-252D735B4704.png)

当前线程可以获取到写锁又获取到读锁，但是获取到了读锁不能继续获取写锁），这是因为读写锁要保持写操作的可见性。因为，如果允许读锁在被获取的情况下对写锁的获取，那么正在运行的其他读线程无法感知到当前写线程的操作。

#### 锁降级代码演示

```java
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock.ReadLock;
import java.util.concurrent.locks.ReentrantReadWriteLock.WriteLock;

/**
 * @author Alfred.Ning
 * @since 2023年07月24日 09:45:00
 */
public class LockDownGradingDemo {

  public static void main(String[] args) {
    ReentrantReadWriteLock rwLock = new ReentrantReadWriteLock();
    ReadLock readLock = rwLock.readLock();
    WriteLock writeLock = rwLock.writeLock();

    writeLock.lock();
    System.out.println("正在写");
    readLock.lock();
    System.out.println("正在读");
    writeLock.unlock();
    readLock.unlock();

    writeLock.lock();
    System.out.println("正在写");
    readLock.lock();
    System.out.println("正在读");
    writeLock.unlock();
//    readLock.unlock();
    writeLock.lock();
    System.out.println("正在写1");

  }
}

```

#### ReentrantWriteReadLock源码

**缓存设计，缓存一致性**

![image-20230724095256121](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230724095256121.png)

1. 声明了一个volatile类型的cacheValid变量，保证其可见性。
2. 首先获取读锁，如果cache不可用，则释放读锁，获取写锁，在更改数据之前，再检查一次cacheValid的值，然后修改数据，将cacheValid置为true，然后在释放写锁前获取读锁；此时，cache中数据可用，处理cache中数据，最后释放读锁。**这个过程就是一个完整的锁降级的过程，目的是保证数据可见性。**

如果违背锁降级的步骤:

- 如果当前的线程C在修改完cache中的数据后，没有获取读锁而是直接释放了写锁，那么假设此时另一个线程D获取了写锁并修改了数据，那么C线程无法感知到数据已被修改，则数据出现错误。

如果遵循锁降级的步骤 

- 线程C在释放写锁之前获取读锁，那么线程D在获取写锁时将被阻塞，直到线程C完成数据处理过程，释放读锁。这样可以保证返回的数据是这次更新的数据，该机制是专门为了缓存设计的。

# 邮戳锁StampedLock

## 定义

*也叫票据锁*

`StampedLock`是JDK1.8中新增的一个读写锁，也是对JDK1.5中的读写锁ReentrantReadWriteLock的优化。

`ReentrantReadWriteLock`效率高的原因在于它的并发读，`StampedLock` 代表了锁的状态。当stamp返回零时，表示线程获取锁失败。并且，当释放锁或者转换锁的时候，都要传入最初获取的stamp值。

## 读写锁的问题 - 锁饥饿

`ReentrantReadWriteLock`实现了读写分离，但是一旦读操作比较多的时候，想要获取写锁就变得比较困难了，假如当前1000个线程，999个读，1个写，有可能999个读取线程长时间抢到了锁，那1个写线程就悲剧了 因为当前有可能会一直存在读锁，而无法获得写锁，根本没机会写

### 解决锁饥饿

使用“公平”策略可以一定程度上缓解这个问题， 但是牺牲了系统的吞吐量

## 特点

- 所有获取锁的方法，都返回一个邮戳（Stamp），Stamp为零表示获取失败，其余都表示成功；
- 所有释放锁的方法，都需要一个邮戳（Stamp），这个Stamp必须是和成功获取锁时得到的Stamp一致；
- StampedLock是不可重入的，危险(如果一个线程已经持有了写锁，再去获取写锁的话就会造成死锁)

## 访问模式

1. Reading（读模式）：功能和ReentrantReadWriteLock的读锁类似
2. Writing（写模式）：功能和ReentrantReadWriteLock的写锁类似
3. Optimistic reading（乐观读模式）：无锁机制，类似于数据库中的乐观锁，**支持读写并发，很乐观认为读取时没人修改，假如被修改再实现升级为悲观读模式**

## 代码演示

```java
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.StampedLock;

/**
 * @author Alfred.Ning
 * @since 2023年07月24日 10:14:00
 */
public class StampedLockDemo {

  static int number = 20;
  static StampedLock stampedLock = new StampedLock();

  public void write() {
    long stamp = stampedLock.writeLock();
    System.out.println(Thread.currentThread().getName() + " 写线程准备修改");
    try {
      number += 20;
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      stampedLock.unlockWrite(stamp);
    }
    System.out.println(Thread.currentThread().getName() + " 写线程修改结束");
  }

  // 悲观读
  public void pessimisticRead() {
    long stamp = stampedLock.readLock();
    System.out.println(Thread.currentThread().getName() + " come in pessimistic lock, after 4 seconds");

    for (int i = 0; i < 4; i++) {
      try {
        TimeUnit.SECONDS.sleep(1);
        System.out.println(Thread.currentThread().getName() + " 正在读取中");
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }

    int result = number;
    try {
      System.out.println(Thread.currentThread().getName() + " 获取变量值: " + result);
      System.out.println("写线程没有修改值，因为 stampedLock.readLock()读的时候，不可以写，读写互斥");
    } finally {
      stampedLock.unlockRead(stamp);
    }
  }

  // 乐观读
  public void optimismRead() {
    long stamp = stampedLock.tryOptimisticRead();
    // 先获得一次数据
    int result = number;
    //间隔4秒钟，我们很乐观的认为没有其他线程修改过number值，实际靠判断。
    System.out.println("4秒前stampedLock.validate值(true无修改，false有修改)" + "\t" + stampedLock.validate(stamp));

    for (int i = 0; i < 4; i++) {
      try {
        TimeUnit.SECONDS.sleep(1);
        System.out.println(
            Thread.currentThread().getName() + "\t 正在读取中......" + i + "秒后stampedLock.validate值(true无修改，false有修改)" + "\t"
                + stampedLock.validate(stamp));
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }

    if (!stampedLock.validate(stamp)) {
      System.out.println("有人动过，有写操作");
      // 切换普通读
      stamp = stampedLock.readLock();

      try {
        System.out.println("乐观读升级为悲观读");
        // 重新获取结果
        result = number;
        System.out.println("重新读取之后结果：" + result);
      } finally {
        stampedLock.unlockRead(stamp);
      }
    }
    System.out.println(Thread.currentThread().getName() + " final value: " + result);
  }

  public static void main(String[] args) {
    StampedLockDemo resource = new StampedLockDemo();
//    悲观读
    new Thread(resource::pessimisticRead, "pessimisticRead").start();

//    乐观读
    new Thread(resource::optimismRead, "pessimisticRead").start();
    try {
      TimeUnit.SECONDS.sleep(6); // 模拟业务没有修改
    } catch (InterruptedException e) {
      e.printStackTrace();
    }

    // 乐观读
    new Thread(resource::optimismRead, "pessimisticRead").start();
    try {
      TimeUnit.SECONDS.sleep(2);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }

    new Thread(resource::write, "write Thread").start();
  }
}

```

## 缺点

- StampedLock 不支持重入，没有Re开头
- StampedLock 的悲观读锁和写锁都不支持条件变量（Condition）
- 使用 StampedLock一定不要调用中断操作，即不要调用interrupt() 方法
  如果需要支持中断功能，一定使用可中断的悲观读锁 `readLockInterruptibly`()和写锁`writeLockInterruptibly`()
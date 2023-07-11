---
title: "01-Thread"
date: 2023-06-19T19:56:37+08:00
lastmod: 2023-06-19T19:56:37+08:00
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

# 前置知识

## 1. 为什么多线程如何重要

硬件方面：摩尔定律失效，主频不在提高，核数在不断增加的情况下，让程序运行更快就需要用到并行或者并发编程

软件方面：高并发系统： 异步 + 回调等生产需求

## 2. 进程

是程序的一次执行，是系统进行资源分配和调度的独立单位，每个进程都有它自己的内存空间和系统资源

## 3. 线程

在同一进程有1个或多个线程，执行多个任务，每个任务可以看做线程，共享内存空间和资源

> 操作系统
>
> - 多进程形式，允许多个任务同时进行
> - 多线程形式，允许单个任务进行拆分不同的部分允许
> - 提供协调机制：一方面进程和线程之间产生冲突，一方面进程和线程之间共享资源

## 4. 管程

操作系统层面：**监视器(Monitor)**, 同步机制，是保证（同一时间）只有一个线程可以访问被保护的数据和代码。JVM中同步是基于进入和退出监视器对象(Monitor,管程对象)来实现的，每个对象实例都会有一个Monitor对象，底层是由C++实现。

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/FC2BBDBB-4CE7-49FA-94D5-7315DA925104.png)

## 5. 用户线程和守护线程

> Java线程分为用户线程和守护线程
>
> 线程的daemon属性默认为false:用户线程 

守护线程：特殊线程，后台执行任务，比如垃圾回收线程

用户线程：系统的工作线程，完成程序所执行的业务操作

1. 当程序的所有用户线程执行完毕，不管是否守护线程执行完毕，系统自动退出
2. 设置守护线程，需要在**start()方法**之前

## 6. 异步编排

### Future 与 Callable

1. Future 定义了**操作异步执行任务**的一些方法，如：获取异步执行的结果，取消任务执行，判断任务是否取消，判断任务执行是否完毕等。子线程去执行任务，比较耗时，主线程继续执行
2. Callable定义了具有返回值的任务

### FutureTask

![image-20230620210401747](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230620210401747.png)

**get阻塞：**一旦调用get方法，无论执行完成都会阻塞，**生成禁****用**

解决措施：**轮询替代阻塞**

> 高并发中，不要阻塞，尽可能少加锁，使用CAS

**isDone轮询：**

1. 轮询方式也是会耗费cpu资源，不能立即获得计算结果
2. 如果想要异步获取结果,通常都会以轮询的方式去获取结果尽量不要阻塞

```java
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * @author Alfred.Ning
 * @since 2023年06月20日 20:59:00
 */
public class FutureTaskDemo {

  public static void main(String[] args)
      throws ExecutionException, InterruptedException, TimeoutException {
    FutureTask<String> futureTask = new FutureTask<>(() -> {
      System.out.println("我是子线程...");
      return "子线程执行完毕";
    });
    new Thread(futureTask, "t1").start();
    futureTask.get();// 会阻塞 生产禁用，单独使用放在最后
    futureTask.get(2, TimeUnit.SECONDS); // 超时不候

    // 轮询解决阻塞
    while (true) {
      if (futureTask.isDone()) {
        System.out.println("result: " + futureTask.get());
        break;
      } else {
        Thread.sleep(1000); // 加入睡眠
        System.out.println("子任务进行中");
      }
    }
    System.out.println("我是主线程");
  }

}

```

### CompletableFuture

> 支持完成更复杂的任务
>
> - 应对Future的完成时间，完成了可以告诉我，也就是我们的回调通知
> - 将两个异步计算合成一个异步计算，这两个异步计算互相独立，同时第二个又依赖第一个的结果
> - 当Future集合中某个任务最快结束时，返回结果
> - 等待Future结合中的所有任务都完成

实现了`Future`、`CompletionStage`接口，对Funture改进和增强

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/F4814F67-A7F5-49AB-8319-95547EE40E97.png)

#### CompletionStage

代表异步计算过程中的某一个阶段，一个阶段完成以后可能会触发另外一个阶段，有些类似Linux系统的管道分隔符传参数

```java
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.ThreadPoolExecutor.AbortPolicy;
import java.util.concurrent.TimeUnit;

/**
 * @author Alfred.Ning
 * @since 2023年06月20日 21:16:00
 */
public class CompletableFutureDemo {

  public static void main(String[] args) throws ExecutionException, InterruptedException {
    easyUse();
    System.out.println("=======================");
    CompletableFuture.supplyAsync(() -> {
      try {
        TimeUnit.SECONDS.sleep(2);

      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      return 1;
    }).thenApply(f -> {
      // 任务2 依赖任务1
      return f + 2;
    }).whenComplete((v, e) -> {
      if (e == null) {
        // 无异常 有返回值
        System.out.println("result: " + v);
      }
    }).exceptionally(e -> {
      e.printStackTrace();
      return null;
    });
    System.out.println("main Thread");

    TimeUnit.SECONDS.sleep(3);
  }

  private static void easyUse()
      throws InterruptedException, ExecutionException {
    ThreadPoolExecutor customPool = new ThreadPoolExecutor(2, 2, 1L, TimeUnit.SECONDS,
        new ArrayBlockingQueue<>(50),
        Executors.defaultThreadFactory(), new AbortPolicy());
    // 无返回值 这里有自带的线程池
    CompletableFuture<Void> cf1 = CompletableFuture.runAsync(() -> {
      System.out.println(Thread.currentThread().getName() + "runAsync无返回值...");
    });
    // 这里沿用之前的Future 也是会阻塞的
    System.out.println(cf1.get());
    // 无返回值 自定义线程池
    CompletableFuture<Void> cf2 = CompletableFuture.runAsync(() -> {
      System.out.println(Thread.currentThread().getName() + "runAsync无返回值...");
    }, customPool);
    System.out.println(cf2.get());

    // 有返回值 这里有自带的线程池
    CompletableFuture<String> cf3 = CompletableFuture.supplyAsync(() -> {
      System.out.println(Thread.currentThread().getName() + "supplyAsync有返回值...");
      return "supplyAsync有返回值 -- cf3";
    });
    System.out.println(cf3.get());
    // 有返回值 自定义线程池
    CompletableFuture<String> cf4 = CompletableFuture.supplyAsync(() -> {
      System.out.println(Thread.currentThread().getName() + "supplyAsync有返回值...");
      return "supplyAsync有返回值 -- cf4";
    }, customPool);
    System.out.println(cf4.get());
    customPool.shutdown();
  }
}

```

#### 优点

1. 异步任务结束，自动回调某个对象的方法
2. 异步任务出错，自动回调某个对象的方法
3. 主线程设置好回调后，不再关心异步任务的执行，异步任务之间可以顺序执行

### join get

join 和 get一样，会阻塞，区别点：**join不抛出异常**

## 7. 比价需求

- 同一款产品，同时搜索出同款产品在各大电商的售价
- 同一款产品，同时搜索出本产品在某一个电商下，各个入驻门店的售价

```java
import static java.util.stream.Collectors.toList;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.TimeUnit;
import lombok.Getter;

/**
 * @author Alfred.Ning
 * @since 2023年06月21日 22:24:00
 */
public class CompletableNetMallDemo {

  static final List<NetMall> list = Arrays.asList(
      new NetMall("jd"),
      new NetMall("taobao"),
      new NetMall("pdd"),
      new NetMall("wph")
  );

  // calculate by step
  public static List<String> getPriceByStep(List<NetMall> list, String productName) {
    return list.stream()
        .map(el -> String.format(productName + "in %s price is %.2f", el.getMallName(),
            el.calcPrice(productName)))
        .toList();
  }


  // calculate all in
  public static List<String> getPriceCompletable(List<NetMall> list, String productName) {
    return list.stream()
        .map(el -> CompletableFuture.supplyAsync(
            () -> String.format(productName + "in %s price is %.2f", el.getMallName(),
                el.calcPrice(productName))))
        .toList()
        .stream()
        .map(CompletableFuture::join)
        .collect(toList());
  }

  public static void main(String[] args) {
    // JDK 使用17
    long startTime1 = System.currentTimeMillis();
    getPriceByStep(list, "On Top of Tides").forEach(System.out::println);

    long endTime1 = System.currentTimeMillis();
    System.out.println("step cost: " + (endTime1 - startTime1) + "ms");
    System.out.println("==========");

    long startTime2 = System.currentTimeMillis();
    getPriceCompletable(list, "On Top of Tides").forEach(System.out::println);
    long endTime2 = System.currentTimeMillis();
    System.out.println("completable cost: " + (endTime2 - startTime2) + "ms");
  }

}

class NetMall {

  @Getter
  // 模拟电商
  private String mallName;

  public NetMall(String mallName) {
    this.mallName = mallName;
  }

  public double calcPrice(String productName) {
    // 模拟计算
    try {
      TimeUnit.SECONDS.sleep(1);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    return ThreadLocalRandom.current().nextDouble() * 2 + productName.charAt(0);
  }

}

```

1. 数据状况不断增大，性能提升
2. 自定义线程池

# 8. CompletableFuture常用方法

## 1. 获得结果和触发计算

获得结果

- get
- get(long timeout, TimeUnit unit)
- getNow(T valueIfAbsent)
  - 没有计算完成的情况下，给我一个替代结果
  - 立即获取结果不阻塞：计算完，返回计算完成后的结果，没算完，返回设定的valueIfAbsent值
- join: 不抛出异常

主动触发计算

- public boolean complete(T value) ：是否打断get方法立即返回括号值。complete尝试打断，打算失败说明计算成功，返回计算结果值，打断成功，说明计算进行中，返回default

## 2. 对计算结果处理

- thenApply: 不同步骤之间存在依赖关系，线程串行化，有任何一个步骤出错就进入exceptionally
- hanle: 有异常仍可以继续运行，携带异常参数

**whenComplete与whenCompleteAsync区别**

whenComplete：是执行当前任务的线程池会继续执行whenComplete的任务

whenCompleteAsync：whenCompleteAsync的任务提交给线程池继续执行

## 3. 对结果进行消费

- thenRun(Runnable runnable) ： 任务 A 执行完执行 B，并且 B 不需要 A 的结果
- thenAccept(Consumer action) ： 任务 A 执行完执行 B，B 需要 A 的结果，但是任务 B 无返回值
- thenApply(Function fn): 任务 A 执行完执行 B，B 需要 A 的结果，同时任务 B 有返回值

## 4. 对计算速度选用

谁快用谁

- applyToEither

## 5. 对计算结果合并

- 两个CompletionStage任务都完成后，最终能把两个任务的结果一起交给thenCombine 来处理
- **先完成的先等着，等待其它分支任务**
- thenCombine

```java
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

/**
 * @author Alfred.Ning
 * @since 2023年06月23日 22:31:00
 */
public class CompletableFutureApiDemo {

  public static void main(String[] args) throws ExecutionException, InterruptedException {
    apiTest01();
    apiTest02();
    apiTest03();
    apiTest04();
    apiTest05();
  }


  // 对计算结果合并
  public static void apiTest05() throws ExecutionException, InterruptedException {
    System.out.println("apiTest05........");
    System.out.println(CompletableFuture.supplyAsync(() -> {
      // 任务1
      return 10;
    }).thenCombine(CompletableFuture.supplyAsync(() -> {
      // 任务2
      return 20;
    }), (r1, r2) -> {
      // 合并
      return r1 + r2;
    }).thenCombine(CompletableFuture.supplyAsync(() -> {
      // 任务3
      return 100;
    }).thenCombine(CompletableFuture.supplyAsync(() -> {
      // 任务4
      return 200;
    }), (r1, r2) -> {
      // 合并
      return r1 + r2;
    }), (task1, task2) -> {
      System.out.println("task1-res: " + task1);
      System.out.println("task2-res: " + task2);
      return task1 + task2;
    }).join());
    TimeUnit.SECONDS.sleep(3);
  }

  // 对计算速度进行选用
  public static void apiTest04() throws ExecutionException, InterruptedException {
    System.out.println("apiTest04........");
    System.out.println(CompletableFuture.supplyAsync(() -> {
      try {
        TimeUnit.SECONDS.sleep(1);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      return 10;
    }).applyToEither(CompletableFuture.supplyAsync(() -> {
      try {
        TimeUnit.SECONDS.sleep(2);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      return 20;
    }), f -> f).join());
    TimeUnit.SECONDS.sleep(3);
  }

  // 对结果进行消费
  public static void apiTest03() throws ExecutionException, InterruptedException {
    System.out.println("apiTest03........");
    System.out.println(CompletableFuture.supplyAsync(() -> "resultA").thenRun(() -> {
    }).join());

    System.out.println(CompletableFuture.supplyAsync(() -> "resultA").thenAccept(resultA -> {
    }).join());

    System.out.println(
        CompletableFuture.supplyAsync(() -> "resultA").thenApply(resultA -> resultA + " resultB")
            .join());
    TimeUnit.SECONDS.sleep(3);
  }

  // 获对计算结果处理
  public static void apiTest02() throws ExecutionException, InterruptedException {
    System.out.println("apiTest02........");
    CompletableFuture.supplyAsync(() -> {
      System.out.println("step1...");
      return 1;
    }).thenApply(v -> {
      System.out.println("step2...");
      return v + 2;
    }).thenApply(v -> {
      System.out.println("step3...");
      return v + 3;
    }).thenApply(v -> {
      System.out.println("step4...");
      return v + 4;
    }).whenComplete((v, e) -> {
      if (e == null) {
        System.out.println("res: " + v);
      }
    }).exceptionally(e -> {
      e.printStackTrace();
      return null;
    });
    System.out.println("测试handle");
    System.out.println(CompletableFuture.supplyAsync(() -> {
      System.out.println("step1...");
      return 1;
    }).handle((v, e) -> {
      System.out.println("step2...");
      int i = 1 / 0;
      return v + 2;
    }).handle((v, e) -> {
      System.out.println("step3...");
      return v + 3;
    }).handle((v, e) -> {
      System.out.println("step4...");
      return v + 4;
    }).whenComplete((v, e) -> {
      if (e == null) {
        System.out.println("res: " + v);
      }
    }).exceptionally(e -> {
      e.printStackTrace();
      return null;
    }).join());
    // 主线程不要立刻结束，否则CompletableFuture默认使用的线程池会立刻关闭:
    try {
      TimeUnit.SECONDS.sleep(2);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }

  // 获得结果与触发计算
  public static void apiTest01() throws ExecutionException, InterruptedException {
    System.out.println("apiTest01........");
    CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> {
      try {
        TimeUnit.SECONDS.sleep(1);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      return 1;
    });
    System.out.println(future.getNow(2));
    try {
      TimeUnit.SECONDS.sleep(1);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    // complete尝试打断，打算失败说明计算成功，返回计算结果值，打断成功，说明计算进行中，返回default
    System.out.println(future.complete(20) + "\t" + future.get());
  }

}

```

# Java锁

## 悲观锁、乐观锁

### 悲观锁

认为自己在使用数据的时候一定会有其它线程来修改数据，获取数据的时候进行加锁，确保别的线程不会修改它。

实现方式：**synronized**，**Lock**

### 乐观锁

认为自己在使用数据的时候不会有别的线程来就修改它，之会在更新的时候去判断之前有没有别的线程修改这个数据。

如果这个数据没有被更新，当前线程将自己修改的数据成功写入。如果数据已经被其他线程更新，则根据不同的实现方式执行不同的操作。

1. 适合读操作多的场景，不加锁的特点能够使其读操作的性能大幅提升。
2. 乐观锁则直接去操作同步资源，是一种无锁算法。

**乐观锁在Java中采用无锁编程**

实现方式：CAS，采用版本号机制

## Synchronized

### 作用范围

- 作用于实例方法，当前实例加锁，进入同步代码前要获得当前实例的锁；
- 作用于代码块，对括号里配置的对象加锁。
- 作用于静态方法，当前类加锁，进去同步代码前要获得当前类对象的锁，锁的是类的Class；

> 能用对象锁就用对象锁，后考虑类锁

### synchronized实现探究

####  反编译 - java原生指令

- javap -c XX.class
- javap -V XX.class  -v:verbose更加详情信息

#### synchronized同步代码块

![image-20230625213241506](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230625213241506.png)

1. 为什么会有两个`monitorexit`

   因为方法退出有

   - 正常退出
   - 异常退出

   JVM需要保证正常/异常都能够释放

2. 一定是两个`monitorexit`吗
   **不是**
   ![](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230625213615751.png)

异常非正常结束，底层需要抛出异常**athrow**

#### synchronized同步方法

调用指令会检查方法的ACC_SYNCHRONIZED是否被设置。如果设置了，先获取monitor再执行方法，最后在完成结束【正常/异常】释放monitor

#### synchronized静态同步方法

ACC_STATIC, ACC_SYNCHRONIZED访问标志区分该方法是否静态同步方法

> Java的这些信息存储在Object类，对应ObjectMonitor.cpp
> 每个对象天生都带着一个对象监视器

## 公平锁和非公平锁

程序中的公平性是符合请求锁的绝对时间的，类似FIFO，否则视为不公平

```java
private Lock lock = new ReentrantLock(); // 默认非公平
```

### ？为什么会有公平锁和非公平锁的设计, 为什么默认非公平

1. 恢复挂起的线程到真正获取锁的时间是有时间差的，从开发人员看该时间微乎其微。但是从cpu角度，时间差还是比较明显的。非公平锁能够充分利用CPU时间片，尽量减少CPU空闲状态时间
2. 多线程的考量点是线程的切换。采**用非公平，当一个线程请求锁获取同步状态，然后释放同步状态。因为不需要考虑是否有前驱节点。所以刚释放锁的线程在此刻再次获取同步状态的概率就变得非常大，所以就减少了线程的开销。**

### ？使用公平锁会有什么问题

公平锁保持排队的公平性，所以就导致有的锁在长时间排队，造成"锁饥饿"

### ？什么时候用公平，什么时候使用非公平

如果为了更高的吞吐量，使用非公平锁是合理的，因为减少线程切换的时间，吞吐量自然就上去了。否认使用公平锁，公平使用

## 可重入锁

> 又名递归锁

同一个线程在外层方法获取锁，在进入该线程内的局部方法会自动获取锁（前提：锁的是同一个对象）

### Synchronized可重入

synchronized默认是可重入的。**每个锁对象都拥有一个对象锁计数器和一个指向该所锁的线程的指针**

- 执行monitorentery时，如果目标对象的锁计数器为0，说明没有被其他线程持有，java虚拟机会将该锁对象的指针指向当前线程，并且计数器加1
- 如果目标对象的锁计数器不为0的情况
  - 锁对象的持有线程是当前线程，虚拟机将其计数器加1
  - 否则等待，等待其持有线程释放锁
- 执行monitorexit，java虚拟机将锁对象的计数器减1，计数器为0代表该锁已经释放

### ReentrantLock

显示锁ReentrantLock也是可重入锁。这里一定注意加锁和解锁配对出现，否则可能造成死锁

## 死锁

两个或两个以上的线程在执行过程中，因竞争资源而造成的一种互相等待锁的现象。若无外力干涉下，都无法推进下去。

- 系统资源不足
- 进程运行推进顺序不当
- 资源分配不当

## 死锁代码演示

```java
import java.util.concurrent.TimeUnit;

/**
 * @author Alfred.Ning
 * @since 2023年07月09日 14:51:00
 */
public class ThreadLockDemo {

  private static Object lockA = new Object();
  private static Object lockB = new Object();

  public static void main(String[] args) {
    new Thread(() -> {
      synchronized (lockA) {
        System.out.println(Thread.currentThread().getName() + "我是A,期待获取B");
        try {
          TimeUnit.SECONDS.sleep(1);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
        synchronized (lockB) {
          System.out.println(Thread.currentThread().getName() + "获得B成功");
        }
      }
    }, "t1").start();

    new Thread(() -> {
      synchronized (lockB) {
        System.out.println(Thread.currentThread().getName() + "我是B,期待获取A");
        try {
          TimeUnit.SECONDS.sleep(1);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
        synchronized (lockA) {
          System.out.println(Thread.currentThread().getName() + "获得A成功");
        }
      }
    }, "t2").start();
  }

}

```

## 死锁排查

### jps + jstack

![image-20230709145604752](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230709145604752.png)

![image-20230709145613169](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230709145613169.png)

### jconsole

![image-20230709145650330](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230709145650330.png)

# 线程中断机制

## 关于中断

首先，一个线程本不应该被其他线程强制中断或停止，而是由自己决定是否停止。

`Thread.stop`、`Thread.suspend`、`Thread.resume`都已经废弃了

其次，Java中没有办法立即停止一个线程，但是停止线程例如某些耗时操作是重要的。Java提供机制-中断

中断只是一种协商机制，中断的过程完全由程序员自己实现。

每个线程对象中都有一个线程中断标识

通过调用线程对象的interrupt方法将该线程的标识位设为true；可以在别的线程中调用，也可以在自己的线程中调用。

? 如何中断表示停止线程

- volatie
- AtomicBoolean
- Thread自带api
  - 实例方法interrupt()，没有返回值
  - 实例方法isInterrupted，返回布尔值

```java
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * @author Alfred.Ning
 * @since 2023年07月09日 16:43:00
 */
public class ThreadInterruptDemo {

  private static volatile boolean isStop = false;
  private static AtomicBoolean atomicBoolean = new AtomicBoolean(false);

  public static void main(String[] args) {
    m1();
    m2();
    m3();
  }

  // volatile中断线程
  private static void m1() {
    new Thread(() -> {
      while (true) {
        if (isStop) {
          System.out.println(Thread.currentThread().getName() + "线程 volatile被中断");
          break;
        }
        System.out.println("线程 执行ing");
      }
    }, "t1").start();

    try {
      TimeUnit.SECONDS.sleep(1);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    new Thread(() -> {
      isStop = true;
    }, "t2").start();
  }

  // atomicBoolean中断线程
  private static void m2() {
    new Thread(() -> {
      while (true) {
        if (atomicBoolean.get()) {
          System.out.println(Thread.currentThread().getName() + "线程 atomicBoolean被中断");
          break;
        }
        System.out.println("线程 执行ing");
      }
    }, "t1").start();

    try {
      TimeUnit.SECONDS.sleep(1);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    new Thread(() -> {
      atomicBoolean.set(true);
    }, "t2").start();
  }

  // interrupt中断线程
  private static void m3() {
    Thread t1 = new Thread(() -> {
      while (true) {
        if (Thread.currentThread().isInterrupted()) {
          System.out.println(Thread.currentThread().getName() + "线程 interrupt被中断");
          break;
        }
        System.out.println("线程 执行ing");
      }
    }, "t1");
    t1.start();

    try {
      TimeUnit.SECONDS.sleep(1);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    new Thread(() -> {
      t1.interrupt();
    }, "t2").start();
  }

}
```

**当前线程的中断标识为true，不是立刻停止**

**中断只是一种协同机制，修改中断标识位仅此而已，不是立刻stop打断**

## Thread类自带API方法说明

### 实例方法  - interrupt

调用interrupt()方法仅仅是在当前线程中打了一个停止的标记，并不是真正立刻停止线程。

如果一个线程在睡眠、等待等状态中，执行中断方法会抛出`InterruptedException`, **该异常会清除中断标志，设置为false**

 这里要在执行一次中断

`Thread.currentThread().interrupt()`

### 实例方法  - isInterrupted

判断当前线程是否被中断，返回中断标志位目前是什么，默认**false**

### 静态方法 - interrupted

该方法完成两件事

1. 返回当前线程的中断状态
2. 将当前线程的中断状态设置为false

```java
import java.util.concurrent.TimeUnit;

/**
 * @author Alfred.Ning
 * @since 2023年07月09日 16:43:00
 */
public class ThreadInterruptDemo {

  public static void main(String[] args) {
    m4();
    m5();
    m6();
  }

  // 测试静态方法Thread.interrupted
  public static void m6() {
    System.out.println(Thread.currentThread().getName() + "---" + Thread.interrupted());
    System.out.println(Thread.currentThread().getName() + "---" + Thread.interrupted());
    System.out.println("111111");
    Thread.currentThread().interrupt();
    System.out.println("222222");
    System.out.println(Thread.currentThread().getName() + "---" + Thread.interrupted());
    System.out.println(Thread.currentThread().getName() + "---" + Thread.interrupted());
  }

  // 已经进入sleep进行中断会抛出中断异常
  public static void m5() {
    Thread t1 = new Thread(() -> {
      while (true) {
        if (Thread.currentThread().isInterrupted()) {
          System.out.println("----isInterrupted: true, 程序结束");
          break;
        }
        try {
          Thread.sleep(5000);
        } catch (InterruptedException e) {
          // 这里不处理的话，程序不会停止
          Thread.currentThread().interrupt(); // 进行复位
          e.printStackTrace();
        }
        System.out.println("hello");

      }

    }, "t1");

    t1.start();
    try {
      TimeUnit.SECONDS.sleep(1);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }

    new Thread(() -> {
      t1.interrupt();
    }).start();
  }

  // 中断不是立刻执行
  public static void m4() {
    Thread t1 = new Thread(() -> {
      while (true) {
        if (Thread.currentThread().isInterrupted()) {
          System.out.println("-----t1 线程被中断了，break，程序结束");
          break;
        }
        System.out.println("-----hello");
      }
    }, "t1");
    t1.start();
    System.out.println("**************" + t1.isInterrupted());
    try {
      //暂停5毫秒
      TimeUnit.MILLISECONDS.sleep(5);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    // 中断标志设置true,不是立刻停止
    t1.interrupt();
    System.out.println("**************" + t1.isInterrupted());
  }

}
```


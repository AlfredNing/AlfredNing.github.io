---
title: "1.JUC初识"
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
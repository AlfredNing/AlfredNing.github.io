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

## 同步队列基本结构

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/60EFECF5-4A36-4EC0-8905-B143A02D2A51.png)

CLH：Craig、Landin and Hagersten 队列，是个单向链表，AQS中的队列是CLH变体的虚拟双向队列（FIFO）
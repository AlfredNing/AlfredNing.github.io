---
title: "Jvm初识"
date: 2023-02-14T07:58:50+08:00
lastmod: 2023-02-14T07:58:50+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- jvm
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

# JDK关系

> Oracle JDK 与 Open JDK 关系

1. Oracle JDK是由oracle 公司开发的，Open JDK 是由IBM，Apple，SAP AG，Redhat等顶级公司合作开发
2. Oracle JDK大多数的功能是开源的，一些功能是开源。Open JDK完全开源
3. Oracle JDK以前的1.0版以前的版本是由Sun开发的，后来被Oracle收购并为其他版本维护，而OpenJDK最初只基于Java SDK或JDK版本7
4.  Oracle JDK不会为即将发布的版本提供长期支持，用户每次都必须通过更新到最新版本获得支持来获取最新版本
5. Oracle JDK将从其10.0.X版本将收费，用户必须付费或必须依赖OpenJDK才能使用其免费版本
6. Oracle JDK在运行JDK时不会产生任何问题，而OpenJDK在为某些用户运行JDK时会产生一些问题
7. **在响应性和JVM性能方面，Oracle JDK与OpenJDK相比提供了更好的性能**
8. Oracle JDK具有良好的GC选项和更好的渲染器，而OpenJDK具有更少的GC选项，并且由于其包含自己的渲染器的分布，因此具有较慢的图形渲染器选项
9.  Oracle JDK的构建过程基于OpenJDK，因此OpenJDK与Oracle JDK之间没有技术差异
10. Oracle JDK将更多地关注稳定性，它重视更多的企业级用户，而OpenJDK经常发布以支持其他性能，这可能会导致不稳定

# JDK与JVM的关系

JDK: Java Development ToolKit(java开发工具包)。JDK是整个java的核心，包括了运行环境，java工具和java的基础类库。

jvm:Java Virtual Machine(java虚拟机)。通过在实际的计算机上模拟仿真各种计算机功能来实现。

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/D45B5044-D227-43BF-9B9D-3F7954E19AB8.png)

**使用JDK（调用JAVA API）开发JAVA程序后，通过JDK中的编译程序（javac）将Java程序编译为Java字节码，在JRE上运行这些字节码，JVM会解析并映射到真实操作系统的CPU指令集和OS的系统调用**

## 如何理解java是跨平台的语言

当java的源代码经过编译程序编译成字节码，需要运行在不同的平台上面时，无需编译。

## 如何理解JVM是跨语言的平台

jvm面对的是字节码文件，只**关心字节码文件**，不关心何种编程语言，只要实现jvm规范即可。J**ava不是最强大的语言，但是JVM是最强大的虚拟机。**

## JVM的类型

- Sun Classic VM -->解释型

- Exact VM  --> Solaris

- SUN公司的 HotSpot VM

- BEA 的 JRockit --> 不包含解释器，服务器端，JMC

- IBM 的 J9

- KVM和CDC/CLDC Hotspot

- Azul VM

- Liquid VM

- Apache Harmony

- Microsoft JVM

- TaobaoJVM

- Graal VM --> 2018年,“Run Programs Faster Anywhere”

![img](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/1184D25D-C1F2-45A2-BAB6-CE1FDD594737.png)

- Dalvik VM : 安卓系统底层

- 其他JVM：

 Java Card VM、Squawk VM、JavaInJava、Maxine VM、Jikes RVM、IKVM.NET、Jam VM、Cacao VM、Sable VM、Kaffe、Jelatine JVM、Nano VM、MRP、Moxie JVM

## JVM的生命周期

### 启动

java虚拟机的启动是由引导类加载器(bootstrap class loader)创建一个初始类(initial class)来完成的，**这个类是由虚拟机指定**

### 退出

1. 某线程调用Runtime类或System类的exit方法， 或Runtime类的halt方法【仅仅是拥有退出的机会】，并且在JAVA安全管理器允许这次exit或者halt方法操作会进行退出
2. 程序正常执行结束
3. 程序在执行过程中遇到了异常或错误进而终止
4. 由于操作系统错误而导致java虚拟机进程终止

# 关于HotSpot

目前是java主流的虚拟机。

- sun的JDK版本从1.3.1开始运用HotSpot虚拟机，2006年底开源，主要实现是c++, JNI接口部分用C实现
- HotSpot是比较新的虚拟机，使用JIT(Just In Time)编译器，可以大大提高java运行性能
- Java原先是把源代码编译成字节码虚拟机执行，速度较慢。HosSpot将常用的部分编译分为本地（原生，native)代码，显著提高性能
- HotSpot JVM参数分为**规则参数和非规则参数**。
  - 规则参数相对稳定，在JDK未来的版本不太会有太大的改动
  - 非规则参数则有升级JDK而改动的可能 

# JVM的架构（组成）

![jvm的组成](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/jvm%E7%9A%84%E7%BB%84%E6%88%90.jpg)

详细

![jvm组成-细分](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/jvm%E7%BB%84%E6%88%90-%E7%BB%86%E5%88%86.jpg)

1. 最上层：javac编译器将编译好的字节码class文件，通过java类装载器执行机制，把对象的class文件存放在jvm划分区域
2. 中间层：称为Runtime Data Area 主要是Java代码运行时用于存放数据
3. 最下层：解释器，JIT(just in time)编译器和GC(Garbage Collection 垃圾回收器)
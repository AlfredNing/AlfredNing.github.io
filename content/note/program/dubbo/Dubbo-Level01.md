---
title: "Dubbo Level01"
date: 2023-09-03T12:31:43+08:00
lastmod: 2023-09-03T12:31:43+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- Dubbo
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

# 基础理论

“分布式系统是若干独立计算机的集合，这些计算机对于用户来说就像单个相关系统”，分布式系统（distributed system）是建立在网络之上的软件系统。分布式服务架构以及流动计算架构势在必行，亟需**一个治理系统**确保架构有条不紊的演进。

## 架构演变

1. 单一应用架构

   适用于小型网站，小型管理系统，将所有功能都部署到一个功能里，简单易用。

   缺点： 1、性能扩展比较难

     		  2、协同开发问题

     		  3、不利于升级维护

2. 垂直应用架构

   适用于小型网站，小型管理系统，将所有功能都部署到一个功能里，简单易用。

   缺点： 1、性能扩展比较难

     		  2、协同开发问题

      		 3、不利于升级维护

3. 分布式服务架构
   当垂直应用越来越多，应用之间交互不可避免，将核心业务抽取出来，作为独立的服务，逐渐形成稳定的服务中心，使前端应用能更快速的响应多变的市场需求。此时，用于提高业务复用及整合的**分布式服务框架(RPC)**是关键

4. #### 流动计算架构

   当服务越来越多，容量的评估，小服务资源的浪费等问题逐渐显现，此时需增加一个调度中心基于访问压力实时管理集群容量，提高集群利用率。此时，用于**提高机器利用率的资源调度和治理中心(SOA)[ Service Oriented Architecture]是关键**

## RPC

RPC【Remote Procedure Call】是指远程过程调用，是一种进程间通信方式，他是一种技术的思想，而不是规范。它允许程序调用另一个地址空间（通常是共享网络的另一台机器上）的过程或函数，而不用程序员显式编码这个远程调用的细节。即程序员无论是调用本地的还是远程的函数，本质上编写的调用代码基本相同.

![image-20230903124625260](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230903124625260.png)

 RPC框架：dubbo gRpc 、Thrift 、HSF(High Speed Service Framework)

## dubbo

Apache Dubbo (incubating) |ˈdʌbəʊ| 是一款高性能、轻量级的开源Java RPC框架，它提供了三大核心能力：面向接口的远程方法调用，智能容错和负载均衡，以及服务自动注册和发现。

### 设计架构

![image-20230903131047505](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230903131047505.png)

- zookeeper
- 监控 dubbo-admin 

# 核心配置

## 加载配置

jvm启动参数 -> dubbo.properties -> spring配置

## 启动时候检查

Dubbo 缺省会在启动时检查依赖的服务是否可用，不可用时会抛出异常，阻止 Spring 初始化完成，以便上线时，能及早发现问题，默认 `check="true"`。

可以通过 `check="false"` 关闭检查，比如，测试时，有些服务不关心，或者出现了循环依赖，必须有一方先启动。

另外，如果你的 Spring 容器是懒加载的，或者通过 API 编程延迟引用服务，请关闭 check，否则服务临时不可用时，会抛出异常，拿到 null 引用，如果 `check="false"`，总是会返回引用，当服务恢复时，能自动连上。

`dubbo3 单独服务检查`

![image-20230903210255885](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230903210255885.png)

全局检查

![image-20230903210415533](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230903210415533.png)

## 超时配置

调用超时，方法级别优先 -> 接口 -> 全局

## 重试

异常重试，保持幂等行

## 多版本

升级存在多版本情况。

服务提供者，设置版本，消费者设置版本机制，灰度发布

## 本地存根

做 ThreadLocal 缓存，提前验证参数，调用失败后伪造容错数据等等，此时就需要在 API 中带上 Stub，客户端生成 Proxy 实例，会把 Proxy 通过构造函数传给 Stub [1](https://cn.dubbo.apache.org/zh-cn/overview/mannual/java-sdk/advanced-features-and-usage/service/local-stub/#fn:1)，然后把 Stub 暴露给用户，Stub 可以决定要不要去调 Proxy。

1. 消费者实现调用接口，构造传入
2. 消费端指定本地存根

# 高可用场景

## zookeeper宕机与dubbo直连

- 现象：zookeeper注册中心宕机，还可以消费dubbo暴露的服务。

l 监控中心宕掉不影响使用，只是丢失部分采样数据

l 数据库宕掉后，注册中心仍能通过缓存提供服务列表查询，但不能注册新服务

l 注册中心对等集群，任意一台宕掉后，将自动切换到另一台

l **注册中心全部宕掉后，服务提供者和服务消费者仍能通过本地缓存通讯**

l 服务提供者无状态，任意一台宕掉后，不影响使用

l 服务提供者全部宕掉后，服务消费者应用将无法使用，并无限次重连等待服务提供者恢复

![image-20230904080533274](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230904080533274.png)

## 负载均衡

服务提供者指定 或者消费端指定

### **Random LoadBalance** - Dubbo默认机制

随机，按权重设置随机概率。在一个截面上碰撞的概率高，但调用量越大分布越均匀，而且按概率使用权重后也比较均匀，有利于动态调整提供者权重。

### **RoundRobin LoadBalance**

轮循，按公约后的权重设置轮循比率。

存在慢的提供者累积请求的问题，比如：第二台机器很慢，但没挂，当请求调到第二台时就卡在那，久而久之，所有请求都卡在调到第二台上

### **LeastActive LoadBalance**

最少活跃调用数，相同活跃数的随机，活跃数指调用前后计数差。

使慢的提供者收到更少请求，因为越慢的提供者的调用前后计数差会越大。

### **ConsistentHash LoadBalance**

一致性 Hash，相同参数的请求总是发到同一提供者。

当某一台提供者挂时，原本发往该提供者的请求，基于虚拟节点，平摊到其它提供者，不会引起剧烈变动。算法参见：http://en.wikipedia.org/wiki/Consistent_hashing。缺省只对第一个参数 Hash，如果要修改，请配置 <dubbo:parameter key="hash.arguments" value="0,1" />

缺省用 160 份虚拟节点，如果要修改，请配置 <dubbo:parameter key="hash.nodes" value="320" />

## 服务降级

**当服务器压力剧增的情况下，根据实际业务情况及流量，对一些服务和页面有策略的不处理或换种简单的方式处理，从而释放服务器资源以保证核心交易正常运作或高效运作**

可以通过服务降级功能临时屏蔽某个出错的非关键服务，并定义降级后的返回策略。也可以通过监控设置

向注册中心写入动态配置覆盖规则：

```java
RegistryFactory  registryFactory =  ExtensionLoader.getExtensionLoader(RegistryFactory.class).getAdaptiveExtension();  
Registry  registry =  registryFactory.getRegistry(URL.valueOf("zookeeper://10.20.153.10:2181")); registry.register(URL.valueOf("override://0.0.0.0/com.foo.BarService?category=configurators&dynamic=false&application=foo&mock=force:return+null"));  
```

其中：

- mock=force:return+null 表示消费方对该服务的方法调用都直接返回 null 值，不发起远程调用。用来屏蔽不重要服务不可用时对调用方的影响。
- 还可以改为 mock=fail:return+null 表示消费方对该服务的方法调用在失败后，再返回 null 值，不抛异常。用来容忍不重要服务不稳定时对调用方的影响。  

## 集群容错

在集群调用失败时，Dubbo 提供了多种容错方案，缺省为 failover 重试。

**集群容错模式**

```java
- Failover Cluster  默认
失败自动切换，当出现失败，重试其它服务器。通常用于读操作，但重试会带来更长延迟。可通过 retries="2" 来设置重试次数(不含第一次)。

重试次数配置如下：
<dubbo:service retries="2" />
或
<dubbo:reference retries="2" />
或
<dubbo:reference>
    <dubbo:method name="findFoo" retries="2" />
</dubbo:reference>

- Failfast Cluster
快速失败，只发起一次调用，失败立即报错。通常用于非幂等性的写操作，比如新增记录。

- Failsafe Cluster
失败安全，出现异常时，直接忽略。通常用于写入审计日志等操作。

- Failback Cluster
失败自动恢复，后台记录失败请求，定时重发。通常用于消息通知操作。

- Forking Cluster
并行调用多个服务器，只要一个成功即返回。通常用于实时性要求较高的读操作，但需要浪费更多服务资源。可通过 forks="2" 来设置最大并行数。

- Broadcast Cluster
广播调用所有提供者，逐个调用，任意一台报错则报错 [2]。通常用于通知所有提供者更新缓存或日志等本地资源信息。

集群模式配置
按照以下示例在服务提供方和消费方配置集群模式
<dubbo:service cluster="failsafe" />
或
<dubbo:reference cluster="failsafe" />

```

配合hystrix实现容错调用

# 原理

## RPC原理

![image-20230904083308545](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230904083308545.png)

一次完整的RPC调用流程（同步调用，异步另说）如下：

1. **服务消费方（client）调用以本地调用方式调用服务；** 
2. client stub接收到调用后负责将方法、参数等组装成能够进行网络传输的消息体； 
3. client stub找到服务地址，并将消息发送到服务端； 
4. server stub收到消息后进行解码； 
5. server stub根据解码结果调用本地的服务； 
6. 本地服务执行并将结果返回给server stub； 
7. server stub将返回结果打包成消息并发送至消费方； 
8. client stub接收到消息，并进行解码； 
9. **服务消费方得到最终结果。**

**RPC框架的目标就是要2~8这些步骤都封装起来，这些细节对用户来说是透明的，不可见的。**

## Netty原理

Netty是一个异步事件驱动的网络应用程序框架， 用于快速开发可维护的高性能协议服务器和客户端。它极大地简化并简化了TCP和UDP套接字服务器等网络编程。

### BIO

![image-20230904083619400](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230904083619400.png)

### NIO

![image-20230904083630060](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230904083630060.png)

Selector 一般称 为**选择器** ，也可以翻译为 **多路复用器，**

Connect（连接就绪）、Accept（接受就绪）、Read（读就绪）、Write（写就绪）

![image-20230904083658958](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230904083658958.png)

## 框架设计


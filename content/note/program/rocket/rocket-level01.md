---
title: "Rocket Level01"
date: 2023-09-05T08:37:14+08:00
lastmod: 2023-09-05T08:37:14+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- RocketMQ
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

# 介绍

## 应用场景

- 应用解耦
- 流量削峰
- 大数据处理
- 异构系统

## 优势

- 低延迟
- 高压
- 可持续性
- 审计、银行、工业

# 角色

![image-20230908204256402](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230908204256402.png)

## broker

- 向生产者和消费者接收和发送消息
- 向nameserver提交自己的消息(nameserver是集群存在)
- 是消息中间件的消息存储，转发服务器
- 每个broker节点启动，遍历nameserver列表，与每个nameserver建立长连接，注册自己的信息，之后定时上报

## broker集群

- 可以配成Master/Slave结构

## producer

- 消息生产者
- 通过集群的其中一个节点（随机选择）建立长连接，获得Topic路由信息，包括Topic下面有哪些Queue,这些Queue分布在哪些Topic上 
- 向提供Topic的Master建立长连接，且定时向Master发送心跳

## Consumer

- 消息的消费者
- 可以和Master和slave连接

## nameserver

- 底层netty实现，提供路由管理，服务注册、服务发现，无状态节点
- 服务发现者
- 可以部署多个
-  nameserver集群间互不通信
- 内存式存储，默认不会持久化

# 操作

## 简单操作

`依赖`

```xml
<dependencies>
  <dependency>
    <groupId>org.apache.rocketmq</groupId>
    <artifactId>rocketmq-client</artifactId>
    <version>4.6.1</version>
  </dependency>
</dependencies>
```

### 同步发送消息

```java
package rocketq;

import org.apache.rocketmq.client.exception.MQClientException;
import org.apache.rocketmq.client.producer.DefaultMQProducer;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.common.message.Message;

/**
 * 发送者
 *
 * @author Alfred.Ning
 * @since 2023年09月08日 21:27:00
 */
public class Producer {

  public static void main(String[] args) throws Exception {
    DefaultMQProducer producer = new DefaultMQProducer("xyz");
    producer.setNamesrvAddr("localhost:9876");
    producer.start();

    Message message = new Message("topic01", "第二条消息".getBytes());

    // 同步消息发送， 有阻塞
    SendResult result = producer.send(message);
    System.out.println(result);

    producer.shutdown();


  }

}
```

### 接收消息

```java
package rocketq;

import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
import org.apache.rocketmq.client.consumer.listener.MessageListenerConcurrently;
import org.apache.rocketmq.client.exception.MQClientException;
import org.apache.rocketmq.common.message.MessageExt;

/**
 * 消费者
 *
 * @author Alfred.Ning
 * @since 2023年09月08日 21:38:00
 */
public class Consumer {

  public static void main(String[] args) throws MQClientException {
    DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("consumerGroup-1");
    consumer.setNamesrvAddr("localhost:9876");

    // 订阅 topic，过滤器 * 表示不过滤
    consumer.subscribe("topic01", "*");

    consumer.registerMessageListener((MessageListenerConcurrently) (msgs, consumeConcurrentlyContext) -> {
      for (MessageExt msg : msgs) {
        System.out.println(new String(msg.getBody()));
      }
      // 默认情况下， 一条消息会被一个Consumer消费 点对点 broker做状态修改 ack
      return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
    });

    consumer.start();
  }

}
```

### 批量发送消息

- 尽量发送消息不要超过1MB

```java
package rocketq;

import java.util.Arrays;
import java.util.List;
import org.apache.rocketmq.client.producer.DefaultMQProducer;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.common.message.Message;

/**
 * 批量发送
 *
 * @author Alfred.Ning
 * @since 2023年09月08日 21:27:00
 */
public class BatchProducer {

  public static void main(String[] args) throws Exception {
    DefaultMQProducer producer = new DefaultMQProducer("xyz");
    producer.setNamesrvAddr("localhost:9876");
    producer.start();

    Message message = new Message("topic01", "第0条消息".getBytes());
    Message message1 = new Message("topic01", "第1条消息".getBytes());
    Message message2 = new Message("topic01", "第2条消息".getBytes());

    List<Message> list = Arrays.asList(message, message1, message2);
    SendResult send = producer.send(list);
    producer.shutdown();
    System.out.println(send);

  }

}
```

### 异步处理

```java
package rocketq;

import org.apache.rocketmq.client.producer.DefaultMQProducer;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.common.message.Message;

/**
 * 异步处理
 *
 * @author Alfred.Ning
 * @since 2023年09月08日 21:27:00
 */
public class ASyncProducer {

  public static void main(String[] args) throws Exception {
    DefaultMQProducer producer = new DefaultMQProducer("xyz");
    producer.setNamesrvAddr("localhost:9876");
    producer.start();

    Message message = new Message("topic01", "第二条消息".getBytes());

    // 同步消息发送， 有阻塞
    SendResult result = producer.send(message);
    System.out.println(result);



    producer.shutdown();

    // 不需要应答 可能丢消息
    producer.sendOneway(message);
  }

}

```

### 广播消息与集群消息

#### 集群消息

指集群化部署消费者

- 每条消息只需要被处理一次，broker只会把消息投递到集群内的一个消费者
- 消息重投，不能保证路由到同一台机器
- **消息状态由broker维护**

#### 广播消息

MQ会把每条消息推送到集群内所有注册的客户端，保证消息至少被每台机器消费一次

- 消息进度由consumer维护
- 保证每个消费者消费一次消息
- 消失失败的消息不会重投

```java
// 设置消费模式 广播模式
consumer.setMessageModel(MessageModel.BROADCASTING);
// 集群模式
consumer.setMessageModel(MessageModel.CLUSTERING);
```

#### 消息过滤

```java
    // tag分组 key查询消息
    Message message = new Message("topic01", "Tag-B", "key_id", "异步消息".getBytes());

    // 订阅 topic，过滤器 * 表示不过滤 只接收Tag-B  tag在同一个group中保持统一 否则可能会丢消息
    consumer.subscribe("topic01", "Tag-B");
```

####  SQL过滤

1. 开启配置
   broker.conf `enablePropertyFilter=true`

2. 发送端配置

   ```java
   package rocketq;
   
   import java.util.ArrayList;
   import java.util.concurrent.TimeUnit;
   import org.apache.rocketmq.client.exception.MQClientException;
   import org.apache.rocketmq.client.producer.DefaultMQProducer;
   import org.apache.rocketmq.client.producer.SendCallback;
   import org.apache.rocketmq.client.producer.SendResult;
   import org.apache.rocketmq.common.message.Message;
   
   /**
    * sql过滤-发送者
    *
    * @author Alfred.Ning
    * @since 2023年09月08日 21:27:00
    */
   public class Producer {
   
     public static void main(String[] args) throws Exception {
       DefaultMQProducer producer = new DefaultMQProducer("xyz");
       producer.setNamesrvAddr("localhost:9876");
       producer.start();
   
       ArrayList<Message> messages = new ArrayList<>();
       for (int i = 0; i < 50; i++) {
         Message message = new Message("topic02", "异步消息".getBytes());
         message.putUserProperty("age", String.valueOf(i));
         messages.add(message);
       }
       producer.send(messages);
   
     }
   
   }
   
   ```

3. 消费者

4. ```java
   package rocketq;
   
   import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
   import org.apache.rocketmq.client.consumer.MessageSelector;
   import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
   import org.apache.rocketmq.client.consumer.listener.MessageListenerConcurrently;
   import org.apache.rocketmq.client.exception.MQClientException;
   import org.apache.rocketmq.client.producer.MessageQueueSelector;
   import org.apache.rocketmq.common.message.MessageExt;
   
   /**
    * sql过滤-消费者
    *
    * @author Alfred.Ning
    * @since 2023年09月08日 21:38:00
    */
   public class Consumer2 {
   
     public static void main(String[] args) throws MQClientException {
       DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("consumerGroup-3");
       consumer.setNamesrvAddr("localhost:9876");
   
       MessageSelector messageSelector = MessageSelector.bySql("age >= 18 and age <= 30");
       consumer.subscribe("topic02", messageSelector);
   
       consumer.registerMessageListener((MessageListenerConcurrently) (msgs, consumeConcurrentlyContext) -> {
         for (MessageExt msg : msgs) {
           System.out.println(new String(msg.getBody()));
         }
         return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
       });
       consumer.start();
     }
   
   }
   ```

   

   ---
   
   # 事务消息
   
   > 分布式事务：2pc / tcc
   >
   > 2pc: XA协议
   >
   > 	1. 尝试提交阶段
   > 	1. 确认提交
   >
   > tcc： try confirm cancel
   
   ![image-20230909131618736](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230909131618736.png)





![image-20230909132401618](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230909132401618.png)

```java
package rocketq.Transaction;

import java.time.Instant;
import java.time.format.DateTimeFormatter;
import org.apache.rocketmq.client.producer.LocalTransactionState;
import org.apache.rocketmq.client.producer.TransactionListener;
import org.apache.rocketmq.client.producer.TransactionMQProducer;
import org.apache.rocketmq.common.message.Message;
import org.apache.rocketmq.common.message.MessageExt;

/**
 * 事务-发送者
 *
 * @author Alfred.Ning
 * @since 2023年09月09日 13:27:00
 */
public class Producer {

  public static void main(String[] args) throws Exception {
    TransactionMQProducer transactionMQProducer = new TransactionMQProducer("abc44");
    transactionMQProducer.setNamesrvAddr("localhost:9876");
    transactionMQProducer.start();

    // 回调
    transactionMQProducer.setTransactionListener(new TransactionListener() {
      @Override
      public LocalTransactionState executeLocalTransaction(Message message, Object o) {
        try {
          /**
           * A服务：
           *
           * 提交注册信息
           * 写入数据库
           * 新用户 -> 发消息 (前两步成功）
           *
           *
           * B服务：
           * 拿到新用户的信息，发送短信
           */
          // 执行本地事务 同步执行
          System.out.println(">>>>>>>>>executeLocalTransaction>>>>>>>>>>>>");
          System.out.println(new String(message.getBody()));
          System.out.println("tid：" + message.getTransactionId());
          System.out.println("curr: " + DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(Instant.now()));
        } catch (Exception e) {
          e.printStackTrace();
          return LocalTransactionState.ROLLBACK_MESSAGE;
        }
        return LocalTransactionState.COMMIT_MESSAGE;
      }

      @Override
      public LocalTransactionState checkLocalTransaction(MessageExt messageExt) {
        System.out.println(">>>>>>>>>checkLocalTransaction>>>>>>>>>>>>");
        System.out.println(new String(messageExt.getBody()));
        System.out.println("tid：" + messageExt.getTransactionId());
        // broker回调  检查本地事务
//        return LocalTransactionState.COMMIT_MESSAGE; // 事务成功
        System.out.println("curr: " + DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(Instant.now()));
        return LocalTransactionState.COMMIT_MESSAGE; // 等会
//        return LocalTransactionState.ROLLBACK_MESSAGE; // 回滚
      }
    });
    Message message = new Message("tran-topic01", "事务消息测试".getBytes());
    transactionMQProducer.sendMessageInTransaction(message, null);
  }
}
```

## 重试机制

```javascript
// producer
   transactionMQProducer.setRetryTimesWhenSendFailed(3); // 同步发送 失败重试 默认2
    transactionMQProducer.setRetryTimesWhenSendAsyncFailed(3); // 异步发送 失败重试 默认2
    transactionMQProducer.setRetryAnotherBrokerWhenNotStoreOK(true); // 是否想其它broker发送请求，默认false
    transactionMQProducer.send(message, 6666L);

    consumer.setConsumeTimeout(2); // 消费超时 单位分钟
//    ConsumeConcurrentlyStatus.RECONSUME_LATER 发送ack消费失败

// broker
只有为集群模式，broker才会进行自动重试 默认使用
```

## 重复消费

幂等

- 数据库表：处理消息前，使用消息主键在表中带有约束字段的insert
- Map： 单机使用ConcurrentHashMap -> putIfAbsent -> guava cache
- redis操作 主键set操作

## 顺序消费

- 同一个topic 底层是queue
- 同一个queue写 
- 发消息一个线程有序发送消息
- 消费 一个线程消费一个queue
- 多个Queue只能保证单个Queue的顺序

```java
package rocketq.Transaction;

import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.List;
import org.apache.rocketmq.client.producer.DefaultMQProducer;
import org.apache.rocketmq.client.producer.LocalTransactionState;
import org.apache.rocketmq.client.producer.MessageQueueSelector;
import org.apache.rocketmq.client.producer.TransactionListener;
import org.apache.rocketmq.client.producer.TransactionMQProducer;
import org.apache.rocketmq.client.producer.selector.SelectMessageQueueByHash;
import org.apache.rocketmq.common.message.Message;
import org.apache.rocketmq.common.message.MessageExt;
import org.apache.rocketmq.common.message.MessageQueue;

/**
 * 顺序消费-发送者
 *
 * @author Alfred.Ning
 * @since 2023年09月09日 13:27:00
 */
public class Producer2 {

  public static void main(String[] args) throws Exception {
    DefaultMQProducer producer = new DefaultMQProducer("abc44");
    producer.setNamesrvAddr("localhost:9876");
    producer.start();
    Message message = new Message("q-topic01", "嘻嘻".getBytes());
    MessageQueueSelector queueSelector = new MessageQueueSelector() {

      @Override
      public MessageQueue select(
          List<MessageQueue> list, // 当前topic所有的queue
          Message message, //  消息
          Object args) { // send的args 2222
        // 固定queue
        return list.get((Integer) args);
      }
    };

    producer.send(message, queueSelector, 0, 6666);

    // 自带实现
    producer.send(message, new SelectMessageQueueByHash(), 1, 6666);
  }
}


```

```java
package rocketq.Transaction;

import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
import org.apache.rocketmq.client.consumer.listener.ConsumeOrderlyStatus;
import org.apache.rocketmq.client.consumer.listener.MessageListenerOrderly;
import org.apache.rocketmq.client.exception.MQClientException;
import org.apache.rocketmq.common.message.MessageExt;

/**
 * 顺序消费-消费者
 *
 * @author Alfred.Ning
 * @since 2023年09月09日 13:27:00
 */

public class Consume2 {

  public static void main(String[] args) throws MQClientException {
    DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("consumerGroup-2");
    consumer.setNamesrvAddr("localhost:9876");

    consumer.subscribe("q-topic01", "*");

    // MessageListenerConcurrently 并发消费
    // MessageListenerOrderly 顺序消费 一个Queue不会开启多线程 多个Queue开启多个现场 一个Queue对应多个线程

    // 最大线程数
//    consumer.setConsumeThreadMax();
//    consumer.setConsumeThreadMin();
    consumer.registerMessageListener((MessageListenerOrderly) (list, consumeOrderlyContext) -> {
      for (MessageExt msg : list) {
        System.out.println(new String(msg.getBody()));
      }
      return ConsumeOrderlyStatus.SUCCESS;
    });
    consumer.start();
  }

}
```

## 消息堆积处理

> 产生消息堆积的原因
>
> - 重启
> - consumer故障
>
> 堆积的消息会过期吗？ 不会 rocketmq对于单条消息没有ttl,只有commitlog过期，只有commitlog被删除消息才会消失
>
> 此时就算上线多个consumer短时间也无法处理
>
> 堆积的消息不会进入死信队列。消息在消费失败先进入重试队列，多次（默认16）才会进入死信队列
>
> 

- 大规模处理使用pull模式，控制消费速度
- 临时处理：新上线一个group,fromwhere定位到最后面，一一对等，让老的group消费老的，之后，会遇到重复消息，做好重复消费
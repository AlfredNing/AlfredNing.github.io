---
title: "GC日志分析"
date: 2023-05-04T22:36:26+08:00
lastmod: 2023-05-04T22:36:26+08:00
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

# GC日志参数

## -verbose:gc

输出gc日志信息，默认输出到标准输出

## -XX:+PrintGC

输出GC日志。类似：-verbose:gc

## -XX:+PrintGCDetails

在发生垃圾回收时打印内存回收详细的日志，

并在进程退出时输出当前内存各区域分配情况

## -XX:+PrintGCTimeStamps

输出GC发生时的时间戳

## -XX:+PrintGCDateStamps

输出GC发生时的时间戳（以日期的形式，如 2013-05-04T21:53:59.234+0800）

## -XX:+PrintHeapAtGC

每一次GC前和GC后，都打印堆信息

## -Xloggc:<file>

表示把GC日志写入到一个文件中去，而不是打印到标准输出中

# 测试代码

```java
import java.util.ArrayList;

/**
 * -Xms60m -Xmx60m -XX:SurvivorRatio=8 -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:./logs/gc.log
 *
 * @author Alfred.Ning
 * @since 2023年05月04日 22:54:00
 */
public class GLogTest {

  public static void main(String[] args) {
    ArrayList<byte[]> bytes = new ArrayList<>();

    for (int i = 0; i < 500; i++) {
      byte[] arr = new byte[1024 * 1024];
      bytes.add(arr);

      try {
        Thread.sleep(10);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
  }

}
```

# 在线分析GC日志代码

[gc日志分析在线](https://gceasy.io/)


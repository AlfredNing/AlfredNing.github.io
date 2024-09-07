---
title: "ORM框架设计"
date: 2024-09-07T14:59:46+08:00
lastmod: 2024-09-07T14:59:46+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- MySQL
tags: # 标签
- MySQL
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

# 经典的软件架构

1. 分层架构：经典的MVC
2. 事件驱动架构
3. 管道-过滤器架构
4. 微核架构：vsCode , idea 

# ORM的架构层次

1. 接口层：向上支持程序调用
2. 处理层：参数映射-> SQL生成 -> SQL执行 -> 结果处理
3. 支撑层：事务管理 连接池管理
4. 连接层： 数据库连接驱动

![image-20240907150455340](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20240907150455340.png)
---
title: "HTTP权威指南"
date: 2023-02-15T12:22:58+08:00
lastmod: 2023-02-15T12:22:58+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- http
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

# Web的基础

## HTTP概述

1. http使用的是可靠的数据传输协议

### 组成

#### web客户端

类似浏览器

#### web服务器：

通常web服务器使用http协议，通常成为http服务器

#### 资源

Web服务器是Web资源（Web resource）的宿主。Web资源是Web内容的源头。资源并不一定非的是静态文件，**根据需要生成的软件程序**

- html文件
- word文件
- 其它任何格式

##### 媒体类型

MIME类型(MIME TYPE) ： 数据格式标签，最初是用于解决在不同的电子邮件系统中之间搬移报文时候存在的问题，http借鉴了。weu服务器会为所有的http对象数据附近一个MIME类型（Content-Type,Content-Length)

##### URI

每一个web服务服务器资源名都有一个名字，被称为统一资源标识符(Uniform Resouce Identifier)，具有两种形式URL、URN

###### URL: 统一资源定位符

HTTP 协议 + 地址 + 某个资源

###### URN： 统一资源名

URN是作为特定内容的唯一名称使用的，与目前的资源所在地无关

### 事务
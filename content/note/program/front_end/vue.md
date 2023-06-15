---
title: "Vue"
date: 2023-06-01T00:55:03+08:00
lastmod: 2023-06-01T00:55:03+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- Vue
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

# 前介

构建用户界面的渐进式的框架

渐进式：可以在项目中一点点使用

## Vue3初识

### 命令式编程vs声明式编程

命令式编程：how to do

声明式编程：what to do . 由框架完成how 的部分

### MVVM模型

Model - View - ViewMode ： 软件架构模式

![image-20230615000635613](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615000635613.png)

### Vue Demo

```vue
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>

<body>
    <div id="app">

    </div>
    <!-- 这里的template 是html提供的，也可以换成div等，但是template是不显示 -->
    <template id="t1">
        <div>
            <h2>{{counter}}</h2>
            <button @click='increment'>+1</button>
            <button @click='decrement'>-1</button>
            <h3>{{message}}</h3>
        </div>
    </template>

    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <script>
        Vue.createApp({
            // 这里使用模板字符串
            template: '#t1',
            // vue3 data 函数
            data: function () {
                return {
                    message: "hello",
                    counter: 100
                }
            },
            methods: {
                increment() {
                    this.counter++;
                },
                decrement() {
                    this.counter--;
                },
            },
        }).mount('#app');
    </script>
</body>

</html>
```

#### template属性

1. 利用script写法
2. 利用template写法
3. 直接放置

#### data属性

- vue3: 传入一个函数，返回一个对象
- data返回对象会被vue响应系统劫持，之后对象的修改和访问都会被系统劫持

#### methods属性

一个对象，定义我们通用的方法。

**methods中定义函数，不建议用箭头函数。**

#### 其他属性

非常多

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

# 基础语法

> vs code代码快捷生成帮助网站https://snippet-generator.app/

## Mustche双括号

- 可以是表达式
- 可以调用函数 methods
- 三元运算符

## v-once

用户指定元素或者组件只渲染一次

- 数据发生变化，元素或者组件以及所有的子元素视为静态内容并且跳过
- 该指令用于性能优化
- 子节点，也只渲染一次

## v-text

很少使用

## v-html

内容本身是html，vue帮助解析

## v-pre

跳过元素和子元素的编译过程，显示原始的Mustache标签

跳过必须要编译的节点，加快编译

## v-cloak

编译组件结束之后取消该属性

## v-bind

属性动态绑定

缩写：`::`

绑定class属性

## v-on

绑定事件

缩写：@

- 可以绑定表达式: 内敛表达式
- 可以绑定对象
- 传递参数

![image-20230617184827223](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230617184827223.png)

## 条件渲染

- v-if: 惰性
- v-else-if
- v-else

## v- show

- v-show 不支持template

- v-show 不可以和v-else连用

v-show 是设置display: none属性 进行切换

v-if 不会渲染到dom上面

1. 开发频繁切换 v-show
2. 不会使用 v-if

## 列表渲染

v-for

![image-20230618212612904](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230618212612904.png)

key的作用：作用于diff元素

## computed 计算属性

包含响应式的复杂逻辑

methods调用也可以显示

计算属性是有缓存的，多次使用，只会执行一次。依赖数据会进行重新计算

## 计算属性的getter和setter

## 监听器Watch

代码逻辑中监听某个数据的变化

- 深度侦听
- 立即执行
- 监听对象的属性

## 表单和开发模式

v-model

可以绑定的元素

- input
- textArea
- checkbox
- radio
- select

可以跟修饰符

- lazy
- number
- trim

# 组件

1. 全局注册
2. 局部注册

组件名称：

- 多个单词，短横线分割，使用时候一样
- 驼峰。使用可以驼峰[**开发不推荐**]或者中划线

# Webpack

## 安装

```css
# 全局安装
npm install webpack webpack-cli -g
# 局部安装
npm install webpack webpack-cli -D
webpack --version

npm init
# 默认yes
npm init -y
# 安装依赖开发环境
npm install webpack webpack-cli  -D
# 使用项目本地依赖打包
npx webpack

# 引入配置文件
webpack.config.js

# css
css-loader style-loader
# less
less less-loader css-loader style-loader

# 工具css PostCss 进行转换或者postcss-preset-env
npm install postcss postcss-cli -D 

# 图片 打包 file-loader
npm install file-loader -D 
# webpack5 	
```

**webpack打包原理：是存在依赖图，凡是存在依赖都会把打包进去**

## 相关使用

webpack5之后提供资源模块类型

## 相关插件

- clean-webpack-plugin
- html-webpack-plugin
- define-plugin
- copy-webpack-plugin

## Babel

工具链，包括词法转换、源代码转换

可以作为独立工具，不和webpack构建工具单独使用，有基础的预设（preset)

### 底层原理

编译器的工作，本质就是一个编译器

工作流程：

1. 解析阶段 Parsing
2. 转换阶段 Transformation
3. 生成阶段 Code Generation

![image-20230714223717856](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230714223717856.png)

## vscode对SFC文件支持

- Vetur
- Volar
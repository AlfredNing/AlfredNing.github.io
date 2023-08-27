---
title: "Spring源码01"
date: 2023-07-24T14:42:20+08:00
lastmod: 2023-07-24T14:42:20+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- Spring
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

# 基本注解

## @Lookup

从容器中查找不同的实例，

```java
/**
 * @author Alfred.Ning
 * @since 2023年08月12日 20:27:00
 */
@Component
@Data
public class Person {

   private String name;

// @Autowired
   private Cat cat;

   @Lookup // 去容器里找
   public Cat getCat() {
      return cat;
   }
}

/**
 * @author Alfred.Ning
 * @since 2023年08月13日 14:42:00
 */
@Scope(scopeName = ConfigurableBeanFactory.SCOPE_PROTOTYPE)
@Component
@Data
public class Cat {
	private String name;

}
```

## Resource+ResourceLoader 

Resource:负责资源

ResourceLoader: 对应资源加载 ，策略模式。

## BeanFactory

容器的根节点，入口。

`HierarchicalBeanFactory`： 定义父子容器

`AutowireCapableBeanFactory`： 处理自动装配功能

`DefaultListableBeanFactory`： 内部所有Bean处理信息，所有组件

`GenericApplicationContext`： 用户使用

`AnnotationConfigApplicationContext`： 组合了自动装配能力

![image-20230821082502931](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230821082502931.png)

## BeanDefinition

## BeanDefinitionReader

## BeanDefinitionRegistry

## ApplicationContext

## Aware

## BeanFactoryPostProcessor

## InitializingBean

## BeanPostProcessor

# Spring整体流程

![Spring架构原理图](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/Spring%E6%9E%B6%E6%9E%84%E5%8E%9F%E7%90%86%E5%9B%BE.jpg)

## BeanDefinition注册流程（类如何加载在Spring当中）

![image-20230827153509780](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230827153509780.png)

## Aware接口

> 使用到sping组件,使用XXXAware接口直接获取
>
> 实现方式是利用回调，传入组件（ioc容器）

### 第一种方式 组件中注入IOC容器

![image-20230827160029843](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230827160029843.png)

###  第二种方式 实现ApplicationContextAware

![image-20230827160432579](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230827160432579.png)

### Aware接口实现原理

例如`ApplicationContextAware`有一个ApplicationContextAwareProcessor 实现了BeanPostProcessor接口，执行Aware固定的接口

```java
// 所有的aware接口
public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
		if (!(bean instanceof EnvironmentAware || bean instanceof EmbeddedValueResolverAware ||
				bean instanceof ResourceLoaderAware || bean instanceof ApplicationEventPublisherAware ||
				bean instanceof MessageSourceAware || bean instanceof ApplicationContextAware ||
				bean instanceof ApplicationStartupAware)) {
			return bean;
		}
	
```

**Bean的功能增强 BeanPostProcessor + InitializingBean**
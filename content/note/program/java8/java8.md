---
title: "Java8"
date: 2023-02-18T12:47:59+08:00
lastmod: 2023-02-18T12:47:59+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- java8
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

# 新特性

- lambda表达式
- 方法引用
- 函数接口
- 流式处理
- 新日期时间API
- Optional类
- 新工具、JavaScript执行引擎
- javaFx

# 函数编程

### lambda表达式

- 想要在代码块以后某个时间点执行
- 可以转换为函数式接口
- 闭包作用域中有效访问final变量
- 任何一个lambda表达式都可以转换为所使用API中对应的函数式接口，注意：lambda表达式转换为函数式接口时候，注意检查期异常
- 不允许声明一个与局部变量同名的参数或者局部变量
- lambda使用this,创建该lambda表达式方法的参数

### 组成

- 可选的类型声明
- 可选的参数小括号
- 可选的大括号
- 可选的返回值【只有一句表达式可以省略】

### 功能

内联功能的实现

### 注意

变量引用不可变，实际内容可变

### 函数接口

只包含一个抽象方法的接口，可以通过lambda表达式创建该接口的对象

### 方法引用

>方法引用用其名称指向方法

引用符号::
指向方法

- 对象::实例方法
- 类:: 静态方法
- 类::实例方法（第一个参数会成为执行方法的对象)

### 构造器引用

类::new

java中无法构造一个泛型类型T的数组，但可以通过数组引用解决。

例如：stream.toArray(Class::new)

### 默认方法

类优先原则

接口中有一个默认方法，一个类也有同名的方法。另一个类继承了父类，实现了该接口。这种情况下，只有父类的方法会起作用。 出于兼容性，这样在接口中添加方法，不会对以前的编写的代码产生影响。不**能对Object的方法定义默认方法**

###  静态方法

为接口添加静态方法

# Stream API

> 原则：做什么，而不是怎么做

- Stream不会自己存储元素。元素可能被存储在底层的集合当中，或者根据需要产生出来
- Stream操作符不会改变源对象的。相反，他们会返回一个持有结果的新Stream
- Stream操作符可能是延迟执行的。意味着他们等到需要结果的时候才执行

## Stream使用三阶段

1. 创建Stream
2. 中间操作
3. 终止操作产生结果

### 创建Stream

1. Stream.of()
   ![image-20230218144721628](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230218144721628.png)

2. Arrays.Stream 可选长度参数
3. 空Stream: Stream.Empty()
4. Stream.generate(Supplier func);
5. Stream.iterate(seed, operator)
6. Pattern类的splitAsStream
7. Files.lines(path) : 记得使用try-with-resources语句

### 中间操作

> 注意null对象

#### filter map  flatMap

##### filter

过滤操作，满足true的保留

参数：Predicate<T>对象

T => Boolean函数

##### map

对流中的每一个元素进行应用一个函数，将返回的值收集到一个新流当中

##### flatMap

多流展开流

flatMap属于计算机科学中的一个基本概念。假设有一个G(例如Stream)和两个函数，从T到G(U)的f函数和从U到G(U)的g方法。通过flatMap,先应用f函数，再应用g函数。 

#### 提取子流和组合流

##### limit

裁剪指定长度的流

##### skip

丢弃前面的n个元素

##### Stream.concat

将两个流连接起来

##### peek

产生与另一个原始具有相同元素的流，每次提取元素的时候，都会调用一个函数

#### 有状态的转换

##### distinct

必须记住之前已经读取的元素

##### sorted

遍历整个流，进行排序

> Collection.sort方法对原有的集合进行排序，而Stream.sorted方法会返回一个新的已排序的流

### 终止操作

#### 聚合方法

- count
- max
- min
- findFirst
- findAny:找到第一个出现的元素就结束
- anyMatch:是否有匹配的元素
- allMatch: 所有元素匹配，并行执行提高速度
- noneMatch: 所有元素不进行匹配，并行执行提高速度
- reduce

forEach: 保证传入函数并发执行

forEachOrdered： 按照流的顺序执行访问

**注意返回值Optional**

### Optional类型

使用一个或者接受正确值，或者返回另一个替代值的方法

##### ifPresent

接受一个函数，存在可选值，将值传递给函数。不会返回任何值，如果希望操作，调用map方法

##### orElse

不存在值产生一个替代值

##### orElseGet

计算默认值

##### orElseThrow

没有值的时候抛出异常

#### 创建可选值

Optional.of

Optional.empty

##### Optiona.ofNullable

对象不为空，返回Optional.of,否则返回Optional.empty()

#### 使用flatmap组合可选值函数

一个方法f返回Optional<T>， 目标类型有一个返回Optional<U>的方法g, 调用s.f().g()不能操作，如果s.f()存在执行g()。多次调用flatMap实现

### 收集结果

#### 收集到集合

- iterator

- toArray

- collect
  使用Collectiors类

  - 一个能创建目标类型的实例方法
  - 一个元素添加到目标中的方法
  - 一个将两个对象整合到一起的方法

  ```java
  public static void main(String[] args) {
    Stream<Integer> stream = Stream.iterate(10, v -> v + 1).limit(20);
    stream.forEach(System.out::println);
    // toList
    List<Integer> list = stream.collect(Collectors.toList());
    Set<Integer> set1 = stream.collect(Collectors.toSet());
    // 排序的set
    TreeSet<Integer> treeSet = stream.collect(Collectors.toCollection(TreeSet::new));
    // 字符串拼接
    String str = stream.map(Object::toString).collect(Collectors.joining("; "));
    // 总和 平均值 最大值 最小值summarizing类型
    DoubleSummaryStatistics summaryStatistics = stream.collect(
        Collectors.summarizingDouble(Integer::intValue));
    summaryStatistics.getAverage();
    summaryStatistics.getCount();
    summaryStatistics.getSum(); // .......
  }
  ```

#### 收集到map

Collectors.toMap(键函数，值函数，键冲突函数)

Function.identity(). 实际的元素

**如果多个元素拥有相同的键，抛出IllegalStateException异常。传入键冲突函数。返回已有值，新值、两者都返回**

如果希望返回TreeMap，传入第四个函数。

![image-20230219145450059](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219145450059.png)

对于toMap的方法都有对应toConcurentMap方法

### 分组和切片

- groupingBy
- partitioningBy

partitioningBy 效率大于groupingBy

传入第二个参数设置downStream

- counting
- summingXXX
- maxBy minBy

![image-20230219150349105](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219150349105.png)

### 原始类型流

IntStream => short char byte boolean int

DoubleStream => float double

### 并行流

默认情况下，流操作是创建一个串行流。Collection.parallelStream()方法除外。

parallel方法可以将任意的串行流转换为一个并行流 

确保传递给并行流的函数都是线程安全的

# 日期时间

### 瞬时时间-Instant

### 时间间隔-Duration

- toNacos
- toMillis
- toSeconds
- toMinuters
- toHours
- toDays

![image-20230219161701168](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219161701168.png)

![image-20230219161750101](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219161750101.png)

### 本地日期

- 本地日期/时间

  - LocalDate 年月日日期

    ![image-20230219162127004](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219162127004.png)

  - 时段：Period

  - 日期矫正器：TemporalAdjusters

  - 本地时间：LocalTime

  - 本地日期和时间：LocalDateTime

- 带时区的时间

  - 获取所有时区：ZoneId.getAvailableZoneIds()
  - 返回时区：Zone.id(id)
  - 日期转带有时区的：local.atZone();
  - 带有偏移量的时间：OffsetDateTime

### 格式化和解析

#### 预定义的标准格式

![image-20230219172546386](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219172546386.png)

![image-20230219172555022](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219172555022.png)

```java
String format = DateTimeFormatter.ISO_DATE.format(LocalDateTime.now());
System.out.println(format);
```

#### 语言相关的格式化风格

![image-20230219172626463](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219172626463.png)

```java
String format1 = DateTimeFormatter.ofLocalizedDateTime(FormatStyle.LONG)
    .format(ZonedDateTime.now());
System.out.println(format1);
// 更改语言环境使用withLocale方法
```

#### 自定义格式

![image-20230219173536027](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219173536027.png)

```java
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyy-MM-dd HH:mm:ss");
System.out.println(formatter.format(LocalDateTime.now()));
```

### 与之前日期时间的交互

Instant类似java.util.Date类

java.util.Date增加了两个方法：toInstant 和format方法

![image-20230219173738624](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219173738624.png)

![image-20230219173752373](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230219173752373.png)

# 其他增强内容

## 字符串

多个字符串组合起来，String.join

## 数字类

Short/Integer/Long/Float/Double提供了静态方法sum/max/min,用来流操作中作为聚合函数使用

Boolean提供logicalAnd / logicalAndor / logicalXor

Interger支持无符号运算

Byte Short新增toUnsignedInt方法

Byte Short Integer 新增了toUnsignedLong 方法

Float Double 新增isFinite

BigInteger新增实例方法（long|int|short|byte)ValueExtract，返回基本类型，不在目标范围时返回ArithmeticException

## 新的数学函数

算术计算：(add | subtract | multiply | increment | decrement | negate)Extract 

将long值转换为等价的Int值： toIntExtract

整数余数问题：floorMod floorDiv 

## 集合

Collection接口加入removeIf

List接口 加入replaceAll ， sort方法

Iterator接口forEachRemaining：将剩余元素传递给一个函数

比较器

comparing/thenComparing

键函数返回null, 使用nullFirst或者nullLast

Collections

- checkQueue
- emptySorted()

## 文件

1. 读取文件行的流

   Files.lines : 默认UTF-8 , 配合使用**try-with-resources**

2. 遍历目录项
   Files.list : 不会进入子目录

   Files.walk: 会进入子目录，可以限制深度

## Base64编码

## null检查

Objects.isNull 和nonNull 配合流使用

## 正则表达式

引用命名捕获组

## 语言环境

Locale.getAvailableLocales()

## jdbc

java.sql包下的Date/Time/TimeStamp提供方法和本地日期时间进行转化

Statement类新增executeLargeUpdate方法

# java7的一些特性

1. try-with-resources： 前提实现AutoCloseable接口
2. 忽略异常：ex.addSuppressed(exception)
3. 捕获多个异常
4. 反射异常：ReflectiveOperationException
5. 使用文件
   1. 使用Path类
   2. 使用Files类
6. 使用Objects
   1. equals方法
   2. hash方法
7. URLClassLoader
8. BitSet构造增强、java8可以通过BitSet返回IntStream

> 未补充
>
> - JavaFX
> - java8的并发增强




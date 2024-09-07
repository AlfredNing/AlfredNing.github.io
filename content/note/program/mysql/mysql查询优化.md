---
title: "MySQL查询优化"
date: 2024-09-07T09:25:42+08:00
lastmod: 2024-09-07T09:25:42+08:00
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

# 一个SQL是如何执行的

![image-20240907110600002](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20240907110600002.png)

查询缓存：

1. 执行查询过得语句先缓存
2. 推荐使用缓存：数据表修改后，会删除所有缓存相关的。Mysql8 去掉缓存

分析器：

1. 知道干什么
2. 词法分析
3. 句法分析

优化器：

1. 优化器的作用知道是怎么做
2. 决定如何使用索引

执行器：

1.  校验权限，调用存储引擎
2. 没有索引情况，执行器会查询所有行

# 索引组织表

索引：数据库中对某一列或者多个列的值进行预排序的数据结构

主键：非空唯一索引；不指定主键，与声明顺序有关

## 主流索引查找

- 线性查找
- 二分查找
- 二叉查找树
- 平衡二叉树
- B树
- B+树

二叉树特殊情况下，可以退化成链表，所有引入了平衡二叉树，通过旋转的方式，保证子树间的高度。二叉树明显的缺点是每个节点存储的数据太少。硬盘按块（默认4k）读取

### B树

叶子存储多节点，多数据节点降低树的高度。

### B+树

叶子间通过链表相连。只有叶子存储数据

高度一般为2-4层，查找速度快

Innodb采用B+树结构

## 聚簇索引

- 根据表的主键构造B+树

- 数据和索引放在一起
- 叶子节点之间存放数据，而不是指针

![image-20240907113117801](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20240907113117801.png)

## 辅助索引

- 叶子节点不包含数据，存储主键

## Innodb存储逻辑结构

![image-20240907113804595](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20240907113804595.png)

## 数据记录格式

![image-20240907114632016](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20240907114632016.png)

![image-20240907114643640](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20240907114643640.png)

![image-20240907114659037](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20240907114659037.png)

## 索引建立

1. 联合索引：最左前缀，“带头大哥不能死，中间兄弟不能丢”
2. 字符串的前缀索引：字符串过长，使用前缀索引节约空间； 
   1. 前缀区分度太小：倒序存储，取的时候反向存储
   2. 新建hash字段
3. 字符串like:
   1. 全模糊：“%like%” 索引失效
   2. 右模糊："%like" 索引失效
   3. 左模糊才可以使用索引

# 查询优化

## 覆盖索引

1. 取消回表操作，提高查询性能
2. 数据的查询不只使用到了一个索引，则不是覆盖索引
3. 优化sql语句或者优化联合索引，来使用覆盖索引

## 有更合适的索引不走

### Mysql索引的选择-基于基数

参考索引的基数

1. 反应字段有多少种取值
2. 选取几个页中取值的平均值，在乘以页数，则为基数

查看索引

`show index from tableName`

![image-20240907120443615](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20240907120443615.png)

区分度越大，mysql最可能选取

### 解决措施: 强制使用索引

- `force index` 强制使用索引
- 优化索引，让mysql重新统计索引 `analyze table` 会重新统计索引基数

## count比较慢

count：统计结果集合不为null的数据个数

1. 存储引擎查询结果集
2. server层逐个结果判断是否为null, 不为null则加1

**count(非索引字段)**：理论上是最慢

**count(索引字段)**： 覆盖索引，但是server需要引擎判断

**count(主键)**： server仍然需要引擎判断

**count(1)**：只扫描索引树，没有解析数据行的过程，**理论是更快**，但是server层仍然每次需要判断“1是否为null"

**count(*)**：一般用来返回数据表行数，MyIsam直接返回数据表行数，直接返回索引树中数据的个数

## order by比较慢

### order by执行过程

1. 根据where条件查询
2. 将查询结果放入sort_buffer
3. 对中间结果集按照order by 字段排序
4. 需要的情况下回表生成完整结果集合

中间结果集：

- 中间表小的时候，直接放在内存
- 中间表大于`sort_buffer_size`, 放入磁盘
- 优化内存占用，减少`sort_buffer_size`
- 优化排序时间，增大`sort_buffer_size`

回表生成完整结果集：

- 当行小于`max_length_for_sort_data` 生成全字段中间结果表
- 大于阈值，只生成排序字段+中间结果表，需要回表
- 调大阈值不一定改善效率，因为结果集排序效率低

**索引覆盖**

- 跳过生成中间结果集，直接输出查询结果
- order 字段需要有索引，或在联合索引的左侧
- 其他相关字段(条件，输出)都在上述的索引中

## 随机选取比较慢

rand(): 0-1直接随机值

### rand执行过程

```sql
select A, B from test order by rand() limit 1
```

1. 创建一个临时表，临时表字段为A,B
2. 从表中取出一行，调用rand()， 将结果和数据放入临时表
3. 针对临时表，将rand+行位置放入sort_buffer
4. 对sort_buffer排序，取出第一个位置主键，查询临时表

慢的原因：

1. sql执行过程中，出现了两次中间结果
2. 需要一个优化结果，但又排序
3. 调用了很多次的rand

### 解决方案

#### 临时方案

```sql
select max(id), min(id) into @M, @N from test;
set @X = floor((@M - @N + 1) * rand() + @N);
select A, B from test  where id > @X limit 1;
```

#### 业务方案

1. 查询数据表总数total

2. total范围内，随机选取一个数字r

3. 执行sql
   ```sql
   select A,B from test limit r, 1
   ```

## 索引下推

> explain Extra中 ： use index condition

使用索引先过滤再次回表查询

## 松散索引扫描

Mysql 8.0 特性

## 函数放弃索引的情况

MySQL中，对索引字段做函数操作，优化器放弃索引

- 时间函数
- 字符串转数字
- 字符编码转换

### 解决方案

1. 时间函数转区间(between and)
2. 数字强转字符串
3. 高级编码转低级

## 分页查询慢

1. 偏移量大时，效率低

### 分页原理

- 先执行条件部分，在执行分页逻辑limit之后
- 丢弃很多无用的数据，效率低下

### 优化思路

- 走覆盖索引
  - 得到数据Id
  - 根据数据Id，得到最终结果集

```sql
selec A,B,C from test order by B limit 900,10;
-- 数据库只有c索引; A是主键
改进后
select t1.A, t1.B, t1.C from test t1
inner join (select A from test t2 order by B limit 900, 10) t2
on t1.A = t2.A
```


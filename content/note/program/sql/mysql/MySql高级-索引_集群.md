---
title: "MySql高级 索引_集群"
date: 2023-06-04T11:20:59+08:00
lastmod: 2023-06-04T11:20:59+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
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

# 索引

## 索引的分类

1. 从功能逻辑划分
   - 普通索引
   - 唯一索引
   - 主键索引
   - 全文索引
2. 从物理实现方法划分
   - 聚簇索引
   - 非聚簇索引
3. 从作用字段划分
   - 单列索引
   - 联合索引

InnoDB: 支持B-Tree，FullText索引，不支持Hash索引

MyISAM: 支持B-Tree，FullText索引，不支持Hash索引

Memory: 支持B-Tree，Hash索引，不支持FullText索引

NDB: 支持Hash索引，不支持 B-Tree, FullText索引

Archive: 不支持 B-Tree, FullText,Hash索引

## 创建索引

### 方式1- 创建表时候指定

1. 普通索引

```sql
CREATE TABLE book( 
    book_id INT , 
    book_name VARCHAR(100), 
    authors VARCHAR(100), 
    info VARCHAR(100) , 
    comment VARCHAR(100), 
    year_publication YEAR, 
    INDEX(year_publication) 
);
```

2. 创建唯一索引

```sql
CREATE TABLE test1( 
    id INT NOT NULL, 
    name varchar(30) NOT NULL, 
    UNIQUE INDEX uk_idx_id(id) 
);
```

3. 主键索引

```sql
CREATE TABLE student ( 
    id INT(10) UNSIGNED AUTO_INCREMENT, 
    student_no VARCHAR(200),
    student_name VARCHAR(200), 
    PRIMARY KEY(id) 
);

# 删除主键索引
ALTER TABLE student drop PRIMARY KEY ;
```

4. 创建单列索引

```sql
CREATE TABLE test2( 
    id INT NOT NULL, 
    name CHAR(50) NULL, 
    INDEX single_idx_name(name(20)) 
);
```

5. 创建组合索引

```sql
CREATE TABLE test3( 
    id INT(11) NOT NULL, 
    name CHAR(30) NOT NULL, 
    age INT(11) NOT NULL, 
    info VARCHAR(255), 
    INDEX multi_idx(id,name,age) 
);
```

6. 全文索引

```sql
CREATE TABLE `papers` ( 
    id` int(10) unsigned NOT NULL AUTO_INCREMENT, 
    `title` varchar(200) DEFAULT NULL, 
    `content` text, PRIMARY KEY (`id`), 
    FULLTEXT KEY `title` (`title`,`content`) 
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

SELECT * FROM papers WHERE MATCH(title,content) AGAINST (‘查询字符串’);
```

7. 空间索引

```sql
CREATE TABLE test5( 
    geo GEOMETRY NOT NULL, 
    SPATIAL INDEX spa_idx_geo(geo) 
) ENGINE=MyISAM;
```



### 方式2-已经创建表上的添加

1. alter 形式

```sql
ALTER TABLE table_name 
ADD [UNIQUE | FULLTEXT | SPATIAL] [INDEX | KEY] [index_name] (col_name[length],...) [ASC | DESC]
```

2. create 形式

```sql
CREATE [UNIQUE | FULLTEXT | SPATIAL] INDEX index_name 
ON table_name (col_name[length],...) [ASC | DESC]
```

### 删除索引-alter

```sql
ALTER TABLE table_name DROP INDEX index_name;
```

删除索引-drop

```sql
DROP INDEX index_name ON table_name;
```

**添加Auto_Increment约束字段的唯一索引不能被删除**

## MySQL8.0 - 新特性

### 降序索引

```sql
CREATE TABLE ts1(a int,b int,index idx_a_b(a,b desc));
```

对InnoDB而言是支持的，Mysql之前是升序索引

### 隐藏索引

```sql
-- 创建表时候指定
CREATE TABLE tablename( 
    propname1 type1[CONSTRAINT1], 
    propname2 type2[CONSTRAINT2], 
    ……
    propnamen typen, 
    INDEX [indexname](propname1 [(length)]) INVISIBLE 
);
-- 已经创建表的指定
CREATE INDEX indexname ON tablename(propname[(length)]) INVISIBLE;
-- alter table 指定
ALTER TABLE tablename ADD INDEX indexname (propname [(length)]) INVISIBLE;
-- 切换隐藏索引状态
ALTER TABLE tablename ALTER INDEX index_name INVISIBLE; #切换成隐藏索引 
ALTER TABLE tablename ALTER INDEX index_name VISIBLE; #切换成非隐藏索引

-- 是隐藏索引对查询优化器可见设置
-- 1. 查看优化器设置
select @@optimizer_switch
set session optimizer_switch="use_invisible_indexes=on" -- 开启

```

## 索引的设计原则

### 哪些情况适合创建索引

#### 1. 字段的数值有唯一的限制

索引本身可以起到约束的作用，比如唯一索引、主键索引都可以起到唯一性约束的，因此在我们的数据表中，如果`某个字段是唯一的`，就可以直接`创建唯一性索引`，或者`主键索引`。这样可以更快速地通过该索引来确定某条记录

> 业务上具有唯一特性的字段，即使是组合字段，也必须建成唯一索引。（来源：Alibaba）
>
> 说明：不要以为唯一索引影响了insert速度，这个速度损耗可以忽略，但提高查找速度是明显的。

#### 2. 经常性作为where条件查询的字段

某个字段在SELECT语句的 WHERE 条件中经常被使用到，那么就需要给这个字段创建索引了。尤其是在数据量大的情况下，创建普通索引就可以大幅提升数据查询的效率

#### 3. 经常group by 和order by 的列

如果只是group by 或者order by单列字段，建立单列索引。

如果既有group by 也有order by 建立联合索引

#### 4. UPDATE、DELETE **的** **WHERE** **条件列**

对数据按照某个条件进行查询后再进行 UPDATE 或 DELETE 的操作，如果对 WHERE 字段创建了索引，就能大幅提升效率。原理是因为我们需要先根据 WHERE 条件列检索出来这条记录，然后再对它进行更新或删除。**如果进行更新的时候，更新的字段是非索引字段，提升的效率会更明显，这是因为非索引字段更新不需要对索引进行维护。**

#### 5. DISTINCT字段需要创建索引

有时候我们需要对某个字段进行去重，使用 DISTINCT，那么对这个字段创建索引，也会提升查询效率。

#### 6. 多表创建索引注意事项

首先，`连接表的数量尽量不要超过 3 张`，因为每增加一张表就相当于增加了一次嵌套的循环，数量级增长会非常快，严重影响查询的效率。

其次，`对 WHERE 条件创建索引`，因为 WHERE 才是对数据条件的过滤。如果在数据量非常大的情况下，没有 WHERE 条件过滤是非常可怕的。

最后，`对用于连接的字段创建索引`，并且该字段在多张表中的`类型必须一致`。*虽然这里能查询，但存在隐式转换，使用到了函数*

#### 7. 使用列的类型小的创建索引

这里所说的`类型大小`指的就是该类型表示的数据范围的大小。

- 数据类型越小，在查询时进行的比较操作越快
- 数据类型越小，索引占用的存储空间就越少，在一个数据页内就可以`放下更多的记录`，从而减少磁盘`I/O`带来的性能损耗，也就意味着可以把更多的数据页缓存在内存中，从而加快读写效率。

这个建议对于表的`主键来说更加适用`，因为不仅是聚簇索引中会存储主键值，其他所有的二级索引的节点处都会存储一份记录的主键值，如果主键使用更小的数据类型，也就意味着节省更多的存储空间和更高效的I/O。

#### 8. 使用字符串前缀创建索引

计算公式

```sql
select count(distinct left(列名, 索引长度))/count(*) from table_name; --比值越接近1越好
-- 尝试
select count(distinct left(列名, 10))/count(*) as sub10 from table_name; 
select count(distinct left(列名, 15))/count(*) as sub15 from table_name; 
select count(distinct left(列名, 20))/count(*) as sub20 from table_name; 
select count(distinct left(列名, 25))/count(*) as sub25 from table_name; 
```

> Alibaba《Java开发手册》
>
> 【`强制`】在 varchar 字段上建立索引时，必须指定索引长度，没必要对全字段建立索引，根据实际文本区分度决定索引长度。
>
> 说明：索引的长度与区分度是一对矛盾体，一般对字符串类型数据，长度为 20 的索引，区分度会`高达 90% 以上`

###### 索引类前缀对排序的影响

**使用了索引列前缀的方式无法支持使用索引排序，只能使用文件排序，可能造成排序结果有偏差**

#### 9. 区分度高(散列性高)的列适合作为索引

`列的基数`指的是某一列中不重复数据的个数，比方说某个列包含值`2,5,8,2,5,8,2,5,8`，虽然有`9`条记录，但该列的基数却是`3`。也就是说，**在记录行数一定的情况下，列的基数越大，该列中的值越分散；列的基数越小，该列中的值越集中。**这个列的基数指标非常重要，直接影响我们是否能有效的利用索引。最好为列的基数大的列建立索引，为基数太小的列建立索引效果可能不好。

可以使用公式`select count(distinct a)/count(*) from t1`计算区分度，越接近1越好，一般超过`33%`就算是比较高效的索引了。

拓展：联合索引把区分度高（散列性高）的列放在前面。

#### 10. 使用最频繁的列放到联合索引的左侧

最左前缀匹配原则

#### 10. 在多个字段都要创建索引的情况下，联合索引优于单值索引

### 索引的数量限制

在实际工作中，我们也需要注意平衡，索引的数目不是越多越好。我们需要限制每张表上的索引数量，建议单张表索引数量`不超过6个`。原因：

- 每个索引都需要占用`磁盘空间`，索引越多，需要的磁盘空间就越大。
- 索引会影响`INSERT、DELETE、UPDATE等语句的性能`，因为表中的数据更改的同时，索引也会进行调整和更新，会造成负担。
- 优化器在选择如何优化查询时，会根据统一信息，对每一个可以用到的`索引来进行评估`，以生成出一个最好的执行计划，如果同时有很多个索引都可以用于查询，会增加MySQL优化器生成执行计划时间，**降低查询性能**。


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


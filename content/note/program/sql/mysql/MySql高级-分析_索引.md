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

### 不适合创建索引的情况

#### 1. 在where,groupby orderby 使用不到的字段不需要创建

#### 2. 数据量小的表不要使用索引

#### 3. 有大量重复数据的列上不要创建索引

> 当数据重复度 大于10%，不需要创建索引

#### 4. 避免对经常更新的表创建过多的索引

1. 频繁更新的字段不一定要创建索引
2. 对经常更新的表避免创建过多的索引

#### 5. 不建议用无序的值作为索引

身份证，uuid(索引比较时候转换为ASCII, 并且插入时可能造成页分裂，md5, hash，无序列长字符串)

#### 6. 删除不再使用或者使用很少的索引

#### 7. 不要定义冗余或者重复的索引

冗余索引：联合索引含有的字段，有定义了单列索引

重复索引

# 性能分析工具

## 数据库优化步骤

![2](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/2.jpg)

## 查看系统参数

```sql
show [global | session] status like '参数名'

```

![image-20230605204006975](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230605204006975.png)

### 统计SQL的查询成本

```sql
SHOW STATUS LIKE 'last_query_cost';
```

使用场景：它对于比较开销是非常有用的，特别是我们有好几种查询方式可选的时候。

> SQL 查询是一个动态的过程，从页加载的角度来看，我们可以得到以下两点结论：
>
> 1. `位置决定效率`。如果页就在数据库`缓冲池`中，那么效率是最高的，否则还需要从`内存`或者`磁盘`中进行读取，当然针对单个页的读取来说，如果页存在于内存中，会比在磁盘中读取效率高很多。
> 2. `批量决定效率`。如果我们从磁盘中对单一页进行随机读，那么效率是很低的（差不多10ms），而采用顺序读取的方式，批量对页进行读取，平均一页的读取效率就会提升很多，甚至要快于单个页面在内存中的随机读取。
>
> 所以说，遇到I/O并不用担心，方法找对了，效率还是很高的。我们首先要考虑数据存放的位置，如果是经常使用的数据就要尽量放到`缓冲池`中，其次我们可以充分利用磁盘的吞吐能力，一次性批量读取数据，这样单个页的读取效率也就得到了提升。

## 定位慢SQL

### 1. 开启慢查询日志参数

```sql
set global slow_query_log='ON';
# 查看 慢日志文件位置
show variables like `%slow_query_log%`;
```

### 2. 修改long_query_time阈值

```sql
# 该参数设置之后，仅对新连接的会话有效
set global long_query_time = 1; 
show global variables like '%long_query_time%'; 
# 对当前会话生效
set long_query_time=1; 
show variables like '%long_query_time%';
# 如果一直生效的话
该配置文件，重启
```

### 3. 查看慢查询数目

```sql
SHOW GLOBAL STATUS LIKE '%Slow_queries%';
```

### 4. 慢查询日志分析工具  mysqldumpslow

```sql
#得到返回记录集最多的10个SQL 
mysqldumpslow -s r -t 10 /var/lib/mysql/mysql-log.log 
#得到访问次数最多的10个SQL 
mysqldumpslow -s c -t 10 /var/lib/mysql/mysql-log.log
#得到按照时间排序的前10条里面含有左连接的查询语句 
mysqldumpslow -s t -t 10 -g "left join" /var/lib/mysql/mysql-log.log 
#另外建议在使用这些命令时结合 | 和more 使用 ，否则有可能出现爆屏情况 
mysqldumpslow -s r -t 10 /var/lib/mysql/mysql-log | more

```

### 5. 关闭慢查询日志

开发当中，如果不涉及调优尽量关闭

1. 永久关闭

   ```sql
   [mysqld] 
   slow_query_log=OFF
   #或
   [mysqld] 
   #slow_query_log =OFF
   重启服务器
   ```

2. 临时关闭

   ```sql
   SET GLOBAL slow_query_log=off;
   ```

## 查看SQL执行成本  - profiling

```sql
show variables like 'profiling';
#开启
set profiling = 'ON';
#查看
show profiles;
show profile cpu,block io for query 2;
```

**profiling 常用参数**

![image-20230605214559754](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230605214559754.png)

**日常开发注意点：**

1. convert heap to MyISAM: 查询结果太大，内存不够，落盘
2. Creating tmp table: 创建临时表。先拷贝数据到临时表，用完后在删除临时表
3. Coping to tmp table on disk: 把内存中临时表复制到磁盘上
4. locked

**如果在show profile诊断结果中出现了以上4条结果中的任何一条，则sql语句需要优化**

*注意：show profile 命令将弃用，可以从information_schema中的profiling数据表进行查看*

## 分析查询语句  EXPLAIN

```sql
EXPLAIN SELECT select_options 
#或者
DESCRIBE SELECT select_options
```

EXPLAIN 语句输出的各个列的作用如下：

| 列名          | 描述                                                     |
| ------------- | -------------------------------------------------------- |
| id            | 在一个大的查询语句中每个SELECT关键字都对应一个`唯一的id` |
| select_type   | SELECT关键字对应的那个查询的类型                         |
| table         | 表名                                                     |
| partitions    | 匹配的分区信息                                           |
| type          | 针对单表的访问方法                                       |
| possible_keys | 可能用到的索引                                           |
| key           | 实际上使用的索引                                         |
| key_len       | 实际使用到的索引长度                                     |
| ref           | 当使用索引列等值查询时，与索引列进行等值匹配的对象信息   |
| rows          | 预估的需要读取的记录条数                                 |
| filtered      | 某个表经过搜索条件过滤后剩余记录条数的百分比             |
| Extra         | 一些额外的信息                                           |

### Explain各列作用

#### 1. table

记录查询时候的表名，MySQL规定**EXPLAIN语句输出的每条记录都对应着某个单表的访问方法**，有时候不是真实的名字，可能是简称。排在前面的是驱动表，排在后面的是被驱动表

#### 2. id

在一个大的查询每个select 关键字对应一个id, 但并不是绝对。SQL优化器会帮我们优化。

- **id如果相同，可以认为是一组，从上往下顺序执行**
- **在所有组中，id值越大，优先级越高，越先执行**
- **关注点：id号每个号码，表示一趟独立的查询,一个sql的查询趟数越少越好**

#### 3. select type

MySQL为每一个SELECT关键字代表的小查询都定义了select_type属性。表示这小查询在大查询里面扮演着什么角色。

| select type          | 描述                                                         |
| -------------------- | ------------------------------------------------------------ |
| SIMPLE               | 简单的SELECT语句（不包括[UNION](https://so.csdn.net/so/search?q=UNION&spm=1001.2101.3001.7020)操作或子查询操作） |
| PRIMARY              | 查询中最外层的SELECT（如两表做UNION或者存在子查询的外层的表操作为PRIMARY，内层的操作为UNION） |
| UNION                | UNION操作中，查询中处于内层的SELECT（内层的SELECT语句与外层的SELECT语句没有依赖关系） |
| DEPENDENT UNION      | UNION操作中，查询中处于内层的SELECT（内层的SELECT语句与外层的SELECT语句有依赖关系） 相关子查询 |
| UNION RESULT         | UNION操作的结果，id值通常为NULL                              |
| SUBQUERY             | 子查询中首个SELECT（如果有多个子查询存在）                   |
| DEPENDENT SUBQUERY   | 子查询中首个SELECT，但依赖于外层的表（如果有多个子查询存在） |
| DERIVED              | 被驱动的SELECT子查询（子查询位于FROM子句）                   |
| MATERIALIZED         | 被物化的子查询                                               |
| UNCACHEABLE SUBQUERY | 对于外层的主表，子查询不可被物化，每次都需要计算（耗时操作） |
| UNCACHEABLE UNION    | UNION操作中，内层的不可被物化的子查询（类似于UNCACHEABLE SUBQUERY） |

#### 4. partitions

代表分区的命中情况，非分区表，该项为null

#### 5. type - 关键点

**结果值从最好到最坏依次是：** **system > const > eq_ref > ref** **> fulltext > ref_or_null > index_merge > unique_subquery > index_subquery >** **range > index > ALL** 

**SQL性能优化的目标：至少要达到 range级别，要求是ref级别，最好是consts级别。**

#### 6. possible_keys和key

possible_keys: 可能使用到的key, 并不是越多越好，需要筛选

key: 使用到的key

#### 7. key_len - 关键点

多数场景对于联合索引，使用到的索引长度。`越大越好`

计算公式：

```sql
varchar(10)变长字段且允许NULL = 10 * ( character set： utf8=3,gbk=2,latin1=1)+1(NULL)+2(变长字段) 

varchar(10)变长字段且不允许NULL = 10 * ( character set：utf8=3,gbk=2,latin1=1)+2(变长字段)

char(10)固定字段且允许NULL = 10 * ( character set：utf8=3,gbk=2,latin1=1)+1(NULL) 

char(10)固定字段且不允许NULL = 10 * ( character set：utf8=3,gbk=2,latin1=1)
```

#### 8. ref

当使用索引列等值查询时候，与索引列匹配的对象信息

#### 9. rows

需要读取的记录条数。该值越小越好

#### 10. filtered 

某个表经过搜索条件后过滤剩下的记录条数百分比。**越大越好**

对于单表查询来说，filtered值没有什么意义，但对于连接查询来说。驱动表对应执行计划的filtered值，它决定了被驱动表要执行的次数（rows * filtered)

#### 11. Extra

一些额外的信息，非常多。**更准确的理解MySQL到底如何执行给定的查询语句**

| 类型                                      | 描述                                                         |
| ----------------------------------------- | ------------------------------------------------------------ |
| distinct                                  | 在select部分使用了distinc关键字                              |
| Using index Condition                     | 使用到了索引下推                                             |
| Using where                               | 表明使用了where过滤                                          |
| Using join buffer                         | 表明使用了连接缓存                                           |
| impossible where                          | where子句的值总是false，不能用来获取任何元组                 |
| no tables used                            | 不带from字句的查询或者From dual查询。 使用not in()形式子查询或not exists运算符的连接查询，这种叫做反连接。即，一般连接查询是先查询内表，再查询外表，反连接就是先查询外表，再查询内表。 |
| using filesort                            | 排序时无法使用到索引时，就会出现这个。常见于order by和group by语句中 |
| using index                               | 查询时不需要回表查询，直接通过索引就可以获取查询的数据。     |
| using_union                               | 表示使用or连接各个使用索引的条件时，该信息表示从处理结果获取并集 |
| using intersect                           | 表示使用and的各个索引的条件时，该信息表示是从处理结果获取交集 |
| using sort_union和using sort_intersection | 与前面两个对应的类似，只是他们是出现在用and和or查询信息量大时，先查询主键，然后进行排序合并后，才能读取记录并返回。 |
| using temporary                           | 表示使用了临时表存储中间结果。临时表可以是内存临时表和磁盘临时表，执行计划中看不出来，需要查看status变量，used_tmp_table，used_tmp_disk_table才能看出来 |
| filtered                                  | 使用explain extended时会出现这个列，5.7之后的版本默认就有这个字段，不需要使用explain extended了。这个字段表示存储引擎返回的数据在server层过滤后，剩下多少满足查询的记录数量的比例，注意是百分比，不是具体记录数 |



Using index:

**覆盖索引**：根据索引查找，由于select字段在B+树叶子节点已经存在，直接使用索引查找。

**索引下推:** 假设查询语句中含有类似like语句 根据索引查找到主键，主键在回表查找，匹配对应like字段，这种方式会产生随机IO。另外一种做法是在索引字段上进行like匹配，之后再次回表查询，使用到了索引下推。

[示例测试SQL数据](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/file/EXPLAIN%E7%9A%84%E4%BD%BF%E7%94%A8.sql)

### Explain四种格式

#### 传统格式

不加任何关键字信息

#### JSON格式

explain format=JSON QUERY, 这里可以查看执行成本cost_info信息

#### Tree格式

TREE格式是8.0.16版本之后引入的新格式，主要根据查询的`各个部分之间的关系`和`各部分的执行顺序`来描述如何查询。

#### 可视化格式

借助WorkBench

### SHOW  WARNINGS的使用

执行完Explain之后，可以使用`SHOW  WARNINGS`,查看优化后执行的sql语句

## 分析优化器执行计划  - Trace

Trace是5.6追踪MySQL优化器执行过程

```sql
# 开启
SET optimizer_trace="enabled=on",end_markers_in_json=on; 
# 设置大小
set optimizer_trace_max_mem_size=1000000;
# 使用
select * from student where id < 10;
select * from information_schema.optimizer_trace\G

```

## 监控视图   sys schema

```sql
-- 索引相关
#1. 查询冗余索引 
select * from sys.schema_redundant_indexes; 
#2. 查询未使用过的索引 
select * from sys.schema_unused_indexes; 
#3. 查询索引的使用情况 
select index_name,rows_selected,rows_inserted,rows_updated,rows_deleted from sys.schema_index_statistics where table_schema='dbname' ;

-- 表相关
# 1. 查询表的访问量 
select table_schema,table_name,sum(io_read_requests+io_write_requests) as io from sys.schema_table_statistics group by table_schema,table_name order by io desc; 
# 2. 查询占用bufferpool较多的表 
select object_schema,object_name,allocated,data
from sys.innodb_buffer_stats_by_table order by allocated limit 10; 
# 3. 查看表的全表扫描情况 
select * from sys.statements_with_full_table_scans where db='dbname';

-- 语句相关
#1. 监控SQL执行的频率 
select db,exec_count,query from sys.statement_analysis order by exec_count desc; 
#2. 监控使用了排序的SQL 
select db,exec_count,first_seen,last_seen,query
from sys.statements_with_sorting limit 1; 
#3. 监控使用了临时表或者磁盘临时表的SQL 
select db,exec_count,tmp_tables,tmp_disk_tables,query
from sys.statement_analysis where tmp_tables>0 or tmp_disk_tables >0 order by (tmp_tables+tmp_disk_tables) desc;

-- io相关
#1. 查看消耗磁盘IO的文件 
select file,avg_read,avg_write,avg_read+avg_write as avg_io
from sys.io_global_by_file_by_bytes order by avg_read limit 10;

-- innodb相关
#1. 行锁阻塞情况 
select * from sys.innodb_lock_waits;
```

# 索引优化与查询优化

- 物理查询优化： 索引、表连接
- 逻辑查询优化:  通过SQL等价变换提升查询效率，换一种写法

> 大多数情况下都（默认）采用`B+树`来构建索引。只是空间列类型的索引使用`R-树`，并且MEMORY表还支持`hash索引`。
>
> 其实，用不用索引，最终都是优化器说了算。优化器是基于什么的优化器？基于`cost开销(CostBaseOptimizer)`，它不是基于`规则(Rule-BasedOptimizer)`，也不是基于`语义`。怎么样开销小就怎么来。另外，**SQL语句是否使用索引，跟数据库版本、数据量、数据选择度都有关系。**

## 索引失效场景

> 任何时候都不是绝对的，基于成本分析

### 全值匹配   

按照索引进行匹配，**不会失效**

### 最佳左前缀法则

```sql
- age建立索引 name建立索引 使用
EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE student.age = 30 AND student.name = 'abcd';	

-- 只有索引age classid name 下面不会使用索引 但现在没有这样的索引，idx_age_classid_name的字段顺序是先找age，所以不符合，所以此时不能用索引
EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE student.classid = 1 AND student.name = 'abcd';	

EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE student.age = 30 AND student.name = 'abcd';
# 现在，删除idx_age和idx_age_classid，发现用到idx_age_classid_name，而key_len=5,即只用到age字段，int(4)+null(1)
#因为索引完age后没有classid了，不能再查找到name

```

在MySQL建立联合索引时会遵守最佳左前缀匹配原则，即最左优先，在检索数据时从联合索引的最左边开始匹配。

结论：MySQL可以为多个字段创建索引，一个索引可以包括16个字段。对于多列索引，**过滤条件要使用索引必须按照索引建立时的顺序，依次满足，一旦跳过某个字段，索引后面的字段都无法被使用。**如果查询条件中没有使用这些字段中第1个字段时，多列（或联合）索引不会被使用。

### 主键插入顺序

在定义表时，让主键auto_increment，否则，插入一条数据时可能会移动大量数据。
如，往 1 5 8 10 15 … 100 中插9，会放在8 10 中间，因为索引默认升序排列。那么10往后的数据都要挪动，页不够时又要放到下一页，每插一条数据都这样挪一次，开销很大
我们自定义的主键列id 拥有AUTO_INCREMENT 属性，在插入记录时存储引擎会自动为我们填入自增的主键值。这样的主键占用空间小，顺序写入，**减少页分裂。**

### 计算、函数、类型转换(自动或手动)导致索引失效

```sql
##### 例1：3
EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE student.name LIKE 'abc%';	#更好，能够使用上索引
# type=range 使用了索引中的排序

EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE LEFT(student.name,3) = 'abc';	# left(text,num_chars):截取左侧n个字符
# type = all 全表的访问
# 该语句的执行过程：针对每一条数据，一个一个取出，先作用一遍函数，再拿函数结果与abc对比，用不上b+树

CREATE INDEX idx_name ON student(NAME);

##### 例2：
CREATE INDEX idx_sno ON student(stuno);
EXPLAIN SELECT SQL_NO_CACHE id,stuno,NAME FROM student WHERE stuno+1 = 900001; 	# type = all 需要做运算，无法直接用索引找值

EXPLAIN SELECT SQL_NO_CACHE id,stuno,NAME FROM student WHERE stuno = 900000; 	# type = ref
```

###  类型转换导致索引失效

```sql
# 未使用到索引
EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE NAME=123;	# 这里使用了隐式转换
# 使用到索引
EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE NAME='123'; 	# name本身就是字符串类型


```

### 范围条件右边的列索引失效

```sql
-- 存在索引 age classId name 但是下面只会使用到 age classId
EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE student.age = 30 AND student.classId > 20 AND student.name = 'abc';	
--改写 添加所以你 age name classId 使用到了索引
EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE student.age = 30 AND student.name = 'abc' AND student.classId > 20 ;	
创建的联合索引中，必须把涉及到范围的字段写在最后。
```

### 不等于(!= 或者<>)索引失效

```sql
-- 不等于(!= 或者<>)索引失效
CREATE INDEX idx_name ON student(NAME);

EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE student.name <> 'abc';	# 索引失效 索引查的是等于 这里是* 

```

> 结论：最好在设计表结构的时候将字段设置为not null约束，比如可以将int 默认值设置成0。 将字符类型设置为空字符串
>
> 同理：在查询中not like 也无法使用到索引，导致全表扫描

###  is null 可以使用索引 is not null 无法使用索引

is null : 触发索引

### like以通配符%开头索引失效

```sql
# like以通配符%开头索引失效
EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE NAME LIKE 'ab%';	# 可用索引

EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE NAME LIKE '%ab';	# type = all 索引失效

```

**页面搜索严禁左模糊或者全模糊，如果需要请走搜索引擎来解决。**

###  OR 前后存在非索引的列，索引失效

```sql
EXPLAIN SELECT SQL_NO_CACHE * FROM student WHERE age = 10 OR classid = 100;	# 未使用索引，索引+全表扫描->全表扫描
-- age是存在索引的，classId是没有索引的，导致全表all
-- 给classId添加索引 此时type为 index_merge,key = idx_age,idx_cid
```

### 数据库和表的字符集统一使用utf8mb4

统一使用utf8mb4( 5.5.3版本以上支持)兼容性更好，统一字符集可以避免由于字符集转换产生的乱码。不同的字符集进行比较前需要进行转换会造成索引失效。

**总结：**

1. 对于单利索引，进来选择对当前query过滤更好的索引
2. 对于选择组合索引，对当前query过滤更好的索引字段顺序中，位置越靠前越好
3. 在选择组合索引，尽量选择能够包含当前query的where字句中更多字段的索引
4. 在选择组合索引，如果某个字段包含范围查询，尽量把这个字段放在索引次序的最后面

## 关联查询优化

外连接的关联条件中，两个关联字段的类型、字符集一定要保持一致，否则索引会失效。外连接查询优化器也会做驱动表与被驱动表的修改。

> 结论1：对于内连接来说，查询优化器可以决定谁来作为驱动表，谁作为被驱动表出现
>
> 结论2：对于内连接来讲，如果表的连接条件中只能有一个字段有索引，则有索引的字段所在的表会被作为被驱动表
>
> 结论3：对于内连接来说，在两个表的连接条件都存在索引的情况下，会选择小表作为驱动表。`小表驱动大表`



**内连接优化器**可以**决定**（被）驱动表。在只有**一个表存在索引**的情况下，会选择**存在索引的表**作为**被驱动表**(因为被驱动表查询次数更多，建立索引以后可以**避免全表扫描**)

## JOIN的底层原理

### 1. 驱动表与被驱动表

驱动表就是**主表**，被驱动表就是**从表**

内连接，外连接优化器会根据优化结果选择先查询哪张表，这张表就是主表驱动表。

### 2. Simple Nested Loop Join 简单嵌套循环连接

算法过程：从A表取出一条数据，遍历B表所有数据进行匹配。驱动表A每一条记录与B进行匹配

![image-20230610174106019](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230610174106019.png)

**效率非常低**

### 3. Index Nested Loop Join 索引嵌套循环

**优化思路是减少内层表的数据匹配次数，所以要求对被驱动表建立索引**。这样查询的转换成B+树的高度。通过外层表匹配条件直接与内层索引进行匹配，**避免**和内层表的**每条记录进行比较**，这样极**大地减少**了对内层表的匹配次数。![image-20230610174249335](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230610174249335.png)

驱动表中的每条记录通过被驱动表的**索引**进行访问，因为索引查询的成本是比较固定的，故 MySQL 优化器都倾向于使用有索引的表作为被驱动表（减少被驱动表的多次全表扫描）

如果被驱动表加索引，效率是非常高的，如果索引**不是主键索引**，所以还得进行一次**回表**查询。相比，被驱动表的索引**是主键索引**，**效率会更高**

### 4. Blocked Nested Loop Join 块嵌套循环连接

如果存在索引，使用INLJ进行，如果join列没有索引，匹配的扫描次数又大大增加。每次访问被驱动表，其表中的记录都会被**加载到内存**中，然后再从驱动表中取一条与其匹配，匹配结束后**清除内存**，然后再**从驱动表中加载一条记录**，然后把驱动表的记录**再加载到内存**匹配，这样**周而复始**，大大增加了 IO 次数。为了减少被驱动表的 IO 次数，就出现了 Block Nested-Loop Join 的方式。

不再是**逐条**获取驱动表的数据，而是**一块一块**的获取，引入了 join buffer 缓冲区，将驱动表 join 相关的部分数据列（大小受 join buffer 的限制）**缓存到 join buffer 中**，然后**全表扫描**被驱动表，被驱动表的每一条记录一次性和 join buffer 中的所有驱动表记录进行匹配（内存中操作），将**简单嵌套循环**中的`多次比较`**合并**成`一次`，**降低了被动表的访问频率**。

> ```sql
> 注意：
> 这里缓存的不只是关联表的列，select 后面的列也会缓存起来
> 在一个有 N 个 join 关联的 SQL 中会分配 N-1 个 join buffer。所以查询的时候尽量减少不必要的字段，可以 让 join buffer 中存放更多的列。
> ```

![image-20230610174555178](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230610174555178.png)

**Join Buffe参数设置**

- block_nested_loop

  通过 `show variables like '%optimizer_switch%'` 查看 `block_nested_loop` 状态。默认是开启的。

- join_buffer_size

  驱动表能不能一次加载完，要看 join buffer 能不能存储所有的数据，默认情况下 `join_buffer_size = 256K`。

  join *buffer* size 的最大值在 32 位系统可以申请 4G，而在 64 位操做系统下可以申请大于 4G 的 join_buffer空间（64 位 Windows 除外，其大值会被截断为 4GB并发出警告）。

### 小结

1. 保证被驱动表的 JOIN 字段已经创建了索引（减少内层表的循环匹配次数）
2. 需要 JOIN 的字段，数据类型保持绝对一致。
3. LEFT JOIN 时，选择小表作为驱动表， 大表作为被驱动表 。减少外层循环的次数。
4. INNER JOIN 时，MySQL 会自动将小结果集的表选为驱动表 。选择相信 MySQL 优化策略。
5. 能够直接多表关联的尽量直接关联，不用子查询。(减少查询的趟数)
6. **不建议使用多层嵌套子查询，建议将子查询 SQL 拆开结合程序多次查询，或使用 JOIN 来代替子查询。**
7. 衍生表建不了索引
8. 默认效率比较：INLJ > BNLJ > SNLJ
9. 正确理解小表驱动大表：**大小不是指表中的记录数，而是永远用小结果集驱动大结果集（其本质就是减少外层循环的数据数量）**。 比如A表有100条记录，B表有1000条记录，但是where条件过滤后，B表结果集只留下50个记录，A表结果集有80条记录，此时就可能是B表驱动A表。其实上面的例子还是不够准确，因为结果集的大小也不能粗略的用结果集的行数表示，而是表行数 *每行大小。其实要理解你只需要结合Join Buffer就好了，因为表行数* 每行大小越小，其占用内存越小,就可以在Join Buffer中尽量少的次数加载完了。

### HashJoin

从 MySQL 8.0.20 版本开始将废弃 BNLJ，因为加入了 hash join 默认都会使用 hash join

- Nested Loop：

  对于被连接的数据子集较小的情况，Nested Loop 是个较好的选择。

- Hash Join 是做 **大数据集连接** 时的常用方法，优化器使用两个表中较小（相对较小）的表利用 join key 在内存中建立 **散列表**，然后扫描较大的表并探测散列表，找出与 Hash 表匹配的行。

  - 这种方式适用于较小的表完全可以放于内存中的情况，这样总成本就是访问两个表的成本之和
  - 在表很大的情况下并不能完全放入内存，这时优化器会将它分割成 若干不同的分区，不能放入内存的部分就把该分区写入磁盘的临时段，此时要求有较大的临时段从而尽量提高 I/O 的性能。
  - 它能够很好的工作于没有索引的大表和并行查询的环境中，并提供最好的性能。大多数人都说它是 Join 的重型升降机。Hash Join 只能应用于等值连接（如 WHERE A.COL1 = B.COL2），这是由 Hash 的特点决定的。

| 类型     | Nested Loop                                                  | Hash Join                                                    |
| :------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| 使用条件 | 任何条件                                                     | 等值连接（=）                                                |
| 相关资源 | CPU、磁盘 I/O                                                | 内存、临时空间                                               |
| 特点     | 当有高选择性索引或进行限制性搜索时效率比较高，能够快速返回第一次的搜索结果 | 当缺乏索引或者索引条件模糊时，Hash Join 比 Nested Loop 有效。在数据仓库环境下，如果表的记录数多，效率高 |
| 缺点     | 当索引丢失或者查询条件限制不够时，效率很低；当表的记录数较多，效率低 | 为遍历哈希表，需要大量内存。第一次的结果返回较慢             |

## 子查询优化

MySQL 从 4.1 版本开始支持子查询，使用子查询可以进行 SELECT 语句的嵌套查询，即一个 SELECT 查询的结果作为另一个 SELECT 语句的条件。子查询可以一次性完成很多逻辑上需要多个步骤才能完成的操作 。

子查询是 MySQL 的一项重要的功能，可以帮助我们通过一个 SQL 语句实现比较复杂的查询。但是，子查询的执行效率不高。

原因:

执行子查询时，MySQL 需要为内层查询语句的查询结果建立一**个临时表** ，然后外层查询语句从临时表中查询记录。查询完毕后，再撤销这些临时表 。这样会消耗过多的 CPU 和 IO 资源，产生大量的慢查询。 子查询的结果集存储的临时表，不论是内存临时表还是磁盘临时表都 不会存在索引 ，所以查询性能会受到一定的影响。 对于返回结果集比较大的子查询，其对查询性能的影响也就越大。 在 MySQL 中，可以使用连接（JOIN）查询来替代子查询。 连接查询 不需要建立临时表，其 速度比子查询要快，如果查询中使用索引的话，性能就会更好。

```sql
#创建班级表中班长的索引
CREATE INDEX idx_monitor ON class(monitor);

#查询班长的信息
EXPLAIN SELECT * FROM student stu1
    WHERE stu1.`stuno` IN (
    SELECT monitor
    FROM class c
    WHERE monitor IS NOT NULL
);
-- 改写
EXPLAIN SELECT stu1.* FROM student stu1 JOIN class c 
ON stu1.`stuno` = c.`monitor`
WHERE c.`monitor` IS NOT NULL;

#查询不为班长的学生信息
EXPLAIN SELECT SQL_NO_CACHE a.* 
FROM student a 
WHERE  a.stuno  NOT  IN (
            SELECT monitor FROM class b 
            WHERE monitor IS NOT NULL);
-- 改写
EXPLAIN SELECT SQL_NO_CACHE a.*
FROM  student a LEFT OUTER JOIN class b 
ON a.stuno =b.monitor
WHERE b.monitor IS NULL;
```

**TIP：尽量不要使用 NOT IN 或者 NOT EXISTS，用 LEFT JOIN xxx ON xx WHERE xx IS NULL 替代**

## 排序优化

问题：在 WHERE 条件字段上加索引，但是为什么在 ORDER BY 字段上还要加索引呢？

-  在 MySQL 中，支持两种排序方式，分别是 **FileSort** 和 **Index** 排序。 Index 排序中，索引可以保证数据的有序性，就不需要再进行排序，效率更更高。 
-  **FileSort** 排序则一般在 内存中 进行排序，占用 CPU 较多。如果待排序的结果较大，会产生临时文件 I/O 到磁盘进行排序的情况，效率低。

优化建议:

-  SQL 中，可以在 WHERE 子句和 ORDER BY 子句中使用索引，目的是在 WHERE 子句中 避免全表扫描，在 ORDER BY 子句 避免使用 FileSort 排序。当然，某些情况下全表扫描，或者 FileSort 排序不一定比索引慢。但总的来说，我们还是要避免，以提高查询效率。 
-  尽量使用 Index 完成 ORDER BY 排序。如果 WHERE 和 ORDER BY 后面是相同的列就使用单索引列；如果不同就使用联合索引。 
-  无法使用 Index 时，需要对 FileSort 方式进行调优。

```sql
-- 当前age classId,name 是有索引的
EXPLAIN SELECT SQL_NO_CACHE * FROM student ORDER BY age,classid;  
1	SIMPLE	student		ALL					498881	100.00	Using filesort
-- 没有使用索引的原因是，优化器通过计算分析，发现最终还是需要回表，使用索引的性能代价反而比不上不用索引的


EXPLAIN  SELECT SQL_NO_CACHE age,classid,name,id FROM student ORDER BY age,classid;  
-- 这里就使用到了索引,覆盖索引

EXPLAIN  SELECT SQL_NO_CACHE * FROM student ORDER BY age,classid LIMIT 10; 
-- 使用limit使用到了索引，因为优化器发现只需要10条，先根据索引查询，在回表返回10条数据
```

- order by 时顺序错误，索引失效
- order by 时规则不一致, 索引失效 （顺序错，不索引；方向反，不索引）
  规则： 同时升序或者同时降序 顺序：索引建立的顺序
- 无过滤，不索引 

**上述是与其数据量有关的**

>  **INDEX a_b_c(a,b,c) order by 能使用索引最左前缀**

- ORDER BY a
- ORDER BY a,b
- ORDER BY a,b,c
- ORDER BY a DESC,b DESC,c DESC 如果 WHERE 使用索引的最左前缀定义为常量，则 order by 能使用索引
- WHERE a = const ORDER BY b,c
- WHERE a = const AND b = const ORDER BY c
- WHERE a = const ORDER BY b,c
- WHERE a = const AND b > const ORDER BY b,c

不能使用索引进行排序

- ORDER BY a ASC,b DESC,c DESC /* 排序不一致 */
- WHERE g = const ORDER BY b,c /*丢失a索引*/
- WHERE a = const ORDER BY c /*丢失b索引*/
- WHERE a = const ORDER BY a,d /*d不是索引的一部分*/
- WHERE a in (…) ORDER BY b,c /*对于排序来说，多个相等条件也是范围查询*

### filesort算法

排序的字段不在索引列上，filesort会有两种算法: 双路排序和单路排序

- 双路排序 - 慢

  MySQL4.1之前使用双路排序。两次扫描磁盘，最终得到数据。读取行指针和order by 列，然后从扫描已经排序好的列表，按照列表中的值重新从列表中读取对应的数据输出。从磁盘读取字段，在buffer排序，在从磁盘读取其他字段，产生随机IO,比较耗时

- 单路排序 - 块
  从磁盘读取查询需要的 所有列 ，按照 order by 列在 buffer 对它们进行排序，然后扫描排序后的列表进行输出， 它的效率更快一些，避免了第二次读取数据。并且把随机 IO 变成了顺序 IO，但是它会使用更多的空间， 因为它把每一行都保存在内存中了。

> 由于单路是后出的，总体而言好过双路 但是用单路有问题 在 sort_buffer 中，单路比多路要 多占用很多空间，因为单路是把所有字段都取出，所以可能取出的数据的总大小超出了 sort_buffer 的容量，导致每次只能取 sort_buffer 容量大小的数据，进行排序（创建 temp 文件，多路合并），排完再取 sort_buffer 容量大小，再排…从而多次I/O。 单路本来想省一次 I/O 操作，反而导致了大量的 I/O 操作，反而得不偿失。
>
> 优化策略：
>
> - 提高 sort_buffer_size
> - 提高max_length_for_sort_data
>   SHOW VARIABLES LIKE '%max_length_for_sort_data%';
>
>  但是如果设的太高，数据总容量超出 sort_buffer_size 的概率就增大，明显症状是高的磁盘 I/O 活动和低的处理器使用率。如果需要返回的列的总长度大于 max_length_for_sort_data，使用双路算法，否则使用单路算法。1024-8192字节之间调整。
>
> Order by 时 select 是一个大忌。最好只Query需要的字段。
>
> 当 Query 的字段大小综合小于 max_length_for_sort_data，而且排序字段不是 TEXT|BLOG 类型时，会改进后的算法——单路排序，否则用老算法——多路排序。 两种算法的数据都有可能超出 sort_buffer_size 的容量，超出之后，会创建 tmp 文件进行合并排序，导致多次 I/O，但是用单路排序算法的风险会更大一些，所以要提高 sort_buffer_size

## Group By优化

- group by 使用索引的原则几乎跟 order by 一致 ，group by 即使没有过滤条件用到索引，也可以直接使用索引。

- group by 先排序再分组，遵照索引建的最佳左前缀法则

- 当无法使用索引列，增大 max_length_for_sort_data 和 sort_buffer_size 参数的设置

- where 效率高于 having，能写在 where 限定的条件就不要写在 having 中了

- 减少使用 order by，和业务沟通能不排序就不排序，或将排序放到程序端去做。Order by、group by、distinct 这些语句较为耗费 CPU，数据库的 CPU 资源是极其宝贵的

- 包含了 order by、group by、distinct 这些查询的语句，where 条件过滤出来的结果集请保持在 1000 行以内，否则 SQL 会很慢

## 分页查询优化

一般分页查询时，通过创建[覆盖索引](https://so.csdn.net/so/search?q=覆盖索引&spm=1001.2101.3001.7020)能够比较好地提高性能。一个常见有非常头疼的问题就是 limit 2000000,10，此时需要 MySQL 排序前 2000010 记录，仅仅返回 2000000-2000010 的记录，其他记录丢弃，查询排序的代价非常大。

```sql
EXPLAIN SELECT * FROM student LIMIT 2000000,10;
```

### 优化思路1

该方案适用于主键自增的表，可以把 Limit 查询转换成某个位置的查询 

```sql
EXPLAIN SELECT * FROM student WHERE id > 2000000 LIMIT 10;
```

### 优化思路2

在索引完成排序分页操作，最后根据主键关联到原表进行查询所需要的其它列内容

```sql
EXPLAIN SELECT * FROM student t,(SELECT id FROM student order by id limit 2000000, 10) a where t.id = a.id
```

## 覆盖索引

### 覆盖索引的定义

**索引列+主键 包含 SELECT 到 FROM 之间查询的列**，**不需要进行回表**

> 定义规则，再进行打破

### 利弊

#### 好处

1. 避免InnoDB表进行回表
   在覆盖索引中，二级索引的键值中可以获取所要的数据，避免了对主键的二次查询，减少了 IO 操作，提升了查询效率。
2. 把随机IO变成顺序IO
   由于覆盖索引是按键值的顺序存储的，对于 I/O 密集型的范围查找来说，对比随机从磁盘读取每一行的数据 I/O 要少的多，因此利用覆盖索引在访问时也可以把磁盘的随机读取的 I/O 转变成索引查找的顺序 I/O。
   **由于覆盖索引可以减少树的搜索次数，显著提升查询性能，所以使用覆盖索引是一个常用的性能优化手段。**

#### 弊端

索引字段的维护 总是有代价的。因此，在建立冗余索引来支持覆盖索引时就需要权衡考虑了。这是业务 DBA，或者称为业务数据架构师的工作。

## 索引条件下推

> 需要回表，条件下推才有意义，如果是聚餐索引查询或者覆盖索引使用不到

索引下推（Index Condition Pushdown, 简称ICP）是MySQL 5.6 版本的新特性，它能减少回表查询次数，提升检索效率。

### 使用前后

**在不使用ICP索引扫描的过程：**

storage层：只将满足index key条件的索引记录对应的整行记录取出，返回给server层

server 层：对返回的数据，使用后面的where条件过滤，直至返回最后一行。

**使用ICP扫描的过程：**

storage层：首先将index key条件满足的索引记录区间确定，然后在索引上使用index filter进行过滤。将满足的index filter条件的索引记录才去回表取出整行记录返回server层。不满足index filter条件的索引记录丢弃，不回表、也不会返回server层。

server 层：对返回的数据，使用table filter条件做最后的过滤。

### 适用条件

1. 当需要访问整表行时，ICP用于range、ref、eq_ref和ref_or_null访问方法。
2. ICP可以用于InnoDB和MyISAM表，包括分区的InnoDB和MyISAM表。
3. 对于InnoDB表，ICP仅用于二级索引。ICP的目标是减少整行读取的数量，从而减少I/O操作。对于InnoDB聚集索引，完整的记录已经读入InnoDB缓冲区。在这种情况下使用ICP并不能减少I/O。（注意：Ⅰ说明减少**完整记录（一条完整元组）读取的个数**；Ⅱ是说明对于InnoDB聚集索引无效，只能是对SECOND INDEX这样的非聚集索引有效。）
4. 在虚拟生成的列上创建的辅助索引不支持ICP。InnoDB支持虚拟生成列的二级索引。
5. 引用子查询的条件不能向下推。
6. 引用存储函数的条件不能向下推。存储引擎不能调用存储函数。
7. 触发条件不能下推。

### ICP的开启和关闭

```sql
索引条件默认启用“下推”。可以通过设置index_condition_pushdown标志来控制optimizer_switch系统变量:
SET optimizer_switch = 'index_condition_pushdown=off';
SET optimizer_switch = 'index_condition_pushdown=on';
```

## 其他查询优化策略

###  exists 与 in 区分

```sql
# 大表A驱动小表cc时用in；即当A表的数据量大于B表的数据量时
SELECT * FROM A WHERE cc IN (SELECT CC FROM B);

# 当A表的数据量小于B表的数据量时
# 小表A驱动大表cc时用EXISTS ，因为执行时每次是从A中取一条数据到SELECT cc FROM B WHERE B.cc = a.cc中执行，A小一点更合适
SELECT * FROM A WHERE EXISTS (SELECT cc FROM B WHERE B.cc = a.cc)
```

### COUNT(*)与COUNT(具体字段)效率

```sql
COUNT(*)与COUNT(1)都是统计表的所有数量，效率差别不大
如果使用MyISAM存储引擎，统计数据表的行数只需要O(1)的复杂度
如果使用InnoDB存储引擎，使用O(n)的复杂度
在InnoDB存储引擎中，如果使用Count(具体字段)来统计数据行数，尽量采用二级索引，如果没有二级索引，才使用主键索引来使用

```

### select 字段

```sql
在表查询中，建议明确字段，不要使用*作为查询的字段列表，推荐使用SELECT<字段列表>查询。原因：
①MySQL在解析的过程中，会通过查询数据字典将"*"按序转换成所有列名，这会大大的耗费资源和时间。
②无法使用覆盖索引

```

### limit 1 对优化的影响

```sql
针对的是会扫描全表的SQL语句，如果你可以确定结果集只有一条，那么加上LIMIT 1 的时候，当找到一条结果的时候就不会继续扫描了，这样会加快查询速度。

如果数据表已经对字段建立了唯一索引，那么可以通过索引进行查询，不会全表扫描的话，就不需要加上LIMIT 1 了。

```

### 多使用COMMIT

```sql
只要有可能，在程序中尽量多使用COMMIT，这样程序的性能得到提高，需求也会因为COMMIT所释放的资源而减少。

COMMIT所释放的资源：
    回滚段上用于恢复数据的信息
    被程序语句获得的锁
    redo/ undo log buffer 中的空间
    管理上述3种资源中的内部花费

```

# 淘宝数据库主键如何设计

![image-20230611134726925](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230611134726925.png)

### 自增ID问题

![image-20230611134752779](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230611134752779.png)

### 业务系统做主键

**尽量不要用根业务有关的字段做主键，比较作为项目的设计人员，我们谁也无法预测在项目的整个生命周期中，哪个业务字段会因为业务的需求有重复，或者重用的情况出现。**

> 刚开始使用MySQL时候，很多人都很容易犯的错误喜欢用业务字段做主键，想当然的认为了解业务需求，但实际情况往往出乎意料，而更改主键设置的成本非常高

### 淘宝的主键设计

**订单ID = 时间 + 去重字段 + 用户ID后6位尾号**

### 推荐的主键设计

> #### 主键设计至少应该是全局唯一且是单调递增。

![image-20230611135139209](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230611135139209.png)

#### UUID

```sql
SELECT uuid() FROM DUAL;
```

##### 特点

全局唯一，占用36字节，数据无序，插入性能查

#### MySQL UUID组成

**UUID = 时间+UUID版本（16字节）- 时钟序列（4字节） - MAC地址（12字节）**

![image-20230611135345985](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230611135345985.png)

#### 改造UUID

> #### MySQL 8.0可以更换时间低位和时间高位的存储方式，这样UUID就是有序的UUID了。

![image-20230611135422552](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230611135422552.png)

#### 如果不是[MySQL8](https://so.csdn.net/so/search?q=MySQL8&spm=1001.2101.3001.7020).0 如何解决

**手动赋值字段做主键**

![image-20230611135551610](C:\Users\15667\AppData\Roaming\Typora\typora-user-images\image-20230611135551610.png)

---
title: "MySql高级 事务"
date: 2023-06-11T13:57:55+08:00
lastmod: 2023-06-11T13:57:55+08:00
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

# 数据库事务概述

## 引擎支持情况

SHOW ENGINES 命令来查看当前 MySQL 支持的存储引擎都有哪些，以及这些存储引擎是否支持事务

## 基本概念

事务：一组逻辑单元，是数据从一种合法状态切换到另一种合法状态。

合法状态：符合现实逻辑

**事务处理的原则：**保证所有事务都作为`一个工作单元`来执行，即使出现了故障，都不能改变这种执行方式。当在一个事务中执行多个操作时，要么所有的事务都被提交(`commit`)，那么这些修改就`永久`地保存下来；要么数据库管理系统将`放弃`所作的所有`修改`，整个事务回滚(`rollback`)到最初状态。

## 事务的ACID特性

- **原子性（atomicity）：**

原子性是指事务是一个不可分割的工作单位，要么全部提交，要么全部失败回滚。

- **一致性（consistency）：**

一致性是指事务执行前后，数据从一个`合法性状态`变换到另外一个`合法性状态`。这种状态是`语义上`的而不是语法上的，跟具体的业务有关。

- **隔离型（isolation）：**

事务的隔离性是指一个事务的执行`不能被其他事务干扰`，即一个事务内部的操作及使用的数据对`并发`的其他事务是隔离的，并发执行的各个事务之间不能互相干扰。

- **持久性（durability）：**

持久性是指一个事务一旦被提交，它对数据库中数据的改变就是`永久性的`，接下来的其他操作和数据库故障不应该对其有任何影响。

持久性是通过`事务日志`来保证的。日志包括了`重做日志`和`回滚日志`。当我们通过事务对数据进行修改的时候，首先会将数据库的变化信息记录到重做日志中，然后再对数据库中对应的行进行修改。这样做的好处是，**即使数据库系统崩溃，数据库重启后也能找到没有更新到数据库系统中的重做日志，重新执行，从而使事务具有持久性。**

## 事务的状态

- **活动的（active）**

事务对应的数据库操作正在执行过程中时，我们就说该事务处在`活动的`状态。

- **部分提交的（partially committed）**

当事务中的最后一个操作执行完成，但由于操作都在内存中执行，所造成的影响并`没有刷新到磁盘`时，我们就说该事务处在`部分提交的`状态。

- **失败的（failed）**

当事务处在`活动的`或者`部分提交的`状态时，可能遇到了某些错误（数据库自身的错误、操作系统错误或者直接断电等）而无法继续执行，或者人为的停止当前事务的执行，我们就说该事务处在`失败的`状态。

- **中止的（aborted）**

如果事务执行了一部分而变为`失败的`状态，那么就需要把已经修改的事务中的操作还原到事务执行前的状态。换句话说，就是要撤销失败事务对当前数据库造成的影响。我们把这个撤销的过程称之为`回滚`。当`回滚`操作执行完毕时，也就是数据库恢复到了执行事务之前的状态，我们就说该事务处在了`中止的`状态。

- **提交的（committed）**

当一个处在`部分提交的`状态的事务将修改过的数据都`同步到磁盘`上之后，我们就可以说该事务处在了`提交的`状态。

> `ACID`是事务的四大特性，原子性是基础，隔离性是手段，一致性是约束条件，持久性是目的。

![image-20230613082029664](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230613082029664.png)

# 如何使用事务

- 显式事务
- 隐式事务

## 显示事务

```sql
-- 显式事务 
-- 步骤1：开启事务
-- START TRANSACTION 可以限制事务操作 
-- 当前事务是只读事务，不能增删改，只是不允许修改那些其他事务也能访问到的表的数据，对于临时表(CREATE TEMPORARY TABLE)来说，是可以进行增删改的 
START TRANSACTION READ ONLY;
-- 读写，默认 
START TRANSACTION READ WRITE;
-- 开启一致性读 
START TRANSACTION READ CONSISTENT SNAPSHOT;
-- 或者  
BEGIN;
-- 步骤2：一系列的DML操作
-- 步骤3：提交或者中止状态  
-- 提交事务 
COMMIT;
-- 回滚事务  
ROLLBACK;

```

## 隐式事务

```sql
-- 隐式事务  
-- 通过 autocommit 设置 ,默认 on，代表每一条DML都是一个独立的操作，执行之后，默认会自动提交。
SHOW VARIABLES LIKE '%autocommit%';
-- 关闭自动提，只针对DML，对DDL是无效的  
SET autocommit=FALSE; 
-- 执行操作，构成一个独立的事务   
-- 提交  
COMMIT;
-- 当 autocommit 为 true，START TRANSACTION或者BEGIN之后，都不会将DML操作作为单个事务，而是作为整体一个事务。

```

保存点：

```sql
-- 保存点 SAVEPOINT ： 事务操作中设置的一个状态，在事务结束之前，可以回到保存点继续操作失误。
-- 设置保存点 
SAVEPOINT save1;
-- 回滚到保存点 
ROLLBACK TO save1;
-- 删除保存点 
RELEASE SAVEPOINT save1;

```

## 隐式提交数据的情况

- 数据定义语言 `DDL` ：例如操作数据库、表、视图、存储过程等结构，`CREATE`、`ALTER`、`DROP`等语句
- 隐式使用或修改MySQL数据库中的表：使用 `ALTER USER`、`CREATE USER`、`DROP USER`、`GRANT`、`RENAME USER`、`REVOKE`、`SET PASSWORD`等语句也会隐式提交前面语句所属于的事务
- 事务控制或关于锁定的语句：在一个事务中没有提交或者回滚，又使用`START TRANSACTION`或者`BEGIN`开启一个新的事物，会隐式的提交上一个事务
- 将 `autocommit` 设置为`true`，也会隐式提交前边语句所属的事务
- 使用 `LOCK TABLES`、`UNLOCK TABLES`等关于锁定的语句也会隐式的提交前边语句所属的事务。
- 加载数据的语句：LOAD DATA语句来批量往数据库中导入数据时，也会隐式的提交前面语句所属的事务。
- 关于MySQL复制的一些语句：`START SLAVE`、`STOP SLAVE`、`RESET SLAVE`、`CHANGE MASTER TO`等语句，也会隐式的提交前面语句所属的事务。
- 其他的一些语句：使用 `ANALYZE TABLE`，`CACHE INDEX`、`CHECK TABLE`、`FLUSH`、`LOAD INDEX INTO CACHE`、`OPTIMIZE TABLE`、`REPAIR TABLE`、`RESET`等语句也会隐式的提交前面语句所属的事务。

## 事务操作

```sql
-- 使用事务 
CREATE TABLE user3(name VARCHAR(10) PRIMARY KEY);
SELECT * FROM user3;
-- 开启事务 
BEGIN;
-- 插入数据
INSERT INTO user3 VALUES('a');
-- 获取数据，可以获取到 
SELECT * FROM user3;
-- 提交 
COMMIT;
-- 获取数据，也可以获取到 
SELECT * FROM user3;

-- 开启事务 
BEGIN;
INSERT INTO user3 VALUES('c');
-- 收到主键影响，会插入失败  
INSERT INTO user3 VALUES('c');
ROLLBACK;

-- DDL 操作会自动提交数据，不受 autocommit 变量的影响 
TRUNCATE TABLE user3;
-- autocommit为默认状态   
SHOW VARIABLES LIKE '%autocommit%';
-- 默认一条DML为一个事务，可以提交成功
INSERT INTO user3 VALUES('a'); 
-- 由于主键原因，操作失败，处于 failed 状态 
INSERT INTO user3 VALUES('a');
-- 回滚，回滚到失败状态之间
ROLLBACK;
-- 只插入了1条记录  
SELECT * FROM user3;

-- completion_type的使用  
SELECT @@completion_type;
SET @@completion_type = 1;
-- autocommit为默认状态   
SHOW VARIABLES LIKE '%autocommit%';
-- 默认一条DML为一个事务，可以提交成功
INSERT INTO user3 VALUES('b'); 
-- 由于主键原因，操作失败，处于 failed 状态 
INSERT INTO user3 VALUES('b');
-- 回滚
ROLLBACK;
-- 还是只有a这1条记录，这就是由于   @@completion_type 的影响 
SELECT * FROM user3;

```

`completion_type`的使用

1. `completion_type=0`，默认情况，当执行`COMMIT`的时候会提交事务，执行下一个事务时，还需要用`START TRANSACTION`或者`BEGIN`来开启。
2. `completion_type=1`，提交事务之后，相当于执行了 `COMMIT AND CHAIN`，也就是开启一个链式事物，即提交事务之后会开启一个相同隔离级别的事务。
3. `completion_type=2`，这种情况下 `COMMIT=COMMIT AND RELEASE`，也就是当事务提交时，会自动与服务器断开连接。

### InnoDB和MyISAM在事务下的区别

MyISAM不支持事务

```sql
-- 创建表  
CREATE TABLE test1(i INT) ENGINE = INNODB;
CREATE TABLE test2(i INT) ENGINE = MYISAM;
-- 针对 InnoDB 
BEGIN; 
INSERT INTO test1 VALUES (1);
ROLLBACK;
-- 回滚之后，没有数据 
SELECT * FROM test1;

-- 针对 MyISAM 
BEGIN;
INSERT INTO test2 VALUES (1);
ROLLBACK;
-- 回滚之后，数据还在，事务对MyISAM无效 
SELECT * FROM test2;

```

### 保存点 SAVEPOINT

```sql
-- 创建表 
CREATE TABLE user4(NAME VARCHAR(10),balance DECIMAL(10,2));
-- 操作事务 
BEGIN;
INSERT INTO user4(NAME,balance) VALUES('a',1000);
COMMIT;
SELECT * FROM user4;

-- 再次操作事务  
BEGIN;
UPDATE user4 SET balance=balance-100 WHERE NAME = 'a';
UPDATE user4 SET balance=balance-100 WHERE NAME = 'a';
-- 设置保存点 
SAVEPOINT s1;
UPDATE user4 SET balance=balance+1 WHERE NAME = 'a';
-- 单独回滚 +1 的操作，回滚到保存点 s1  
ROLLBACK TO s1;
SELECT * FROM user4;
-- 此时事务没有完成  
ROLLBACK;
-- 或者  
COMMIT;

```

# 事务的隔离级别

## 数据并发问题

### 脏写

对于两个事务`Session A`、`Session B`，如果事务`Session A`修改了另一个未提交事务`Session B`修改过的数据，那就意味着发生了脏写

![image-20230613221237339](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230613221237339.png)

### 脏读

对于两个事务`Session A`、`Session B`，`Session A`读取了**已经被`Session B`更新但还没有被提交**的字段。之后若`Session B`回滚，`Session A`读取的内容就是临时且无效的。

![image-20230613221255997](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230613221255997.png)

### 不可重复读

对于两个事务`Session A`、`Session B`，**`Session A`读取了一个字段，然后`Session B`更新了该字段。之后`Session A`再次读取同一个字段，值就不同**，就意味着发生了不可重复读。

![image-20230613221321837](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230613221321837.png)

### 幻读

对于两个事务`Session A`、`Session B`，`Session A`从一个表中读取了一个字段，然后`Session B`在该表中插入了一些新的行。之后，如果`Session A`再次读取同一个表，就会多出几行。那就意味着发生了幻读。

![image-20230613221349414](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230613221349414.png)

注意1：如果`Session B`删除了一些记录，导致`Session A`读取的记录变少了，这个现象不属于幻读，幻读强调的是一个事务按照某个相同条件多次读取记录时，后读取时读到了之前没有读到的记录。

注意2：对于先前已经读到的记录，之后又读取不到，这相当于每一条记录都发生了不可重复读的现象。

## SQL的隔离级别

问题严重性
脏写  > 脏读 > 不可重复读 > 幻读

可以舍弃一部分隔离性来换取一部分性能在这里就体现在：设立一些隔离级别，隔离级别越低，并发问题发生的就越多。SQL标准设立了4个隔离级别：

- `READ UNCOMMIT`：读未提交，在该隔离级别，所有事务都可以看到其他未提交事务的执行结果（没有提交，但是可以看到结果，也就意味着发生了脏读，因为如果另外一个事务回滚，则出现前后不一致。）。不能避免脏读、不可重复读、幻读。
- `READ COMMIT`：读已提交，满足了隔离的简单定义：一个事务只能看见已经提交事务所做的改变（没有提交，则读取不到，提交，则读取到），这是大多数数据库系统的默认隔离级别（Oracle默认隔离级别）。可以避免脏读，但不可重复读、幻读问题仍然存在。
- `REPEATABLE READ`：可重复读，事务A在读到一条数据之后，此时事务B对该数据进行了修改并提交，那么事务A再读该数据，读到的还是原来的内容（先读一条数据，后续无论其他事务是否提交，都按照这条已经读到的数据处理）（这里与脏读的差别是脏读提交之后可读取到，提交之前读取不到；可重复读是读取的都是第一次读取的数据。）。可以避免脏读、不可重复读，但幻读问题仍然存在。**这是MySQL的默认隔离级别**。
- `SERIALIZABLE`：可串行化，确保事务可以从一个表中读取相同的行。这个事务持续期间，禁止其他事务对该表执行插入、更新和删除操作。所有的并发问题都可以避免，但是性能很低。能避免脏读、不可重复读和幻读。

SQL标准中规定，针对不同的隔离级别，并发事务可以发生不同严重程度的问题，具体情况如下：

![image-20230613221457170](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230613221457170.png)

脏读是最为严重的，因此这四种隔离级别，都解决了脏读的问题。

不同隔离级别有不同的锁和并发机制，隔离级别与并发性能关系如下：

![image-20230613221507841](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230613221507841.png)

## MySQL支持的四种隔离级别

```sql
-- 查看隔离级别
SELECT @@transaction_isolation;
-- 设置隔离级别  
-- 当前会话  
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- 全局 
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- 或者  
SET SESSION TRANSACTION_ISOLATION = 'READ-UNCOMMITTED';
SET SESSION TRANSACTION_ISOLATION = 'READ-COMMITTED';
SET SESSION TRANSACTION_ISOLATION = 'REPEATABLE-READ';
SET SESSION TRANSACTION_ISOLATION = 'SERIALIZABLE';

```

`GLOBAL`：当前已经存在的会话无效，只对执行完该语句之后产生的会话起作用；

`SESSION`：对当前会话的所有后续事务有效，如果在事务之间执行，对后续的事务有效，该语句可以在当前事务中间执行，但不会影响当前正在执行的事务

重启之后，都会恢复成默认隔离级别。
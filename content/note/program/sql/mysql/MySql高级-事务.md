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

# 事务日志

事务有四种特性：原子性、一致性、隔离性、持久性

- 隔离性是由`锁机制实现`
- 原子性、一致性、持久性由事务的`redo`日志和`undo`日志来保证
  - redo log : 重做日志，提供在写入操作，恢复提交事务的页操作，记录事务的持久性
  - undo log: 回滚日志，回滚行记录到某一个特定版本，用来保证事务的原子性，一致性

## redo 日志

### 为什么需要redo log?

1. 缓冲池可以帮助我们消除CPU和磁盘之间的鸿沟，checkpoint机制可以保证数据的最终落盘，然而由于checkpoint`并不是每次变更的时候就触发`的，而是master线程隔一段时间去处理的。所以最坏的情况就是事务提交后，刚写完缓冲池，数据库宕机了，那么这段数据就是丢失的，无法恢复
2. 事务包含`持久性`的特性，就是说对于一个已经提交的事务，在事务提交后即使系统发生了崩溃，这个事务对数据库中所做的更改也不能丢失

那么如何保证这个持久性呢？`一个简单的做法`：在事务提交完成之前把该事务所修改的所有页面都刷新到磁盘，但是这个简单粗暴的做法有些问题

`另一个解决的思路`：我们只是想让已经提交了的事务对数据库中数据所做的修改永久生效，即使后来系统崩溃，在重启后也能把这种修改恢复出来。所以我们其实没有必要在每次事务提交时就把该事务在内存中修改过的全部页面刷新到磁盘，只需要把`修改`了哪些东西`记录一下`就好。比如，某个事务将系统表空间中`第10号`页面中偏移量为`100`处的那个字节的值`1`改成`2`。我们只需要记录一下：将第0号表空间的10号页面的偏移量为100处的值更新为 2 。

3. InnoDB采用了WAL（预写日志）：**先写日志，在写磁盘**，只有日志写入成功，才算事务提交成功，这里的日志就是 redo log。当发生宕机且数据未刷到磁盘的时候，可以通过 redo log 来恢复，保证 ACID 中的 D，这就是 redo log 的作用。
   ![image-20230615204139406](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615204139406.png)

### redo  log 的好处、特点

#### 好处

- redo 降低了刷盘频率
- redo 占用的日志空间小

#### 特点

- redo日志是顺序写入磁盘
- 事务执行过程中、redo log不断记录

### redo 组成

#### 1. 重做日志缓冲：redo log buffer, 保持在内存中

服务器启动时就向操作系统申请了一大片称之为 redo log buffer 的连续内存空间，翻译成中文就是 **redo 日志缓冲区**。这片内存空间被划分成若干个连续的 **redo log block**。一个 redo log block 占用 512 字节大小。

![image-20230615204442341](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615204442341.png)

参数设置：innodb_log_buffer_size，它表示 redo log buffer 大小，**默认是 16M** ，**最大值是 4096M，最小值为 1M。**

```sql
-- 查看
show variables like '%innodb_log_buffer_size%'; 
```

#### 2. 重做日志file: **(redo log file)**，保存在硬盘中，是持久的。

保存在存储目录中

### redo 的整体流程

1. 以一个更新事务为例，redo log 流转过程，如下图所示：
   ![image-20230615204641548](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615204641548.png)

① 第 1 步：先将原始数据从磁盘中读入内存中来，修改数据的内存拷贝；
② 第 2 步：生成一条重做日志并写入 redo log buffer，记录的是数据被修改后的值；
③ 第 3 步：当事务 commit 时，将 redo log buffer 中的内容刷新到 redo log file，**对 redo log file采用追加写的方式；**
④ 第 4 步：定期将内存中修改的数据刷新到磁盘中；

2. **Write-Ahead Log（预先日志持久化）：在持久化一个数据页之前，先将内存中相应的日志页持久化。**

### redo log 刷盘策略

1. redo log 的写入并不是直接写入磁盘的，InnoDB 引擎会在写 redo log 的时候先写 redo log buffer，之后以一定的频率刷入到真正的 redo log file 中（即上面的第 3 步）。根据就是刷盘策略

![image-20230615204816357](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615204816357.png)

2. redo log buffer刷盘到 redo log file中并不是真正刷新到磁盘，而是**刷入到文件系统缓存（page cache)**这是现代操作系统为了提高文件写入效率做的一个优化），真正的写入会交给系统自己来决定（比如 page cache 足够大了）。那么对于 InnoDB 来说就存在一个问题，如果交给系统来同步，同样如果系统宕机，那么数据也丢失了（虽然整个系统宕机的概率还是比较小的）。

3. 刷盘策略Innodb参数： **innodb_flush_log_at_trx_commit**  该参数控制 commit 提交事务时，如何将 redo log buffer 中的日志刷新到 redo log file 中

   ```sql
   -- 查看刷盘参数
   show variables like 'innodb_flush_log_at_trx_commit';
   ```

   

​	① 设置为0 ：表示每次事务提交时不进行刷盘操作（系统默认 master thread 每隔 1s 进行一次重做日志的同步）；
​	② 设置为1 ：表示每次事务提交时都将进行同步，刷盘操作（默认值）；
​	③ 设置为2 ：表示每次事务提交时都只把 redo log buffer 内容写入 page cache，不进行同步。由操作系统自己决定什么时候同步到磁盘文件

4. 另外，InnoDB 存储引擎有一个后台线程，每隔 1s，就会把 redo log buffer 中的内容写到文件系统缓存，然后调用刷盘操作。
   ![image-20230615205211473](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615205211473.png)

也就是说，一个没有提交事务的 redo log 记录，也可能会刷盘。因为在事务执行过程 redo log 记录是会写入 redo log buffer 中，这些 redo log 记录会被后台线程刷盘。
除了后台线程**每秒 1 次的轮询操作**，还有一种情况，当 redo log buffer 占用的空间即将达到 **innodb_log_buffer_size**（这个参数默认是 16M）的一半的时候，后台线程会主动刷盘。

### 刷盘策略比较

innodb_flush_log_at_trx_commit = 1 时，只要事务提交成功，redo log 记录就一定在硬盘里，不会有任何数据丢失。如果事务执行期间 MySQL 挂了或宕机，这部分日志丢了，但是事务并没有提交，所以日志丢了也不会有损失。可以保证 ACID 的 D，数据绝对不会丢失，但是效率是最差的。建议使用默认值，虽然操作系统宕机的概率理论小于数据库宕机的概率，但是一般既然使用了事务，那么数据的安全相对来说更重要些。

innodb_flush_log_at_trx_commit = 2 时，只要事务提交成功，redo log buffer中的内容只写入文件系统缓存 (page cache)。如果仅仅只是 MySQL 挂了不会有任何数据丢失，但是操作系统宕机可能会有 1s 数据的丢失，这种情况下无法满足 ACID 中的 D。但是数值 2 肯定是效率最高的。

innodb_flush_log_at_trx_commit = 0 时，master thread 中每 1s 进行一次重做日志的 fsync 操作，因此实例 crash 最多丢失 1s 内的事务（master thread 是负责将缓冲池中的数据异步刷新到磁盘，保证数据的一致性）。值为 0 的话，是一种折中的做法，它的 I/O 效率理论是高于 1 的，低于 2 的，这种策略也有丢失数据的风险，也无法保证 ACID 中的 D。

### 写入redo log buffer 过程

#### 概念 - Mini-Transaction

1. MySQL 把对底层页面中的一次原子访问的过程称之为一个 Mini-Transaction，简称 mtr，比如，向某个索引对应的 B+ 树中插入一条记录的过程就是一个 Mini-Transaction。一个 mtr 可以包含一组 redo 日志，在进行崩溃恢复时这一组 redo 日志作为一个不可分割的整体。
2. 一个事务可以包含若干条语句，每一条语句其实是由若干个 mtr 组成，每一个 mtr 又可以包含若干条 redo 日志，画个图表示它们的关系就是这样：
   ![image-20230615211454430](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615211454430.png)

#### redo 日志写入 log buffer

1. 向 log buffer 中写入 redo 日志的过程是顺序的，也就是先往前边的 block 中写，当该 block 的空闲空间用完之后再往下一个 block 中写。当我们想往 log buffer 中写入 redo 日志时，第一个遇到的问题就是应该写在哪个 block 的哪个偏移量处，所以 InnoDB 的设计者特意提供了一个称之为 buf_free 的全局变量，该变量指明后续写入的 redo 日志应该写入到 log buffer 中的哪个位置，如图所示：
   ![image-20230615211534532](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615211534532.png)

2. 一个 mtr 执行过程中可能产生若干条 redo 日志，这些 redo 日志是一个不可分割的组，所以其实并不是每生成一条 redo 日志，就将其插入到log buffer 中，而是每个 mtr 运行过程中产生的日志先暂时存到一个地方，当该 mtr 结束的时候，将过程中产生的一组 redo 日志再全部复制到 log buffer 中。我们现在假设有两个名为 T1、T2 的事务，每个事务都包含 2 个 mtr，我们给这几个 mtr 命名一下：

   事务 T1 的两个 mtr 分别称为 mtr_T1_1 和 mtr_T1_2。
   事务 T2 的两个 mtr 分别称为 mtr_T2_1 和 mtr_T2_2。

3. 每个 mtr 都会产生一组 redo 日志，用示意图来描述一下这些 mtr 产生的日志情况
   ![image-20230615211609063](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615211609063.png)

4. 不同的事务可能是并发执行的，所以 T1、T2 之间的 mtr 可能是交替执行的。每当一个 mtr 执行完成时，伴随该 mtr 生成的一组 redo 日志就需要被复制到 log buffer 中，也就是说不同事务的 mtr 可能是交替写入 log buffer 的，我们画个示意图（为了美观，我们把一个 mtr 中产生的所有的 redo 日志当作一个整体来画）：
   ![image-20230615211631816](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615211631816.png)

有的 mtr 产生的 redo 日志量非常大，比如 mtr_t1_2 产生的 redo 日志占用空间比较大，占用了 3 个 block 来存储。

#### redo log block 的结构图

1. 一个 redo log block 是由日志头、日志体、日志尾组成。日志头占用 12 字节，日志尾占用 8 字节，所以**一个 block 真正能存储的数据就是 512 - 12 - 8 = 492 字节。**

> 为什么一个 block 设计成 512 字节？
> 这个和磁盘的扇区有关，机械磁盘默认的扇区就是 512 字节，如果你要写入的数据大于 512 字节，那么要写入的扇区肯定不止一个，这时就要涉及到盘片的转动，找到下一个扇区，假设现在需要写入两个扇区 A 和 B，如果扇区 A 写入成功，而扇区 B 写入失败，那么就会出现非原子性的写入，而如果每次只写入和扇区的大小一样的 512 字节，那么每次的写入都是原子性的。

![image-20230615211721372](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615211721372.png)

2. 真正的 redo 日志都是存储到占用 496 字节大小的 log block body 中，图中的 log block header 和 logblock trailer 存储的是一些**管理信息**。我们来看看这些所谓的管理信息都有什么。
   ![image-20230615211750543](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615211750543.png)

![image-20230615211808999](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615211808999.png)

### redo log  file

#### 相关参数

```sql
show variables like 'innodb_log_files_in_group'; 
show variables like 'innodb_log_group_home_dir'; 
show variables like 'innodb_log_file_size'; 
show variables like 'innodb_log_file_size'; 
```

1. innodb_log_group_home_dir：指定 redo log 文件组所在的路径，默认值为 ./，表示在数据库的数据目录下。MySQL 的默认数据目录 (var/lib/mysql) 下默认有两个名为 ib_logfile0 和 ib_logfile1 的文件，log buffer 中的日志默认情况下就是刷新到这两个磁盘文件中。此 redo 日志文件位置还可以修改。
2. innodb_log_files_in_group：指明 redo log file 的个数，命名方式如：ib_logfile0，iblogfile1… iblogfilen。默认 2 个，最大 100 个
3. innodb_flush_log_at_trx_commit：控制 redo log 刷新到磁盘的策略，默认为 1。
4. innodb_log_file_size：单个 redo log 文件设置大小，默认值为 48M 。最大值为 512G，注意最大值
   **指的是整个 redo log 系列文件之和，即 innodb_log_files_in_group * innodb_log_file_size 不能大于最大值 512G**

> 在数据库实例更新比较频繁的情况下，可以适当加大 redo log 组数和大小。但也不推荐 redo log 设置过大，在 MySQL 崩溃恢复时会重新执行 REDO 日志中的记录。

#### 日志文件组

1. 磁盘上的 redo 日志文件不只一个，而是以一个日志文件组的形式出现的。这些文件以 ib_logfile[数字]（数字可以是0、1、2…）的形式进行命名，每个的 redo 日志文件大小都是一样的。
2. 在将 redo 日志写入日志文件组时，是从 ib_logfile0 开始写，如果 ib_logfile0 写满了，就接着 ib_logfile1 写。同理, ib_logfile1 写满了就去写 ib_logfile2，依此类推。如果写到最后一个文件该咋办？那就重新转到 ib_logfile0 继续写，所以整个过程如下图所示。类似环形缓冲池
   ![image-20230615212116671](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615212116671.png)

3. 总共的 redo 日志文件大小其实就是： innodb_log_file_size × innodb_log_files_in_group。采用循环使用的方式向 redo 日志文件组里写数据的话，会导致后写入的 redo 日志覆盖掉前边写的 redo 日志？当然！所以 InnoDB 的设计者提出了 checkpoint 的概念。

#### checkpoint

1. 在整个日志文件组中还有两个重要的属性，分别是 write pos、checkpoint：
   - write pos是当前记录的位置，一边写一边后移；
   - checkpoint是当前要擦除的位置，也是往后推移；
2. 每次刷盘 redo log 记录到日志文件组中，write pos 位置就会后移更新。每次 MySQL 加载日志文件组恢复数据时，会清空加载过的redo log 记录，并把 checkpoint 后移更新。write pos 和 checkpoint 之间的还空着的部分可以用来写入新的 redo log 记录。
   ![image-20230615212230805](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615212230805.png)

3. 如果 write pos 追上checkpoint，表示日志文件组满了，这时候不能再写入新的 redo log 记录，MySQL 得停下来，清空一些记录，把 checkpoint 推进一下。
   ![image-20230615212247860](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615212247860.png)



## undo 日志

redo log 是事务持久性的保证，undo log 是事务原子性的保证。在事务中**更新数据**的**前置操作**其实是要先写入一个 undo log。

### 理解undo日志

1. 事务需要保证原子性，也就是事务中的操作要么全部完成，要么什么也不做。但有时候事务执行到一半会出现一些情况，比如：

   情况一：事务执行过程中可能遇到各种错误，比如服务器本身的错误， 操作系统错误 ，甚至是突然断电导致的错误。
   情况二：程序员可以在事务执行过程中手动输入 ROLLBACK 语句结束当前事务的执行。

2. 以上情况出现，我们需要把数据改回原先的样子，这个过程称之为回滚，这样就可以造成一个假象：这个事务看起来什么都没做，所以符合原子性要求。

3. 每当我们要对一条记录做改动时（这里的改动可以指 INSERT、DELETE、UPDATE，不包括 SELECT），都需要"留一手"——即把回滚时所需的东西记下来。比如：

   你插入一条记录时，至少要把这条记录的主键值记下来，之后回滚的时候只需要把这个主键值对应的记录删掉就好了。(对于每个INSERT，InnoDB 存储引擎会完成一个DELETE）
   你删除了一条记录，至少要把这条记录中的内容都记下来，这样之后回滚时再把由这些内容组成的记录插入到表中就好了。（对于每个DELETE，InnoDB 存储引擎会执行一个 INSERT）
   你修改了一条记录，至少要把修改这条记录前的旧值都记录下来，这样之后回滚时再把这条记录更新为旧值就好了。（对于每个UPDATE，InnoDB 存储引擎会执行一个相反的 UPDATE，将修改前的行放回去）

4. MySQL 把这些为了回滚而记录的这些内容称之为撤销日志或者回滚日志（即 undo log）。**注意，由于查询操作 (SELECT) 并不会修改任何用户记录，所以在查询操作执行时，并不需要记录相应的 undo 日志。此外，undo log 会产生 redo log，也就是 undo log 的产生会伴随着 redo log 的产生，这是因为 undo log 也需要持久性的保护。**

### undo日志作用

#### 1. 回滚数据

① 用户对 undo 日志可能有误解：undo 用于将数据库物理地恢复到执行语句或事务之前的样子。但事实并非如此。undo 是逻辑日志，因此只是将数据库逻辑地恢复到原来的样子。所有修改都被逻辑地取消了，但是数据结构和页本身在回滚之后可能大不相同。

② 这是因为在多用户并发系统中，可能会有数十、数百甚至数千个并发事务。数据库的主要任务就是协调对数据记录的并发访问。比如，一个事务在修改当前一个页中某几条记录，同时还有别的事务在对同一个页中另几条记录进行修改。因此，不能将一个页回滚到事务开始的样子，因为这样会影响其他事务正在进行的工作。

#### 2. MVCC

undo 的另一个作用是 MVCC（多版本并发控制），即在 InnoDB 存储引擎中 MVCC 的实现是通过 undo 来完成。当用户读取一行记录时，若该记录已经被其他事务占用，当前事务可以通过 undo 读取之前的行版本信息，以此实现非锁定读取。

### undo 存储结构

#### 回滚段与 undo 页

1. InnoDB 对 undo log 的管理采用段的方式，也就是回滚段 (rollback segment)。每个回滚段记录了 1024 个 undo log segment，而在每个undo log segment 段中进行 undo 页的申请。

   - 在 InnoDB1.1版本之前（不包括1.1版本），只有一个 rollback segment，因此支持同时在线的事务限制为 1024 。虽然对绝大多数的应用来说都已经够用。
   - 从 1.1 版本开始 InnoDB 支持最大 128 个 rollback segment ，故其支持同时在线的事务限制提高到了 128*1024 。

   ```sql
    show variables like 'innodb_undo_logs';  -- 查看回滚段
   ```

2. 虽然 InnoDB 1.1 版本支持了 128 个 rollback segment，但是这些 rollback segment 都存储于共享表空间 ibdata 中。从 InnoDB1.2 版本开始，可通过参数对 rollback segment 做进一步的设置。这些参数包括：

   - innodb_undo_directory：设置 rollback segment 文件所在的路径。这意味着 rollback segment 可以存放在共享表空间以外的位置，即可以设置为独立表空间。该参数的默认值为 “./”，表示当前 InnoDB 存储引擎的目录。
   - innodb_undo_logs：设置 rollback segment 的个数，默认值为 128。在 InnoDB 1.2 版本中，该参数用来替换之前版本的参数 innodb_rollback_segments。
   - innodb_undo_tablespaces：设置构成 rollback segment 文件的数量，这样 rollback segment 可以较为平均地分布在多个文件中。设置该参数后，会在路径 innodb_undo_directory 看到 undo 为前缀的文件，该文件就代表 rollback segment 文件。

   > 注意：undo log 相关参数一般很少改动。

3. undo 页的重用

   ① 当我们开启一个事务需要写 undo log 的时候，就得先去 undo log segment 中去找到一个空闲的位置，当有空位的时候，就去申请 undo页，在这个申请到的 undo 页中进行 undo log 的写入。我们知道 MySQL 默认一页的大小是 16k。

   ② 为每一个事务分配一个页，是非常浪费的（除非你的事务非常长），假设你的应用的 TPS（每秒处理的事务数目）为1000，那么 1s 就需要 1000 个页，大概需要 16M 的存储，1 分钟大概需要 1G 的存储。如果照这样下去除非 MySQL 清理的非常勤快，否则随着时间的推移，磁盘空间会增长的非常快，而且很多空间都是浪费的。

   ③ 于是 undo 页就被设计的可以重用了，当事务提交时，并不会立刻删除 undo 页。因为重用，所以这个 undo 页可能混杂着其他事务的undo log。undo log 在 commit 后，会被放到一个链表中，然后判断 undo 页的使用空间是否小于 3/4，如果小于 3/4 的话，则表示当前的undo 页可以被重用，那么它就不会被回收，其他事务的 undo log 可以记录在当前 undo 页的后面。由于 undo log 是离散的，所以清理对应的磁盘空间时，效率不高。

#### 回滚段与事务

（1）每个事务只会使用一个回滚段，一个回滚段在同一时刻可能会服务于多个事务。
（2）当一个事务开始的时候，会制定一个回滚段，在事务进行的过程中，当数据被修改时，原始的数据会被复制到回滚段。
（3）在回滚段中，事务会不断填充盘区，直到事务结束或所有的空间被用完。如果当前的盘区不够用，事务会在段中请求扩展下一个盘区，如果所有已分配的盘区都被用完，事务会覆盖最初的盘区或者在回滚段允许的情况下扩展新的盘区来使用。
（4）回滚段存在于undo表空间中，在数据库中可以存在多个 undo 表空间，但同一时刻只能使用一个 undo 表空间。
（5）当事务提交时，InnoDB 存储引擎会做以下两件事情：
		① 将 undo log 放入列表中，以供之后的 purge 操作
		② 判断 undo log 所在的页是否可以重用，若可以分配给下个事务使用

#### 回滚段中的数据分类

（1）未提交的回滚数据 (uncommitted undo information)
		该数据所关联的事务并未提交，用于实现读一致性，所以该数据不能被其他事务的数据覆盖。

（2）已经提交但未过期的回滚数据 (committed undo information)
		该数据关联的事务已经提交，但是仍受到 undo retention 参数的保持时间的影响。

（3）事务已经提交并过期的数据 (expired undo information)
		事务已经提交，而且数据保存时间已经超过 undo retention 参数指定的时间，属于已经过期的数据。当回滚段满了之后，会优先覆盖"事务已经提交并过期的		数据"。

事务提交后并不能马上删除 undo log 及 undo log 所在的页。这是因为可能还有其他事务需要通过 undo log 来得到行记录之前的版本。所以事务提交时将 undo log 放入一个链表中，是否可以最终删除 undo log 及 undo log 所在页由 purge 线程来判断。

### undo 类型

在 InnoDB 存储引擎中，undo log 分为：

- insert undo log
  insert undo log 是指在 insert 操作中产生的 undo log。因为 insert 操作的记录，只对事务本身可见，对其他事务不可见（这是事务隔离性的要求），故该
- undo log 可以在事务提交后直接删除。不需要进行 purge 操作。
  update undo log 记录的是对 delete 和 update 操作产生的 undo log。该 undo log 可能需要提供 MVCC 机制，因此不能在事务提交时就进行删除。提交时放入 undo log 链表，等待 purge 线程进行最后的删除。

### undo log生命周期

#### 1. 简要生成过程

1. 以下是 undo + redo 事务的简化过程，假设有 2 个数值，分别为 A = 1 和 B = 2，然后将 A 修改为 ，B 修改为 4。

```sql
1. start transaction;
2. 记录 A = 1 到 undo log;
3. update A = 3;
4. 记录 A = 3 到 redo log;
5. 记录 B = 2 到 undo log;
6. update B =4;
7. 记录 B = 4 到 redo log;
8. 将 redo log 刷新到磁盘;
9. commit;

在 1 ~ 8 步骤的任意一步系统宕机，事务未提交，该事务就不会对磁盘上的数据做任何影响。
如果在 8 ~ 9 之间宕机，恢复之后可以选择回滚，也可以选择继续完成事务提交
因为此时 redo log 已经持久化。若在 9 之后系统宕机，内存映射中变更的数据还来不及刷回磁盘，那么系统恢复之后，可以根据 redo log 把数据刷回磁盘。

```

2. 只有 Buffer Pool 的流程

![image-20230615225544823](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615225544823.png)

3. 有了Redo Log和Undo Log之后

![image-20230615225613381](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615225613381.png)

在更新 Buffer Pool 中的数据之前，我们需要先将该数据事务开始之前的状态写入 Undo Log 中。假设更新到一半出错了，我们就可以通过 Undo Log 来回滚到事务开始前。

#### 2. 详细生成过程

2.1 对于 InnoDB 引擎来说，每个行记录除了记录本身的数据之外，还有几个隐藏的列：
	① DB_ROW_ID∶如果没有为表显式地定义主键，并且表中也没有定义唯一索引，那么 InnoDB 会自动为表添加一个 row_id 的隐藏列作为主键。
	② DB_TRX_ID：每个事务都会分配一个事务 ID，当对某条记录发生变更时，就会将这个事务的事务 ID 写入 trx_id 中。

![image-20230615225653533](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615225653533.png)

2.2 当执行 INSERT 操作时：

```sql
begin; 
INSERT INTO user (name) VALUES ("tom");
```

入的数据都会生成一条 insert undo log，并且数据的回滚指针会指向它。undo log 会记录 undo log 的序号、插入主键的列和值…，那么在进行 rollback 的时候，通过主键直接把对应的数据删除即可。

![image-20230615225738645](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615225738645.png)

2.3 当执行 UPDATE 操作时：

对于更新的操作会产生 update undo log，并且会分更新主键的和不更新主键的，假设现在执行：

```sql
UPDATE user SET name= "Sun" WHERE id = 1;
```

 ![image-20230615225822374](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615225822374.png)

这时会把老的记录写入新的 undo log，让回滚指针指向新的 undo log，它的 undo no 是 1，并且新的 undo log 会指向老的 undo log (undo no = 0)。假设现在执行：

```sql
UPDATE user SET id=2 WHERE id=1;
```

对于更新主键的操作，会先把原来的数据 deletemark 标识打开，这时并没有真正的删除数据，真正的删除会交给清理线程去判断，然后在后面插入一条新的数据，新的数据也会产生 undo log，并且 undo log 的序号会递增。

可以发现每次对数据的变更都会产生一个 undo log，当一条记录被变更多次时，那么就会产生多条 undo log，undo log 记录的是变更前的日志，并且每个 undo log 的序号是递增的，那么当要回滚的时候，按照序号依次向前推，就可以找到我们的原始数据了。

### undo log 是如何回滚的

以上面的例子来说，假设执行 rollback，那么对应的流程应该是这样：
（1）通过 undo no = 3 的日志把 id = 2 的数据删除；
（2）通过 undo no = 2 的日志把 id= 1 的数据的 deletemark 还原成 0；
（3）通过 undo no = 1 的日志把 id = 1 的数据的 name 还原成 Tom；
（4）通过 undo no = 0 的日志把 id = 1 的数据删除；

### undo log 的删除

1. 针对于 insert undo log
   因为 insert 操作的记录，只对事务本身可见，对其他事务不可见。故该 undo log 可以在事务提交后直接删除，不需要进行 purge 操作。

2. 针对于update undo log
   该 undo log 可能需要提供 MVCC 机制，因此不能在事务提交时就进行删除。提交时放入 undo log 链表，等待 purge 线程进行最后的删除。

> 补充：purge 线程两个主要作用是清理 undo 页和清除 page 里面带有 Delete_Bit 标识的数据行。在 InnoDB 中，事务中的 Delete 操作实际上并不是真正的删除掉数据行，而是一种 Delete Mark 操作，在记录上标识 Delete_Bit，而不删除记录。是一种"假删除"，只是做了个标记，真正的删除工作需要后台 purge 线程去完成。

**小结:**

1. undo log 是**逻辑日志**，对事务回滚时，只是将数据库逻辑地恢复到原来的样子。
2. redo log 是**物理日志**，记录的是数据页的物理变化，undo log 不是 redo log 的逆过程。



![image-20230615222250260](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230615222250260.png)










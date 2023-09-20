---
title: "通用mapper"
date: 2023-09-16T20:21:08+08:00
lastmod: 2023-09-16T20:21:08+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- MyBatis
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

# 通用MapperMBG

`pom.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.nq</groupId>
  <artifactId>MapperMBG</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <maven.compiler.source>8</maven.compiler.source>
    <maven.compiler.target>8</maven.compiler.target>
    <!--  basedir引用工程目录-->
    <!--  targetJavaProject: 声明存放源码的目录位置-->
    <targetJavaProject>${basedir}/src/main/java</targetJavaProject>
    <!--  targetMapperPackage: 声明存放mapper接口的package位置-->
    <targetMapperPackage>com.nq.user.mapper</targetMapperPackage>
    <!--  targetModelPackage: 声明存放实体类位置-->
    <targetModelPackage>com.nq.user.entity</targetModelPackage>
    <!--  targetResourcesProject 声明存放资源文件的目录位置-->
    <targetResourcesProject>${basedir}/src/main/resources</targetResourcesProject>
    <!--  targetXMLPackage 声明存放mapper xml文件的目录位置 多层文件写法com/nq/mapper-->
    <targetXMLPackage>mappers</targetXMLPackage>
    <!--  通用mapper版本号  -->
    <mapper.version>4.1.5</mapper.version>
    <!--  mysql驱动版本号  -->
    <mysql.version>5.1.46</mysql.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>tk.mybatis</groupId>
      <artifactId>mapper</artifactId>
      <version>${mapper.version}</version>
    </dependency>
    <dependency>
      <groupId>org.mybatis</groupId>
      <artifactId>mybatis</artifactId>
      <version>3.2.8</version>
    </dependency>
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <version>${mysql.version}</version>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.mybatis.generator</groupId>
        <artifactId>mybatis-generator-maven-plugin</artifactId>
        <version>1.3.2</version>
        <!--配置generatorConfig.xml文件的路径-->
        <configuration>
          <configurationFile>${basedir}/src/main/resources/generator/generatorConfig.xml</configurationFile>
          <overwrite>true</overwrite>
          <verbose>true</verbose>
        </configuration>
        <!--配置MBG插件依赖信息-->
        <dependencies>
          <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>${mysql.version}</version>
          </dependency>
          <dependency>
            <groupId>tk.mybatis</groupId>
            <artifactId>mapper</artifactId>
            <version>${mapper.version}</version>
          </dependency>
        </dependencies>
      </plugin>
    </plugins>
  </build>
</project>
```

`jdbc.properties`

```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3307/my_dev?characterEncoding=utf8
jdbc.user=root
jdbc.password=ningqiang
```

`mybatis-config.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

 <!-- 引入外部属性文件 -->
 <properties resource="jdbc.properties"/>
 
 <!-- 配置MyBatis运行环境 -->
 <environments default="development">
  <!-- 配置专门用于开发过程的运行环境 -->
  <environment id="development">
   <!-- 配置事务管理器 -->
   <transactionManager type="JDBC"/>
   <!-- 配置数据源 -->
   <dataSource type="POOLED">
    <property name="username" value="${jdbc.user}"/>
    <property name="password" value="${jdbc.password}"/>
    <property name="driver" value="${jdbc.driver}"/>
    <property name="url" value="${jdbc.url}"/>
   </dataSource>
  </environment>
 </environments>
 
 <mappers>
  <package name="com.nq.user.mapper"/>
 </mappers>

</configuration>
```

`config.properties`

```properties
# 数据库配置
jdbc.driverClass=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3307/my_dev?characterEncoding=utf8
jdbc.user=root
jdbc.password=ningqiang
table.name=sample_table

#c3p0
jdbc.maxPoolSize=50
jdbc.minPoolSize=10
jdbc.maxStatements=100
jdbc.testConnection=true

# 通用Mapper配置
mapper.plugin=tk.mybatis.mapper.generator.MapperPlugin
## 指定Mapper
mapper.Mapper=tk.mybatis.mapper.common.Mapper
```

`generatorConfig.xml`

```java
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
  PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
  "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">

<generatorConfiguration>
  <!-- 引入外部配置文件 -->
  <properties resource="generator/config.properties"/>

  <context id="Mysql" targetRuntime="MyBatis3Simple" defaultModelType="flat">
    <property name="beginningDelimiter" value="`"/>
    <property name="endingDelimiter" value="`"/>

    <!-- 引入外部配置文件 -->
    <plugin type="${mapper.plugin}">
      <property name="mappers" value="${mapper.Mapper}"/>
    </plugin>

    <!-- 数据库 -->
    <jdbcConnection driverClass="${jdbc.driverClass}"
      connectionURL="${jdbc.url}"
      userId="${jdbc.user}"
      password="${jdbc.password}">
    </jdbcConnection>

    <!--java实体类-->
    <javaModelGenerator targetPackage="${targetModelPackage}" targetProject="${targetJavaProject}"/>

    <!--mapper文件-->
    <sqlMapGenerator targetPackage="${targetXMLPackage}"  targetProject="${targetResourcesProject}"/>

    <!--mapper接口-->
    <javaClientGenerator targetPackage="${targetMapperPackage}" targetProject="${targetJavaProject}" type="XMLMAPPER" />

    <!--数据库表-->
  <!-- tableName="%" 表示所有表的生成 使用默认规则 默认规则：table_dept -->
    <table tableName="${table.name}" >
      <!--配置主键生成策略 ,默认id-->
      <generatedKey column="id" sqlStatement="Mysql" identity="true"/>
    </table>
  </context>
</generatorConfiguration>
```

```ABAP
mvn mybatis-generator:generate
```

# 项目地址

https://github.com/AlfredNing/Coding/tree/main/MapperMBG
---
title: "Mybatis_generator"
date: 2023-09-03T08:44:09+08:00
lastmod: 2023-09-03T08:44:09+08:00
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

# Mybatis-Generator

# 生成方式

- 命令行
- maven插件
- 使用图形化

## 运行过程

1. 连接数据库
2. 从数据库元数据
3. 生成文件

## 问题

下划线和驼峰法命名，不加设置下划线自动转驼峰

## maven插件生成

`pom.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.nq</groupId>
  <artifactId>mybatis_generator</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <maven.compiler.source>8</maven.compiler.source>
    <maven.compiler.target>8</maven.compiler.target>
  </properties>

  <build>
    <plugins>
      <plugin>
        <groupId>org.mybatis.generator</groupId>
        <artifactId>mybatis-generator-maven-plugin</artifactId>
        <version>1.4.2</version>
        <dependencies>
          <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.1.46</version>
          </dependency>
        </dependencies>
        <configuration>
          <!--指定生成文件-->
          <configurationFile>src/main/resources/generator/generatorConfig.xml</configurationFile>
          <!--If true, then MBG will write progress messages to the build log.-->
          <verbose>true</verbose>
<!--          If true, then existing Java files will be overwritten if an existing Java file if found with the same name as a generated file. If not specified, and a Java file already exists with the same name as a generated file-->
          <overwrite>true</overwrite>
        </configuration>
        <executions>
          <execution>
            <id>Generate MyBatis Artifacts</id>
            <goals>
              <goal>generate</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>

</project>
```





`generator/generatorConfig.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
  PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
  "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>

  <!--配置文件 占位符读取-->
  <properties resource="generator/db.properties"/>
  <context id="default" targetRuntime="MyBatis3">
    <!--jdbc连接-->
    <jdbcConnection driverClass="${jdbc.driver}"
      connectionURL="${jdbc.url}"
      userId="${jdbc.username}"
      password="${jdbc.password}">
    </jdbcConnection>

    <!--不强制把所有的数字类型转化为BigDecimal -->
    <javaTypeResolver>
      <property name="forceBigDecimals" value="false"/>
    </javaTypeResolver>

    <!--生成model类所在位置-->
    <javaModelGenerator targetPackage="com.nq.entity" targetProject="src/main/java">
      <property name="enableSubPackages" value="true"/>
      <!--Setter方法是否对字符串类型进行一次trim操作-->
      <property name="trimStrings" value="true"/>
    </javaModelGenerator>

    <!--mapper文件-->
    <sqlMapGenerator targetPackage="mapper" targetProject="src/main/resources/">
      <property name="enableSubPackages" value="true"/>
    </sqlMapGenerator>

    <!--生成dao所在位置-->
    <javaClientGenerator type="XMLMAPPER" targetPackage="com.nq.dao" targetProject="src/main/java">
      <property name="enableSubPackages" value="true"/>
    </javaClientGenerator>

    <!--对应表名及类名-->
    <table tableName="${table.name}"
      enableCountByExample="false"
      enableDeleteByExample="false"
      enableSelectByExample="false"
      enableUpdateByExample="false"
      domainObjectName="SampleTable"
      mapperName="OrderMapper">
      <!--      <property name="useActualColumnNames" value="true"/>-->
      <generatedKey column="id" sqlStatement="MySql" identity="true"/>

      <!--      <columnOverride column="DATE_FIELD" property="startDate" />-->
      <!--      <ignoreColumn column="FRED" />-->
      <!--      <columnOverride column="LONG_VARCHAR_FIELD" jdbcType="VARCHAR" />-->
    </table>
  </context>
</generatorConfiguration>
```

`generator/db.properties`

```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3307/my_dev?characterEncoding=utf8
jdbc.username=root
jdbc.password=root

table.name=sample_table
```

![image-20230903105654730](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230903105654730.png)

**注意这里如果有自定义类型转换的话，需要打包到插件中**

## 代码生成 

需要额外引入依赖，pom进行调整

`pom.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.nq</groupId>
  <artifactId>mybatis_generator</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <maven.compiler.source>8</maven.compiler.source>
    <maven.compiler.target>8</maven.compiler.target>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.mybatis.generator</groupId>
      <artifactId>mybatis-generator-core</artifactId>
      <version>1.4.2</version>
    </dependency>
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <version>5.1.46</version>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.mybatis.generator</groupId>
        <artifactId>mybatis-generator-maven-plugin</artifactId>
        <version>1.4.2</version>
        <configuration>
          <!--指定生成文件-->
          <configurationFile>src/main/resources/generator/generatorConfig.xml</configurationFile>
          <!--If true, then MBG will write progress messages to the build log.-->
          <verbose>true</verbose>
          <!--          If true, then existing Java files will be overwritten if an existing Java file if found with the same name as a generated file. If not specified, and a Java file already exists with the same name as a generated file-->
          <overwrite>true</overwrite>
        </configuration>
        <executions>
          <execution>
            <id>Generate MyBatis Artifacts</id>
            <goals>
              <goal>generate</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>

</project>
```

`执行类`

```java
package mybatis_gen;

import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import org.mybatis.generator.api.MyBatisGenerator;
import org.mybatis.generator.config.Configuration;
import org.mybatis.generator.config.xml.ConfigurationParser;
import org.mybatis.generator.internal.DefaultShellCallback;

/**
 * MyBaits生成运行
 *
 * @author Alfred.Ning
 * @since 2023年09月03日 10:58:00
 */
public class MybatisGeneratorMain {

  public static void main(String[] args) throws Exception {
    List<String> warnings = new ArrayList<String>();
    // 如果已经存在生成过的文件是否进行覆盖
    boolean overwrite = true;
    Properties properties = new Properties();
    properties.load(MybatisGeneratorMain.class.getClassLoader().getResourceAsStream("generator/db.properties"));
    ConfigurationParser cp = new ConfigurationParser(properties,warnings);
    Configuration config = cp.parseConfiguration(MybatisGeneratorMain.class.getClassLoader().getResourceAsStream("generator/generatorConfig.xml"));
    DefaultShellCallback callback = new DefaultShellCallback(overwrite);
    MyBatisGenerator myBatisGenerator = new MyBatisGenerator(config, callback, warnings);
    myBatisGenerator.generate(null);
  }
}
class c{

}
```

### 优化

- 注释简化
- 自定义类型，例如：smallInt -> Int

#### `注释简化类`

```java
package mybatis_gen;

import static org.mybatis.generator.internal.util.StringUtility.isTrue;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.Set;
import org.mybatis.generator.api.CommentGenerator;
import org.mybatis.generator.api.IntrospectedColumn;
import org.mybatis.generator.api.IntrospectedTable;
import org.mybatis.generator.api.MyBatisGenerator;
import org.mybatis.generator.api.dom.java.CompilationUnit;
import org.mybatis.generator.api.dom.java.Field;
import org.mybatis.generator.api.dom.java.FullyQualifiedJavaType;
import org.mybatis.generator.api.dom.java.InnerClass;
import org.mybatis.generator.api.dom.java.InnerEnum;
import org.mybatis.generator.api.dom.java.Method;
import org.mybatis.generator.api.dom.java.TopLevelClass;
import org.mybatis.generator.api.dom.xml.XmlElement;
import org.mybatis.generator.config.Configuration;
import org.mybatis.generator.config.PropertyRegistry;
import org.mybatis.generator.config.xml.ConfigurationParser;
import org.mybatis.generator.internal.DefaultShellCallback;
import org.mybatis.generator.internal.util.StringUtility;

/**
 * 注释简化
 *
 * @author Alfred.Ning
 * @since 2023年09月03日 11:31:00
 */
public class MyCommentGenerator implements CommentGenerator {


  private Properties properties;

  private boolean suppressDate;

  private boolean suppressAllComments;

  /**
   * If suppressAllComments is true, this option is ignored.
   */
  private boolean addRemarkComments;

  private SimpleDateFormat dateFormat;

  public MyCommentGenerator() {
    super();
    properties = new Properties();
    suppressDate = false;
    suppressAllComments = false;
    addRemarkComments = false;
  }

  /**
   * 默认配置
   *
   * @param properties
   */
  @Override
  public void addConfigurationProperties(Properties properties) {
    this.properties.putAll(properties);

    suppressDate = isTrue(properties
        .getProperty(PropertyRegistry.COMMENT_GENERATOR_SUPPRESS_DATE));

    suppressAllComments = isTrue(properties
        .getProperty(PropertyRegistry.COMMENT_GENERATOR_SUPPRESS_ALL_COMMENTS));

    addRemarkComments = isTrue(properties
        .getProperty(PropertyRegistry.COMMENT_GENERATOR_ADD_REMARK_COMMENTS));

    String dateFormatString = properties.getProperty(PropertyRegistry.COMMENT_GENERATOR_DATE_FORMAT);
    if (StringUtility.stringHasValue(dateFormatString)) {
      dateFormat = new SimpleDateFormat(dateFormatString);
    }
  }

  /**
   * 实体类添加的注释
   *
   * @param topLevelClass
   * @param introspectedTable
   */
  @Override
  public void addModelClassComment(TopLevelClass topLevelClass,
      IntrospectedTable introspectedTable) {
    if (suppressAllComments || !addRemarkComments) {
      return;
    }

    topLevelClass.addJavaDocLine("/**"); //$NON-NLS-1$
    String remarks = introspectedTable.getRemarks();
    if (addRemarkComments && StringUtility.stringHasValue(remarks)) {
      String[] remarkLines = remarks.split(System.getProperty("line.separator"));
      for (String remarkLine : remarkLines) {
        topLevelClass.addJavaDocLine(" * " + remarkLine);  //$NON-NLS-1$
      }
    }
    topLevelClass.addJavaDocLine(" *");
    topLevelClass.addJavaDocLine(" * create by Alfred.Ning");
    topLevelClass.addJavaDocLine(" * " + introspectedTable.getFullyQualifiedTable().toString());
    topLevelClass.addJavaDocLine(" */");
    topLevelClass.addJavaDocLine("@Data");
  }

  /**
   * 实体类的属性注释，数据库中自定义注释
   *
   * @param field
   * @param introspectedTable
   * @param introspectedColumn
   */
  @Override
  public void addFieldComment(Field field,
      IntrospectedTable introspectedTable,
      IntrospectedColumn introspectedColumn) {
    if (suppressAllComments) {
      return;
    }
    field.addJavaDocLine("/**"); //$NON-NLS-1$
    String remarks = introspectedColumn.getRemarks();
    if (addRemarkComments && StringUtility.stringHasValue(remarks)) {
      String[] remarkLines = remarks.split(System.getProperty("line.separator"));  //$NON-NLS-1$
      for (String remarkLine : remarkLines) {
        field.addJavaDocLine(" * " + remarkLine);  //$NON-NLS-1$
      }
    }
    field.addJavaDocLine(" */"); //$NON-NLS-1$
  }

  @Override
  public void addFieldComment(Field field, IntrospectedTable introspectedTable) {
    if (suppressAllComments) {
      return;
    }
    StringBuilder sb = new StringBuilder();
    field.addJavaDocLine("/**"); //$NON-NLS-1$
    sb.append(introspectedTable.getFullyQualifiedTable());
    field.addJavaDocLine(" */"); //$NON-NLS-1$
  }


  @Override
  public void addGeneralMethodComment(Method method, IntrospectedTable introspectedTable) {
  }


  @Override
  public void addClassComment(InnerClass innerClass, IntrospectedTable introspectedTable) {

  }

  @Override
  public void addClassComment(InnerClass innerClass, IntrospectedTable introspectedTable, boolean markAsDoNotDelete) {
  }

  @Override
  public void addEnumComment(InnerEnum innerEnum, IntrospectedTable introspectedTable) {
  }

  // 不需要get方法的注释
  @Override
  public void addGetterComment(Method method, IntrospectedTable introspectedTable,
      IntrospectedColumn introspectedColumn) {
  }

  // 不需要set方法的注释
  @Override
  public void addSetterComment(Method method, IntrospectedTable introspectedTable,
      IntrospectedColumn introspectedColumn) {
  }

  @Override
  public void addGeneralMethodAnnotation(Method method, IntrospectedTable introspectedTable,
      Set<FullyQualifiedJavaType> imports) {
  }

  @Override
  public void addGeneralMethodAnnotation(Method method, IntrospectedTable introspectedTable,
      IntrospectedColumn introspectedColumn, Set<FullyQualifiedJavaType> imports) {
  }

  @Override
  public void addFieldAnnotation(Field field, IntrospectedTable introspectedTable,
      Set<FullyQualifiedJavaType> imports) {

  }

  @Override
  public void addFieldAnnotation(Field field, IntrospectedTable introspectedTable,
      IntrospectedColumn introspectedColumn, Set<FullyQualifiedJavaType> imports) {
  }

  @Override
  public void addClassAnnotation(InnerClass innerClass, IntrospectedTable introspectedTable,
      Set<FullyQualifiedJavaType> imports) {
  }

  @Override
  public void addComment(XmlElement xmlElement) {

  }

  @Override
  public void addRootComment(XmlElement rootElement) {
  }

  @Override
  public void addJavaFileComment(CompilationUnit compilationUnit) {
  }
}
```

####  `类型转换`默认实现类 `JavaTypeResolverDefaultImpl`

```java
package mybatis_gen;

import java.sql.Types;
import org.mybatis.generator.api.dom.java.FullyQualifiedJavaType;
import org.mybatis.generator.internal.types.JavaTypeResolverDefaultImpl;

/**
 * 类型转换
 * @author Alfred.Ning
 * @since 2023年09月03日 11:14:00
 */
public class DefaultJavaTypeResolver extends JavaTypeResolverDefaultImpl {

  public DefaultJavaTypeResolver() {
    super();
    typeMap.put(Types.SMALLINT, new JdbcTypeInformation("SMALLINT",
        new FullyQualifiedJavaType(Integer.class.getName())));
    typeMap.put(Types.TINYINT, new JdbcTypeInformation("TINYINT",
        new FullyQualifiedJavaType(Integer.class.getName())));
  }

}
```

####  配置文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
  PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
  "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>

  <!--配置文件 占位符读取-->
  <properties resource="generator/db.properties"/>
  <context id="default" targetRuntime="MyBatis3">
    <commentGenerator type="mybatis_gen.MyCommentGenerator">
      <!--是否生成注释-->
      <property name="suppressAllComments" value="false"/>
      <!--是否输出表和列的Comment信息-->
      <property name="addRemarkComments" value="true"/>
      <!--是否在注释中添加生成的时间戳-->
      <property name="suppressDate" value="true"/>
    </commentGenerator>

    <!--jdbc连接-->
    <jdbcConnection driverClass="${jdbc.driver}"
      connectionURL="${jdbc.url}"
      userId="${jdbc.username}"
      password="${jdbc.password}">
    </jdbcConnection>
    <!--不强制把所有的数字类型转化为BigDecimal -->
    <javaTypeResolver type="mybatis_gen.DefaultJavaTypeResolver">
      <property name="forceBigDecimals" value="false"/>
    </javaTypeResolver>

    <!--生成model类所在位置-->
    <javaModelGenerator targetPackage="com.nq.entity" targetProject="src/main/java">
      <property name="enableSubPackages" value="true"/>
      <!--Setter方法是否对字符串类型进行一次trim操作-->
      <property name="trimStrings" value="true"/>
    </javaModelGenerator>

    <!--mapper文件-->
    <sqlMapGenerator targetPackage="mapper" targetProject="src/main/resources/">
      <property name="enableSubPackages" value="true"/>
    </sqlMapGenerator>

    <!--生成dao所在位置-->
    <javaClientGenerator type="XMLMAPPER" targetPackage="com.nq.dao" targetProject="src/main/java">
      <property name="enableSubPackages" value="true"/>
    </javaClientGenerator>

    <!--对应表名及类名-->
    <table tableName="${table.name}"
      enableCountByExample="false"
      enableDeleteByExample="false"
      enableSelectByExample="false"
      enableUpdateByExample="false"
      domainObjectName="SampleTable">
      <!--      <property name="useActualColumnNames" value="true"/>-->
      <generatedKey column="id" sqlStatement="MySql" identity="true"/>

      <!--      <columnOverride column="DATE_FIELD" property="startDate" />-->
      <!--      <ignoreColumn column="FRED" />-->
      <!--      <columnOverride column="LONG_VARCHAR_FIELD" jdbcType="VARCHAR" />-->
    </table>
  </context>
</generatorConfiguration>
```

#### properties文件

```xml
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3307/my_dev?characterEncoding=utf8
jdbc.username=root
jdbc.password=ningqiang

table.name=sample_table
```

#### Main类

```java
package mybatis_gen;

import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import org.mybatis.generator.api.MyBatisGenerator;
import org.mybatis.generator.config.Configuration;
import org.mybatis.generator.config.xml.ConfigurationParser;
import org.mybatis.generator.internal.DefaultShellCallback;

/**
 * MyBaits生成运行
 *
 * @author Alfred.Ning
 * @since 2023年09月03日 10:58:00
 */
public class MybatisGeneratorMain {

  public static void main(String[] args) throws Exception {
    List<String> warnings = new ArrayList<String>();
    // 如果已经存在生成过的文件是否进行覆盖
    boolean overwrite = true;
    Properties properties = new Properties();
    properties.load(MybatisGeneratorMain.class.getClassLoader().getResourceAsStream("generator/db.properties"));
    ConfigurationParser cp = new ConfigurationParser(properties,warnings);
    Configuration config = cp.parseConfiguration(MybatisGeneratorMain.class.getClassLoader().getResourceAsStream("generator/generatorConfig.xml"));
    DefaultShellCallback callback = new DefaultShellCallback(overwrite);
    MyBatisGenerator myBatisGenerator = new MyBatisGenerator(config, callback, warnings);
    myBatisGenerator.generate(null);
  }
}
```



## 大杀器 -  MyBatisX

1. 安装MyBatisX 插件
2. ![image-20230903115554216](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230903115554216.png)
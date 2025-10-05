---
title: "Mockito使用"
date: 2025-10-05T21:54:02+08:00
lastmod: 2025-10-05T21:54:02+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- Mockito
tags: # 标签
- Mockito
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
# Mockito概述
## 什么是Mockito
Java单元测试的模拟框架, 例如链接数据库，下载文件，或者调用某个外部服务等等一系列单元测试。
## 为什么需要 Mockito
**测试驱动开发**(TDD)要求我们先写单元测试，在写单元测试的过程中，有很多类是具有依赖的关系，我们需要构建出完整的依赖关系，衍生出了很多的测试框架，**Mockito**便是其中的一种。
## Mockito的核心概念
### Mock

创建一个对象的模拟实例，该实例不是真实对象，但可以模拟对象的行为
- 所有方法默认返回空值（null/0/false）或空集合
- 不会执行真实方法逻辑
- 可以记录方法的调用情况
### Stub
**方法存根**
是指定mock对象在特定条件下如何响应的方法配置
- 自定义方法的返回值
- 可以模拟方法抛出异常
- 基于不同参数做到不同响应

### SPY
Spy是部分真实的对象，默认会调用真实的方法，但可以针对特定方法进行存根
- 基于真实对象创建
- 默认调用真实方法
- 可以选择性的模拟某些方法
- 比mock更接近真实对象
### Verify
用于验证mock对象的方法是否按照预期被调用
- 可以验证方法是否被调用
- 可以验证调用次数和顺序
- 可以验证方法参数

## 总结
| 概念     | 特点                      | 主要用途                  |
| ------ | ----------------------- | --------------------- |
| Mock   | 完全模拟对象，所有方法默认不执行真实逻辑    | 替代难以构造或使用的真实依赖        |
| Stub   | 定义方法调用的响应行为             | 控制依赖组件的行为，模拟各种返回值和异常  |
| Spy    | 部分真实对象，默认调用真实方法，可选择性地模拟 | 当需要大部分真实行为，只修改少量方法时使用 |
| Verify | 验证方法是否按预期被调用            | 确保被测对象与依赖组件的交互符合预期    |


# 环境搭建
## maven配置
maven配置，springboot应用

```xml
<dependency>  
    <groupId>org.projectlombok</groupId>  
    <artifactId>lombok</artifactId>  
    <optional>true</optional>  
</dependency>  
<dependency>  
    <groupId>org.springframework.boot</groupId>  
    <artifactId>spring-boot-starter-test</artifactId>  
    <scope>test</scope>  
</dependency>  
<dependency>  
    <groupId>org.mockito</groupId>  
    <artifactId>mockito-all</artifactId>  
    <version>1.10.19</version>  
</dependency>
```
## 第一个测试类
```java
package com.nq.mockitouse;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import static org.mockito.Mockito.*;

import org.mockito.invocation.InvocationOnMock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.stubbing.Answer;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

@ExtendWith(MockitoExtension.class)
public class ListMockTest {
    @Test
    public void mockList() {
        List list = mock(List.class);
        list.add("one");
        list.clear();

        verify(list).add("one");
        verify(list).clear();
    }

    @Test
    public void mockList2() {
        List mockedList = mock(List.class);

        when(mockedList.get(0)).thenReturn("fist");
        when(mockedList.get(1)).thenThrow(new RuntimeException());

        System.out.println(mockedList.get(0));
//        System.out.println(mockedList.get(1));

        System.out.println(mockedList.get(2));

        doThrow(new RuntimeException()).when(mockedList).clear();
        mockedList.clear();

    }

    @Test
    public void mockList3() {
        List mockedList = mock(List.class);

        when(mockedList.get(0)).thenReturn("fist").thenReturn("two").thenReturn("three");
        // 简写方式
        when(mockedList.get(0)).thenReturn("first", "second", "third");

        System.out.println(mockedList.get(0));
        System.out.println(mockedList.get(0));
        System.out.println(mockedList.get(0));
    }

    @Test
    public void mockFunc() {
        List list = mock(List.class);
        when(list.get(0)).thenAnswer(new Answer<Object>() {
            @Override
            public Object answer(InvocationOnMock invocationOnMock) throws Throwable {
                System.out.println("func call start");
                Object[] arguments = invocationOnMock.getArguments();
                System.out.println("args : " + Arrays.toString(arguments));
                Method method = invocationOnMock.getMethod();
                System.out.println("method : " + method.getName());
                return "I'm an answer";
            }
        });
        System.out.println(list.get(0));
    }
}

```
# 基础用法
## Mock对象使用
1. 原生使用
```java
   @Test  
public void testMock1() {  
    AccountDao mock = Mockito.mock(AccountDao.class);  
    Account account = mock.findAccount("admin", "admin");  
    // 这里是null 默认是null  
    System.out.println(account);
   ```

2. 注解使用
```java

    @Mock(answer = Answers.RETURNS_SMART_NULLS)
    private AccountDao accountDao;
```

3. 注解类
```java
MockitoAnnotations.openMocks(this);;
```


## Stub使用
```java
package com.nq.mockitouse;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.MockitoJUnitRunner;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;

import static org.hamcrest.CoreMatchers.*;
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class StubingTest01 {
    private List<String> list;

    @BeforeEach
    public void init() {
        this.list = mock(ArrayList.class);
    }

    // 基础测试
    @Test
    public void useStubing01() {
        when(list.get(0)).thenReturn("first");
        assertThat(list.get(0), equalTo("first"));

        when(list.get(anyInt())).thenThrow(new RuntimeException());
        try {
            list.get(0);
            fail();
        } catch (Exception e) {
            assertThat(e, instanceOf(RuntimeException.class));
        }
    }

    // 测试void 返回值
    @Test
    public void useStubVoidMethod() {
        doNothing().when(list).clear();
        // 调用
        list.clear();
        // verify
        verify(list, times(1)).clear();

        doThrow(RuntimeException.class).when(list).clear();

        assertThrows(RuntimeException.class, () -> list.clear());
    }


    // 测试return返回值
    @Test
    public void testDoReturn() {
        when(list.get(0)).thenReturn("first");
        doReturn("second").when(list).get(1);

        assertThat(list.get(0), equalTo("first"));
        assertThat(list.get(1), equalTo("second"));
    }

    // 测试迭代的stub
    @Test
    public void testStubRecursive() {
        when(list.size()).thenReturn(1)
                .thenReturn(2).thenReturn(3)
                .thenReturn(4);

        assertThat(list.size(), equalTo(1));
        assertThat(list.size(), equalTo(2));
        assertThat(list.size(), equalTo(3));
        assertThat(list.size(), equalTo(4));
    }

    // 自定义返回值
    @Test
    public void testStubingWithAnswer() {
        when(list.get(anyInt())).thenAnswer(invocationOnMock -> {
            Integer index = invocationOnMock.getArgument(0, Integer.class);
            return String.valueOf(index);
        });
        assertThat(list.get(0), equalTo("0"));
        assertThat(list.get(99), equalTo("99"));

    }

    // 测试调用真正方法
    @Test
    public void testStubRealCall() {
        StubService stubService = mock(StubService.class);
        when(stubService.getS()).thenReturn("stub");
        assertThat(stubService.getS(), equalTo("stub"));

        when(stubService.getI()).thenCallRealMethod();
        assertThat(stubService.getI(), equalTo(10));
    }

    @AfterEach
    public void destroy() {
        reset(this.list);
    }


}

class StubService {
    public int getI() {
        return 10;
    }

    public String getS() {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}


```

## SPY
```java
package com.nq.mockitouse;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.mockito.junit.MockitoJUnitRunner;

import java.util.ArrayList;
import java.util.List;


import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertThat;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

@RunWith(MockitoJUnitRunner.class)
public class SpyTest {

    // 使用注解的方式实现spy
    @Spy
    private List<String> list = new ArrayList<>();


    @Test
    public void testSpy() {
        List reayList = new ArrayList();
        List list = spy(reayList);
        list.add("Mockito");
        list.add("Spy");

        assertThat(list.get(0), equalTo("Mockito"));
        assertThat(list.get(1), equalTo("Spy"));
        assertThat(list.isEmpty(), equalTo(false));

        when(list.isEmpty()).thenReturn(true);
        when(list.size()).thenReturn(1);

        assertThat(list.isEmpty(), equalTo(true));
        assertThat(list.size(), equalTo(1));
    }

    @Test
    public void testAnnotation() {
        list.add("Mockito");
        assertThat(list.get(0), equalTo("Mockito"));
    }
}

```
## 参数验证器
测试服务类
```java
package com.nq.mockitouse.service;

import java.io.Serializable;
import java.util.Collection;

public class SimpleService {
    public int method1(int i, String str, Collection<?> c, Serializable ser) {
        throw new RuntimeException();
    }

    public void method2(int i, String str, Collection<?> c, Serializable ser) {
        throw new RuntimeException();
    }
}

```

测试类
```java
package com.nq.mockitouse;

import com.nq.mockitouse.service.SimpleService;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnitRunner;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertThrows;
import static org.mockito.ArgumentMatchers.isA;
import static org.mockito.Mockito.*;

@RunWith(MockitoJUnitRunner.class)
public class ArgumentMatchTest {

    @Mock
    private SimpleService simpleService;


    @Test
    public void testBasic() {
        List list = mock(ArrayList.class);
        when(list.get(0)).thenReturn(100);

        assertThat(list.get(0), equalTo(100));
        assertThat(list.get(1), nullValue());
    }

    // 测试isA any
    @Test
    public void testAny() {
        Foo foo = mock(Foo.class);
        when(foo.function(isA(Parent.class))).thenReturn(100);

        assertThat(foo.function(new Children1()), equalTo(100));
        assertThat(foo.function(new Children2()), equalTo(100));

        reset(foo);

        when(foo.function(Mockito.any(Parent.class))).thenReturn(100);
        assertThat(foo.function(new Children3()), equalTo(100));

        reset(foo);

        // isA 必须是它的实例 any() 任何实现
        when(foo.function(isA(Children1.class))).thenReturn(100);
        assertThat(foo.function(new Children2()), equalTo(100));
    }


    static class Foo {
        int function(Parent p) {
            return p.work();
        }
    }

    interface Parent {
        int work();
    }

    class Children1 implements Parent {
        @Override
        public int work() {
            throw new RuntimeException();
        }
    }

    class Children2 extends Children1 {
        @Override
        public int work() {
            throw new RuntimeException();
        }
    }

    class Children3 implements Parent {
        @Override
        public int work() {
            throw new RuntimeException();
        }
    }


    //===================wildcard test==============

    @Test
    public void testWildCard01() {
        when(simpleService.method1(anyInt(), anyString(), anyCollection(), isA(Serializable.class))).thenReturn(100);
        int res = simpleService.method1(1, "super", Collections.emptyList(), "Mockito");
        assertThat(res, equalTo(100));

        int res2 = simpleService.method1(1, "super", Collections.emptySet(), "Mockito");
        assertThat(res2, equalTo(100));
    }

    @Test
    public void testWildCard02() {
        // anyString 保持最前面
        when(simpleService.method1(anyInt(), anyString(), anyCollection(), isA(Serializable.class))).thenReturn(300);
        // 注意eq 如果使用wildcard 全部统一用wildcard
        when(simpleService.method1(anyInt(), eq("alex"), anyCollection(), isA(Serializable.class))).thenReturn(100);
        when(simpleService.method1(anyInt(), eq("bob"), anyCollection(), isA(Serializable.class))).thenReturn(200);
        int res = simpleService.method1(1, "alex", Collections.emptyList(), "Mockito");
        assertThat(res, equalTo(100));

        int res2 = simpleService.method1(1, "bob", Collections.emptySet(), "Mockito");
        assertThat(res2, equalTo(200));

        int res3 = simpleService.method1(1, "ctask", Collections.emptySet(), "Mockito");
        assertThat(res3, equalTo(300));
    }

    @Test
    public void testWildCard03() {
        doNothing().when(simpleService).method2(anyInt(), anyString(), anyCollection(), isA(Serializable.class));
        simpleService.method2(1, "alex", Collections.emptySet(), "Mockito");
        verify(simpleService, times(1)).method2(1, "alex", Collections.emptySet(), "Mockito");
        verify(simpleService, times(1)).method2(anyInt(), anyString(), anyCollection(), isA(Serializable.class));
    }


    @After
    public void destory() {
        reset(simpleService);
    }
}

```


# 集成测试

## 静态集成
静态类
```java
package com.nq.mockitouse.util;

public class HttpUtil {
    public static String requestGet(String url) {
        return "response received";
    }
}

```

测试类
```java
package com.nq.mockitouse;

import com.nq.mockitouse.util.HttpUtil;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnitRunner;
import org.springframework.test.context.bean.override.BeanOverride;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@RunWith(MockitoJUnitRunner.class)
public class StaticTest {
    private MockedStatic<HttpUtil> httpUtilMockedStatic;

    @Before
    public void setup() {
        httpUtilMockedStatic = mockStatic(HttpUtil.class);
    }

    @Test
    public void testGet() {
        httpUtilMockedStatic.when(() -> HttpUtil.requestGet(anyString())).thenReturn("okk");
        String res = HttpUtil.requestGet("test");
        assertThat(res, equalTo("okk"));
    }

    @After
    public void destroy() {
        httpUtilMockedStatic.close();
    }
}

```

## springboot集成
> 简易的用户登录实现

user对象
```java
package com.nq.mockitouse.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class User {
    private String username;
    private String password;
}

```

controller
```java
package com.nq.mockitouse.controller;

import com.nq.mockitouse.dto.User;
import com.nq.mockitouse.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody User user) {
        boolean isValid = userService.login(user);
        if (isValid) {
            return ResponseEntity.ok("登录成功");
        } else {
            return ResponseEntity.badRequest().body("用户名或密码错误");
        }
    }
}

```

service
```java
package com.nq.mockitouse.service;

import com.nq.mockitouse.dto.User;

public interface UserService {

    boolean login(User user);
}


package com.nq.mockitouse.service.impl;

import com.nq.mockitouse.dto.User;
import com.nq.mockitouse.repository.UserRemoteRepo;
import com.nq.mockitouse.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRemoteRepo userRemoteRepo;
    @Override
    public boolean login(User user) {
        return userRemoteRepo.validateUser(user);
    }
}

```


repository
```java
package com.nq.mockitouse.repository;

import com.nq.mockitouse.dto.User;

public interface UserRemoteRepo {
    boolean validateUser(User user);
}


package com.nq.mockitouse.repository.impl;

import com.nq.mockitouse.dto.User;
import com.nq.mockitouse.repository.UserRemoteRepo;
import org.springframework.stereotype.Repository;

@Repository
public class UserRemoteRepoImpl implements UserRemoteRepo {
    @Override
    public boolean validateUser(User user) {
        // 模拟远程调用：比如调用第三方身份认证服务
        // 简单模拟：如果用户名是 admin 且密码是 123456，则验证通过
        return "admin".equals(user.getUsername()) && "123456".equals(user.getPassword());
    }
}

```

**单元测试service的login方法**
```java
package com.nq.mockitouse;

import com.nq.mockitouse.dto.User;
import com.nq.mockitouse.repository.UserRemoteRepo;
import com.nq.mockitouse.service.UserService;
import com.nq.mockitouse.service.impl.UserServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    // 模拟对象
    @Mock
    private UserRemoteRepo userRemoteRepo;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    public void testLoginSuccess() {
        User user = new User("无所谓", "无所谓");

        // 模拟 userRepository.validateUser(...) 返回 true
        when(userRemoteRepo.validateUser(user)).thenReturn(true);

        boolean result = userService.login(user);
        assertTrue(result);
    }

    @Test
    public void testLoginFailed() {
        User user = new User("无所谓", "无所谓");

        // 模拟 userRepository.validateUser(...) 返回 false
        when(userRemoteRepo.validateUser(user)).thenReturn(false);

        boolean result = userService.login(user);
        assertFalse(result);
    }

}

```

### @Mock 与 @InjectMocks区别
@Mock 是Mockito提供Mock对象实例
@InjectMocks 是真实依赖的对象，单元测试的目标类

---
1. 明确单元测试的**目标**，例如：只关心service层的逻辑，不关心其他组件的依赖性，使用**Mockito**
2. 如果需要测试整个servcie的逻辑，例如真实调用数据库等，使用集成测试 SpringBootTest, 或者只Mock第三方服务
3. 测试整个系统，使用springbootTest
Mockito 单元测试，快速验证逻辑，不启动spring，不连接任务外部服务

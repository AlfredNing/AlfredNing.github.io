---
title: "SpringBoot工具"
date: 2024-08-12T23:24:51+08:00
lastmod: 2024-08-12T23:24:51+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- SpringBoot
tags: # 标签
- SpringBoot
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
> springCloud和springboot版本之间的对应关系：https://spring.io/projects/spring-cloud
> springboot和kafka的版本对应关系：https://spring.io/projects/spring-kafka

# SpringBoot全局异常处理

```java
package com.example.demo01.infra.advice;

import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理器
 *
 * @author Alfred.Ning
 * @since 2024年08月15日 21:17:00
 */
@RestControllerAdvice
@ResponseBody
@Slf4j
public class GlobalExceptionHandler {
  @ExceptionHandler(value = {MethodArgumentNotValidException.class})
  public ResponseResult<String> handleValidException(MethodArgumentNotValidException ex, HttpServletResponse httpServletResponse) {
    log.error("[GlobalExceptionHandler][handleValidException] 参数校验exception", ex);
    return wrapperBindingResult(ex.getBindingResult(), httpServletResponse);
  }

  private ResponseResult<String> wrapperBindingResult(BindingResult bindingResult, HttpServletResponse httpServletResponse) {
    StringBuilder errorMsg = new StringBuilder();
    for (ObjectError error : bindingResult.getAllErrors()) {
      if (error instanceof FieldError) {
        errorMsg.append(((FieldError) error).getField()).append(": ");
      }
      errorMsg.append(error.getDefaultMessage() == null ? "" : error.getDefaultMessage());

    }
    httpServletResponse.setStatus(HttpStatus.BAD_REQUEST.value());
    return ResponseResult.failed(ResultCode.FAILED.getCode(),null);
  }

}
```

# 请求日志记录

```java
package com.example.demo01.infra.advice;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.apache.tomcat.util.buf.StringUtils;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.context.annotation.Configuration;
import org.springframework.validation.BindingResult;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

/**
 * @author Alfred.Ning
 * @since 2024年08月15日 21:24:00
 */
@Configuration
@Slf4j
public class WebLogAspect {

  @Pointcut("@within(org.springframework.stereotype.Controller) || @within(org.springframework.web.bind.annotation.RestController)")
  public void cutController() {
  }

  @Before("cutController()")
  public void doBefore(JoinPoint point) {
    //获取拦截方法的参数
    HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
    String url = request.getRequestURL().toString();
    List<Object> list = new ArrayList<>();
    for (Object object : point.getArgs()) {
      if (object instanceof MultipartFile || object instanceof HttpServletRequest
          || object instanceof HttpServletResponse || object instanceof BindingResult) {
        continue;
      }
      list.add(object);
    }
    log.info("请求 uri:[{}],params:[{}]", url, list);
  }

  /**
   * 返回通知： 1. 在目标方法正常结束之后执行 1. 在返回通知中补充请求日志信息，如返回时间，方法耗时，返回值，并且保存日志信息
   *
   * @param response
   * @throws Throwable
   */
  @AfterReturning(returning = "response", pointcut = "cutController()")
  public void doAfterReturning(Object response) {
    if (response != null) {
      log.info("请求返回result:[{}]", response);
    }
  }
}
```

**通过Filter接口也可以实现**

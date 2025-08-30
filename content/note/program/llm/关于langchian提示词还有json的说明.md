---
title: "关于langchian提示词还有json的说明"
date: 2025-08-30T16:45:29+08:00
lastmod: 2025-08-30T16:45:29+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- LLM
tags: # 标签
- LLM
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

> 所有目标的实现都是源于对过程的深究

# 问题阐述

使用langchain遇到了需要在提示词里面加入json格式需求，如果是直接插入会导致识别成变量。

错误信息：

```python
KeyError: "Input to ChatPromptTemplate is missing variables {'key1'}.  Expected: ['input', 'key1'] Received: ['input']\nNote: if you intended {key1} to be part of the string and not a variable, please escape it with double curly braces like: '{{key1}}'.\nFor troubleshooting, visit: https://python.langchain.com/docs/troubleshooting/errors/INVALID_PROMPT_INPUT "

```

# 不使用模版字符串的情况

```python
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", """你是一个标准的格式输出器。请帮我输出一段用户提供键值，系统mocks生成value的json格式。格式如下:
        {key1: value1, key2:value2}
        """),
        ("human", "{input}")
    ]
)

print(prompt.invoke({"input": "username"}))

```

修改措施：`{key1: value1, key2:value2}` 修改成 `{{key1: value1, key2:value2}}`

# 使用模板字符串的情况

```python
from langchain_core.prompts import ChatPromptTemplate

params = {
    "build_tool": "Maven",
    "framework": "Spring Boot",
    "modules": ["User", "Product"],
    "needs": ["UserService", "ProductService"]
}
# [{"type": "dir", "path": "src/main/java"}, {"type": "file", "path": "pom.xml"}]

prompt = ChatPromptTemplate.from_messages([
    ("system", f"""
      根据以下参数生成 Java 项目目录结构，输出 JSON 列表，每项为：
        {{"type": "dir"|"file", "path": "相对路径"}}
      参数：
      - build_tool: {params['build_tool']}
      - framework: {params['framework']}
      - modules: {params['modules']}
      - needs: {params['needs']}

      只输出 JSON 列表，例如：
                  [{{{{"type": "dir", "path": "src/main/java"}}}}, {{{{"type": "file", "path": "pom.xml"}}}}]

      """),
    ("human", "请输出结构。")
])
print(prompt.invoke({}))

```

结果措施: `{{"type": "dir"|"file", "path": "相对路径"}}` 修改成 `{{{{"type": "dir"|"file", "path": "相对路径"}}}}`

# 总结

不使用模板字符串，统一用"{{"   "}}" 处理

使用模板字符串，统一用"{{{{"   "}}}}" 处理


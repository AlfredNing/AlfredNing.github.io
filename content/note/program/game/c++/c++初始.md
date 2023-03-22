---
title: "C++初始"
date: 2023-03-22T07:31:48+08:00
lastmod: 2023-03-22T07:31:48+08:00
author: ["AlfredNing"]
keywords: 
- 
categories: # 没有分类界面可以不填写
- 
tags: # 标签
- c++
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

# 简介

C++一种静态类型、编译式、通用的、大小写敏感的、不规则的编程语言，支持过程化编程、面向对象编程和泛型编程。

c++是一门中级语言，综合高级语言和低级语言的特点。

C++ 是 C 的一个超集，事实上，任何合法的 C 程序都是合法的 C++ 程序。

静态类型的编程语言都是在编译时候执行类型检查，而不是在运行时候执行类型检查

# 面向对象四大特点

- 封装
- 继承
- 抽象
- 多态

**开发工具，window使用Visual Studio**

> - **对象 -** 对象具有状态和行为。例如：一只狗的状态 - 颜色、名称、品种，行为 - 摇动、叫唤、吃。对象是类的实例。
> - **类 -** 类可以定义为描述对象行为/状态的模板/蓝图。
> - **方法 -** 从基本上说，一个方法表示一种行为。一个类可以包含多个方法。可以在方法中写入逻辑、操作数据以及执行所有的动作。
> - **即时变量 -** 每个对象都有其独特的即时变量。对象的状态是由这些即时变量的值创建的。

# 程序结构

```c++
#include <iostream>
using namespace std;
int main() {
	cout << "Hello, world!" << endl;
	return 0;
}
 g++ hello.cpp$ ./a.outHello Wo
```

- 头文件：包含程序必须的或有用的信息
- 命名空间
- main 函数程序开始
- 分号是语句结束符，每个语句必须以分号结束。c++不以行末作为结束符，一行可以放置多个语句
- 块是一组使用大括号括起来的按逻辑连接的语句

## 标识符

以字母A-Z或a-z或下划线_开始，后跟多个字母数字下划线

## 关键字

|              |           |                  |          |
| ------------ | --------- | ---------------- | -------- |
| asm          | else      | new              | this     |
| auto         | enum      | operator         | throw    |
| bool         | explicit  | private          | true     |
| break        | export    | protected        | try      |
| case         | extern    | public           | typedef  |
| catch        | false     | register         | typeid   |
| char         | float     | reinterpret_cast | typename |
| class        | for       | return           | union    |
| const        | friend    | short            | unsigned |
| const_cast   | goto      | signed           | using    |
| continue     | if        | sizeof           | virtual  |
| default      | inline    | static           | void     |
| delete       | int       | static_cast      | volatile |
| do           | long      | struct           | wchar_t  |
| double       | mutable   | switch           | while    |
| dynamic_cast | namespace | template         |          |

## 三字符组

用于表示另一个字符的三个字符系列，又称为**三字符系列**

- 以两个问号开头
- 三字符序列不太常见，但 C++ 标准允许把某些字符指定为三字符序列。以前为了表示键盘上没有的字符，这是必不可少的一种方法。
- **三字符序列可以出现在任何地方，包括字符串、字符序列、注释和预处理指令**

| 三字符组 | 替换 |
| -------- | ---- |
| ??=      | #    |
| ??/      | \    |
| ??'      | ^    |
| ??(      | [    |
| ??)      | ]    |
| ??!      | \|   |
| ??<      | {    |
| ??>      | }    |
| ??-      | ~    |

- - 如果希望在源程序中有两个连续的问号，且不希望被预处理器替换，这种情况出现在字符常量、字符串字面值或者是程序注释中，可选办法是用字符串的自动连接："...?""?..."或者转义序列："...??..."。
  - 从Microsoft Visual C++ 2010版开始，该编译器默认不再自动替换三字符组。如果需要使用三字符组替换（如为了兼容古老的软件代码），需要设置编译器命令行选项/Zc:trigraphs、
  - g++仍默认支持三字符组，但会给出编译警告

## 空格

只包含空格的行，被称为空白行，可能带有注释，C++ 编译器会完全忽略它

## 注释

- 单行注释：// 或者 /**/
- 多行注释: /**/
- 在 /* 和 */ 注释内部，// 字符没有特殊的含义*

## 数据类型

变量保留是所存储的值的内存地址，当创建一个变量，就会在内存中保留一些空间。

### 七种基本的 C++ 基本内置数据类型

| 类型 | 关键字 |
| ---- | ------ |
|      |        |

| 类型     | 关键字  |
| -------- | ------- |
| 布尔型   | bool    |
| 字符型   | char    |
| 整型     | int     |
| 浮点型   | float   |
| 双浮点型 | double  |
| 无类型   | void    |
| 宽字符型 | wchar_t |

类型修饰符

- signed
- unsigned
- short
- long

| 类型               | 位            | 范围                                                    |
| ------------------ | ------------- | ------------------------------------------------------- |
| char               | 1 个字节      | -128 到 127 或者 0 到 255                               |
| unsigned char      | 1 个字节      | 0 到 255                                                |
| signed char        | 1 个字节      | -128 到 127                                             |
| int                | 4 个字节      | -2147483648 到 2147483647                               |
| unsigned int       | 4 个字节      | 0 到 4294967295                                         |
| signed int         | 4 个字节      | -2147483648 到 2147483647                               |
| short int          | 2 个字节      | -32768 到 32767                                         |
| unsigned short int | 2 个字节      | 0 到 65,535                                             |
| signed short int   | 2 个字节      | -32768 到 32767                                         |
| long int           | 8 个字节      | -9,223,372,036,854,775,808 到 9,223,372,036,854,775,807 |
| signed long int    | 8 个字节      | -9,223,372,036,854,775,808 到 9,223,372,036,854,775,807 |
| unsigned long int  | 8 个字节      | 0 to 18,446,744,073,709,551,615                         |
| float              | 4 个字节      | +/- 3.4e +/- 38 (~7 个数字)                             |
| double             | 8 个字节      | +/- 1.7e +/- 308 (~15 个数字)                           |
| long double        | 8 个字节      | +/- 1.7e +/- 308 (~15 个数字)                           |
| wchar_t            | 2 或 4 个字节 | 1 个宽字符                                              |

```c++
#include <iostream>
using namespace std;
int main(){   
cout << "Size of char : " << sizeof(char) << endl;
cout << "Size of int : " << sizeof(int) << endl;
cout << "Size of short int : " << sizeof(short int) << endl;
cout << "Size of long int : " << sizeof(long int) << endl;
cout << "Size of float : " << sizeof(float) << endl;
cout << "Size of double : " << sizeof(double) << endl;
cout << "Size of wchar_t : " << sizeof(wchar_t) << endl;   return 0;
}
// 结果会根据所使用的计算机而有所不同
```

### typedef of 声明

为已有的类型取一个新名字

```c++
#include <iostream>
using namespace std;
typedef int a;
int main(){   
	a b = 10;
	cout << b;
return 0;
}
```

### 枚举类型

派生数据类型，由用户定义的若干枚举常量的集合

enum enum-name { list of names } var-list;

```c++
#include <iostream>
using namespace std;
typedef int a;
int main(){   
	// 默认情况下，第一个名称的值为 0，第二个名称的值为 1，第三个名称的值为 2，以此类推
	enum color {
		red, blue, green
	} c ;
	c = blue;

	cout << c;
	// 以给名称赋予一个特殊的值，只需要添加一个初始值即可。例如，在下面的枚举中，green 的值为 5。
	enum color { red, green = 5, blue };
	return 0;
}
```

### 变量类型

变量的名称可以由字母、数字和下划线字符组成。它必须以字母或下划线开头。大写字母和小写字母是不同的，因为 C++ 是大小写敏感的。

前面的基本数据类型

| 类型    | 描述                                               |
| ------- | -------------------------------------------------- |
| bool    | 存储值 true 或 false。                             |
| char    | 通常是一个八位字节（一个字节）。这是一个整数类型。 |
| int     | 对机器而言，整数的最自然的大小。                   |
| float   | 单精度浮点值。                                     |
| double  | 双精度浮点值。                                     |
| void    | 表示类型的缺失。                                   |
| wchar_t | 宽字符类型。                                       |

c++ 也允许定义各种其他类型的变量，比如**枚举、指针、数组、引用、数据结构、类**等等

变声类型 变量名

声明的时候被初始化。

不带初始化的定义：带**有静态存储持续时间的变量会被隐式初始化为 NULL（所有字节的值都是 0），其他所有变量的初始值是未定义的。**

### 变量声明

变量声明保证变量以给定的类型和名称存在，这样编译器在不需要知道变量完整细节的情况下也能继续进一步的编译。变量声明只在编译时有它的意义，在程序连接时编译器需要实际的变量声明。

使用多个文件只在其中一个文件定义变量

**extern** 关键字在任何地方声明一个变量。可以在 C++ 程序中多次声明一个变量，但变量只能在某个文件、函数或代码块中被定义一次

```c++
#include <iostream>
using namespace std;
extern int a, b;extern int c; extern float f;
int func(); // 函数声明
int main(){   
	// 变量定义
	int a, b;
	int c;
	float f;

	// 实际初始化
	a = 10;
	b = 20;
	c = a + b;
	cout << c << endl;
	f = 70.0 / 3.0;
	cout << f << endl;
	return 0;
}
```

### 左值和右值

左值：指向内存位置的表达式被称为左值(**lvalue**)表达式。**左值可以出现在赋值号的左边或右边。**

右值：指存储在内存某些地址的数值。**右值是不能对其进行赋值的表达式。右值只能出现在赋值号的右边**

### 变量作用域

一般有三个地方可以声明变量

- 函数或一个代码块中，称为**局部变量**
- 在函数参数的定义中声明的变量，称为**形式参数**
- 在所有函数外部声明的变量，成为**全局变量**

```c++
#include <iostream>
using namespace std;
// 全局变量声明
int g;
int gg = 100;
int main(){   
	// 局部变量声明
	int a, b;
	int c;
	
	// 实际初始化
	a = 10;
	b = 20;
	c = a + b;
	cout << c << endl; 

	// 全局变量初始
	g = 100;
	cout << g << endl;

	// 同名变量，局部覆盖全局变量
	int gg = 300;
	cout << gg << endl;
	return 0;
}
```

**当局部变量被定义时，系统不会对其初始化，必须自行对其初始化。定义全局变量时，系统会自动初始化为下列值**

| 数据类型 | 初始化默认值 |
| -------- | ------------ |
| int      | 0            |
| char     | '\0'         |
| float    | 0            |
| double   | 0            |
| pointer  | NULL         |

**正确地初始化变量是一个良好的编程习惯，否则有时候程序可能会产生意想不到的结果**

### 常量

常量是固定值，在程序执行期间不会改变。这些固定的值，又叫做**字面量**

常量可以是任何的基本数据类型，可分为整型数字、浮点数字、字符、字符串和布尔值

常量的值在定义后不能更改

#### 整数常量

整数常量可以是十进制、八进制或十六进制的常量。前缀指定基数：0x 或 0X 表示十六进制，0 表示八进制，不带前缀则默认表示十进制。

整数常量也可以带一个后缀，后缀是 U 和 L 的组合，U 表示无符号整数（unsigned），L 表示长整数（long）。后缀可以是大写，也可以是小写，U 和 L 的顺序任意

#### 浮点常量

浮点常量由整数部分、小数点、小数部分和指数部分组成。您可以使用小数形式或者指数形式来表示浮点常量。

当使用小数形式表示时，必须包含整数部分、小数部分，或同时包含两者。当使用指数形式表示时， 必须包含小数点、指数，或同时包含两者。带符号的指数是用 e 或 E 引入的

```c++
.14159       // 合法的 314159E-5L    // 合法的 510E          // 非法的：不完整的指数210f  
```

#### 布尔常量

- true
- false

**不要把 true 的值看成 1，把 false 的值看成 0**

#### 字符常量

字符常量是括在单引号中。如果常量以 L（仅当大写时）开头，则表示它是一个宽字符常量（例如 L'x'），此时它必须存储在 **wchar_t** 类型的变量中。否则，它就是一个窄字符常量（例如 'x'），此时它可以存储在 **char** 类型的简单变量中。

字符常量可以是一个普通的字符（例如 'x'）、一个转义序列（例如 '\t'），或一个通用的字符（例如 '\u02C0'）

有反斜杠时，它们就具有特殊的含义

转义序列码

| 转义序列   | 含义                       |
| ---------- | -------------------------- |
| \          | \ 字符                     |
| '          | ' 字符                     |
| "          | " 字符                     |
| ?          | ? 字符                     |
| \a         | 警报铃声                   |
| \b         | 退格键                     |
| \f         | 换页符                     |
| \n         | 换行符                     |
| \r         | 回车                       |
| \t         | 水平制表符                 |
| \v         | 垂直制表符                 |
| \ooo       | 一到三位的八进制数         |
| \xhh . . . | 一个或多个数字的十六进制数 |

#### 字符串常量

符串字面值或常量是括在双引号 "" 中的。一个字符串包含类似于字符常量的字符：普通的字符、转义序列和通用的字符。

### 定义常量

#### #define 预处理器

```c++
#include <iostream>
using namespace std;
#define WIDTH 5
#define LENGTH 10
#define NEWLINE '\n'
int main(){   
	cout << WIDTH << endl;
	cout << LENGTH << endl;
	cout << NEWLINE << endl;
	return 0;
}
```

#### const 关键字

```c++
#include <iostream>
using namespace std;

int main(){   
	const int  WIDTH  = 5;
	const int  LENGTH = 10;
	const char NEWLINE  = '\n';
	cout << WIDTH << endl;
	cout << LENGTH << endl;
	cout << NEWLINE << endl;
	return 0;
}
```

## 修饰符类型

C++ 允许在 **char、int 和 double** 数据类型前放置修饰符。修饰符用于改变基本类型的含义，所以它更能满足各种情境的需求。

下面列出了数据类型修饰符：

- signed
- unsigned
- long
- short

修饰符 **signed、unsigned、long 和 short** 可应用于整型，**signed** 和 **unsigned** 可应用于字符型，**long** 可应用于双精度型。

修饰符 **signed** 和 **unsigned** 也可以作为 **long** 或 **short** 修饰符的前缀。例如：**unsigned long int**。

C++ 允许使用速记符号来声明**无符号短整数**或**无符号长整数**。您可以不写 int，只写单词 **unsigned、short** 或 **unsigned、long**，int 是隐含的。例如，下面的两个语句都声明了无符号整型变量。

```c++
unsigned x;
unsigned int y;	
```

## 类型限定符

给变量设置额外信息

| 限定符   | 含义                                                         |
| -------- | ------------------------------------------------------------ |
| const    | **const** 类型的对象在程序执行期间不能被修改改变。           |
| volatile | 修饰符 **volatile** 告诉编译器，变量的值可能以程序未明确指定的方式被改变。 |
| restrict | 由 **restrict** 修饰的指针是唯一一种访问它所指向的对象的方式。只有 C99 增加了新的类型限定符 restrict。 |

## 存储类

作用：定义c++程序中变量/函数的范围（可见性）和声明周期。放置在修饰的类型之前

- auto
- register
- static
- extern
- mutable
- thread_local (C++11)

从 C++ 11 开始，auto 关键字不再是 C++ 存储类说明符，且 register 关键字被弃用

### auto存储类

自 C++ 11 以来，**auto** 关键字用于两种情况：**声明变量时根据初始化表达式自动推断该变量的类型、声明函数时函数返回值的占位符**。

C++98标准中auto关键字用于自动变量的声明，但由于使用极少且多余，在C++11中已删除这一用法

### register 存储类

用于定义存储在寄存器而不是RAM中的局部变量

-  最大尺寸等于寄存器的大小，且不能应用一元运算符&， 因为它没有内存位置
- 寄存器只用于需要快速访问的变量，比如计数器。
- 不是一味的意味着变量存储到寄存器中，可能意味着存储到寄存器当中，取决于硬件和实现的限制

### static存储类

作用：指示编译器在程序的声明周期内保持局部变量的存在，而不需要每次进入和离开作用域时候进行创建和销毁

- 利用static变量修饰局部变量可以在函数调用中保持局部变量的值
- 修饰全局变量，使变量的作用域限定在声明的文件内
- 作用在类数据成员上，会导致仅有一个该成员的副本被类的所有对象共享

```c++
#include <iostream>
// 函数声明
void func(void);
// 全局静态变量
static int count = 10;
int main(){   
	while (count--) {
		func();
	}
	return 0;
}
void func(void) {
	// 局部静态变量
	static int i = 5;
	i++;
	std::cout << "变量i为 " << i;
	std::cout << "变量count为 " << count << std::endl;
}
```

### extern存储类

提供一个全局变量的引用，全局变量对所有程序的文件都是可见的。当使用 'extern' 时，对于无法初始化的变量，会把变量名指向一个之前定义过的存储位置。

- 用来在另一个文件中声明一个全局变量或函数

- extern 修饰符通常用于当有两个或多个文件共享相同的全局变量或函数的时候

```java
// t1.cpp
#include <iostream>
extern int count;
void write_externx(void) {
	// Count is 5
	std::cout << "Count is " << count << std::endl;
}
// main.cpp
#include <iostream>
int count;
extern void write_externx();
int main() {
	count = 5;
	write_externx();
	return 0;
}
```

### mutable存储类

**只适用于类的对象，允许对象的成员替代常量。mutable 成员可以通过 const 成员函数修改**

### thread_local 存储类

声明的变量仅可在其上创建的线程上访问。 变量在创建线程时创建，并在销毁线程时销毁。 每个线程都有其自己的变量副本。

thread_local 说明符可以与 static 或 extern 合并。

可以将 thread_local 仅应用于数据声明和定义，thread_local 不能用于函数声明或定义。

```c++
thread_local int x;  // 命名空间下的全局变量
class X{
static thread_local std::string s; // 类的static成员变量
};
static thread_local std::string X::s;  // X::s 是需要定义的
 void foo(){
    thread_local std::vector<int> v;  // 本地变量
 }
```


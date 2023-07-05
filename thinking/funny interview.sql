1 http 与https
http设计的初衷是用来接收和处理http页面，轻量无状态。默认端口80
https http over SSL/TLS 识别网站，加密传输。默认端口443。
非对称加密+对称加密。原因是存在秘钥交换问题。
服务器给客户端公钥。客户端生成会话秘钥。用公钥加密。返回给服务端，服务端进行解密。之后采用对称加密.
2. TCP 与 UDP
属于传输层协议。

3. 继承与接口区别
继承：解决代码的复用性和可维护性，满足的是is-a关系,对类的抽象。可以有实现和抽象方法，也可以定义成员变量。单继承
接口：设计各种规范，让其他类实现这些方法，满足的是like-a关系，对行为的抽象。多实现。如果是接口继承接口的话，可用extends.在接口中只能定义全局常量,和抽象方法

===========================================网络===========================================
4. TCP 和UDP
TCP UDP 工作在传输层，负责传输数据。稳定可靠，文件，浏览网页
TCP基于连接，在乎可靠性，及时反馈 全双工。
    - 三次握手
        1. clien > SYN包 > Server端
        2. Server端 > SYN + ACK 包 > client端
        3. 客户端 > ACK 包 > Server端
    为什么需要三次握手，而不是两次握手？
        服务端回复SYN + ACK包 建立连接。防止因为已失效的请求报文突然又传到服务器引起错误。
        实际分析：
                客户端向服务端发送SYN包请求建立连接，因为某些未知的原因，并没有到达服务器。在中间某个网络节点产生滞留。为了建立连接，客户端重新发送SYN包，这次的数据包成功达到
                服务端返回SYN+ACK包，但是第一包阻塞的SYN包网络节点突然恢复，又送达到服务器端，在两次握手的基础上，服务端认为是客户端的建立新连接。在两次握手之后，进入等待数据状态。
                客户端认为是一个连接，服务端认为是两个连接，造成状态不一致。在三次握手的基础上，服务端收不到最后的ACK包，不会认为建立连接成功。
        三次握手解决网络信道不可靠的问题，能在不可靠的信道上建立可靠的连接
    - 传输确认
    TCP 如何处理丢包问题 乱序问题 
        tcp为每一个连接建立发送缓冲区，从建立连接的第一个字节的序列号为0，后面每个字节的序列号增加1，发送数据时，从发送缓冲区取一部分数据组成数据内容。在tcp协议头会附带序列号和长度。
        回复确认： 接收段收到数据后，需要回复确认ack=序列号+长度 = 下一包起始序列号。
        切割发送： 发送端可以发送多包数据，接收端只需要回复一次即可。发送端可以把待发送的数据分割成一系列碎片，发送到对端。对端根据序列号和长度重构出来完整的数据
        丢失重传： 假设丢失，接收端发送ack=100,发送端重传序列号100到接收端。接收端进行补齐。
    - 四次挥手
    处于连接的客户端和服务器都可以发送关闭请求。
        假设客户端主动发送连接关闭请求
        1。 客户端向服务器发送FIN关闭连接请求，自己进入终止等待1状态。
        2. 服务端收到FIN包，发送ACK包，表示自己进入关闭等待状态。客户端进入终止等待2状态。服务端此时还可以发送未发送的数据，客户端还可以接收数据。
        3. 服务端发送数据完成之后，发送FIN包，服务端进入最后确认状态。
        4. 客户端收到回复ACK包，自己进入超时等待状态，经过超时时间后关闭连接。服务端收到ACK包，立即关闭连接
    为什么客户需要超时等待？
        为了保证对方已收到ACK包，因为假设客户端发送ACK包就立即释放，一旦ACK包在网络丢失。服务端一直停留在最后确认状态。如果客户端等待一段时间，服务端没有收到ACK包，会重发FIN包，客户端会响应ACK，刷新等待时间
        不可靠的网络连接过程中，进行可靠的连接。
UCP基于非连接，面向报文。速度快，适合实时性要求较高，对少量丢包没有太大要求的场景。域名查询，视频查询，隧道网络：vpn
    发送数据，就是把数据封装组成数据包，经过网卡发送出去。没有状态上的联系。

===========================================操作系统===========================================
5. CPU状态相关
    CPU 分为内核态与用户态，也分别称为管态和目态。
    CPU指令：特权指令和非特权指令。特权指令是只有内核态的CPU可以运行，非特权指令就是CPU的内核态和用户态都可以运行。
6. 进程状态
    创建 -> 就绪 -> 运行 -> 阻塞 -> 终止
7. 进程和线程
    进程是对正在运行中的程序的一个抽象，是系统进行资源分配和调度的基本单位。线程是操作系统能够运算调度的最小单位，是进程当中的一个执行单元。
    一个程序在内存运行，每个进程都有其自己独立的一块内存空间。一个进程有多个线程。多个线程共享进程的堆和方法区资源。每个线程有自己的程序计数器、虚拟机栈和本地方法栈。
8. 进程和线程内如何通信
    为什么是内？实际上只需要进程间的通信，因为同一进程的线程共享地址空间，没有通信的必要，但需要做好同步/互斥。
    进程间通信方式：
        1. 管道
        2. 有名管道
        3. 信号量
        4. 消息队列
        5. 信号
        6. 共享内存
        7. 套接字
    线程间通信方式：
        1. 锁机制：互斥锁、条件变量，读写锁
        2. 信号量机制
        3. 信号量机制
    线程间通信的目的在于线程同步，所有线程没有像进程中用于数据交换的通信进程

===========================================java 基础===========================================    
9. == 和 equals区别
    基本类型：比较的是值是否相同；
    引用类型：比较的是引用是否相同

10. map 和flatmap区别
    共同点：map 和flatmap都是接受一个映射函数，将该函数应用每个元素中，并返回一个Stream。map为输入元素每个生成一个值，而flatmap用该流的内容替换每个生成流的效果，简而概括


    flatmap将生成的所有单独的流都扁平化为一个流
===========================================java 多线程===========================================    
1. 线程池
    1.1 什么时候使用线程池?：单个任务处理时间长，需要处理的任务数量大
    1.2 线程池优势?: 
        1. 提高响应速度
        2. 任务达到，不需要创建线程就能立即执行
        3. 提高线程的可管理性，统一分配，调优和监控
    1.3 构造方法参数
        1. corePoolSize: 维护的核心线程数，最少数量
        2. maxPoolSize: 维护的最大线程数量
        3. keepAliveTime: 维护线程池多余线程所允许的空闲时间，最长可以空闲多久，时间到了，如果超过corePoolSize的数量，销毁掉
        4. unit: 维护线程池运行空闲的时间单位
        5. workQueue: 缓冲队列,已经提交但是没有执行过的任务会放进这里
        6. threadFactory: 生成线程池工作线程的线程工厂，一般使用默认
        7. handle: 线程池对拒绝任务的处理策略，当队列满且工作线程已经达到maximunPoolSize
    2.1 线程池的执行逻辑
        1. 线程池中的数量少于corePoolSize, 创建新的线程来执行
        2. 线程池中的数量大于等于corePoolSize, 队列未满，放到队列中
        3. 线程池的数量大于等于corePollSize,队列满了，但maxPoolSize没有满的话，创建新的非核心线程来执行任务
        4. 线程池的数量等于maxPoolSize, 调用RejectedExectuionHandler来执行拒绝策略，会抛出异常，一般是RejectedExecutionException
        注意【大坑】：线程池执行顺序，java安排任务的时候是，核心，队列，非核心线程安排的顺序是1,2，3
            但是如果线程满了的话，执行顺序是核心，非核心，队列 变成1,3,2
    2.2 拒绝策略：
        队列满，线程池满
        1. CallerRunsPolicy: 调用者运行策略
            不抛弃任务，不抛出异常，将任务返回给调用者，从而降低新任务的流量
        2. AbortPolicy: 终止策略
            抛出异常，默认策略
        3. DiscordPolicy: 丢弃任务
            如果场景运行丢弃，最好的策略
        4. DiscordOldestPolicy: 抛弃队列中等待最久的任务
            抛弃队列中等待最久的任务，然后把当前的任务加入到队列中，尝试再次提交任务

===========================================mysql ===========================================            
1. 主从同步
    1.1 主从复制：用来建立一个和主数据库一样的数据库环境，成为从数据库，主数据库一般是准实时的业务数据库
    1.2 原理
        1. 数据库有个bin-log二进制日志,记录了所有sql语句
        2. 把主数据库的bin-log文件的sql语句复制过来
        3. 在其从数据库relay-log重做日志文件中在执行一次这些sql语句即可
        4. 具体需要三个线程
            1. binlog输出线程：当有从库连接到主库的时候，主库都会创建一个线程然后发送binlog内容到从库。在从库里，当复制开始的时候，从库就会创建两个线程进行处理
            2. 从库I/O线程:当START SLAVE语句在从库开始执行之后，从库创建一个I/O线程，该线程连接到主库并请求主库发送binlog里面的更新记录到从库上。
               从库I/O线程读取主库的binlog输出线程发送的更新并拷贝这些更新到本地文件，其中包括relay log文件
            3. 从库的SQL线程:从库创建一个SQL线程，这个线程读取从库I/O线程写到relay log的更新事件并执行。
        对于每一个主从复制的连接，都有三个线程。拥有多个从库的主库为每一个连接到主库的从库创建一个binlog输出线程，每一个从库都有它自己的I/O线程和SQL线程
    https://cuizb.top/myblog/article/detail/1644849971


===========================================spring ===========================================                
1. Bean的初始化过程
    1.1 对用反射创建对象实例。这里用了策略模式。借助BeanDefinationRegistry中的BeanDefination,我们可以使用反射的方式创建对象，也可以使用CGlib字节码生成创建对象。
    1.2 包装对象 BeanWrapper。实际上是对反射相关的API封装，使得上层使用反射完成的相关的业务逻辑大大简化，获取对象数据不在使用写繁杂的反射API，直接调用
    1.3 设置对象属性
        基本类型属性：如果配置元信息有设置，就直接设置。否则基本类型没有设置的，随着JVM启动的话，赋予零值
        引用类型属性：如果依赖的属性已经实例化完成，直接注入。否则先去实例化依赖对象，最后完成对象实例化
    1.4 检查Aware相关接口
    1.5 BeanPostProcessor前置处理
        BeanFactoryPostProcessor存在于容器启动阶段而BeanPostProcessor存在于对象实例化阶段，
        BeanFactoryPostProcessor关注对象被创建之前 那些配置的修修改改，缝缝补补，
        而BeanPostProcessor阶段关注对象已经被创建之后 的功能增强，替换等操作，这样就很容易区分了
    1.6 自定义初始化逻辑
        1. InitializingBean
        2. 配置init-method参数
    1.7 BeanPostProcess后置处理
    1.8 自定义销毁逻辑
        1. 实现DisposableBean接口
        2. 配置destory-method参数。 

===========================================设计模式 =========================================== 
1. 介绍下代理模式
    1.1 结构设计模式
    1.2 角色分类
        1. 服务接口
        2. 服务类： 提供使用的业务逻辑
        3. 代理类：包含一个执行服务对象的引用，代理完成其任务
        4. 客户端



===========================================hr ===========================================
1. 为什么来我们公司面试
    首先，公司的人文价值企业文化，
    其次 与我应聘的岗位是领羊下面的业务开发部门的开发云，主要负责是只能智能数据的建设,为客户提供数智化服务，这与我个人兴趣与目前职业规划是吻合的
    因此，这是我选择贵公司的原因
2. 做过最成功的事情/你遇到过最有挑战性的事是什么/你最有成就感的事/你克服了哪些带给你巨大压力的事
    在我毕业之后，我觉得最成功的一件事就是，我毕业之后，但是公司的数据团队还没有完全成立，
    是我一个人从0到1写完了整个数据同步，这个过程是比较痛苦的，因为要面对需要对于以刚毕业的我来说，是的确有些难度的，
    不过最终项目稳定运行之后，我个人的信心以及面对新的挑战都得到了极大的增强
3. 你的缺点是什么
    - 不要与岗位冲突
    - 回答思路：知道自己缺点之后，如何改正
    整合能力稍微有所欠缺，举个例子：就是我个人在学习当中，很对新技术的感兴趣，去研究新技术解决什么问题，为什么要有它的出现，
    但是碰到真实复杂的问题，凭借单一的知识，往往不能解决，对于此，这也是我个人开始写博客的原因。它设计技术，
    也包括一些其他知识。

4. 你的规划是怎么样
    - 无限制的话，注意层次性m
    未来的1-3年，会做精进自己的专业能力，主要是在自己的本职工作，争取能够独当一面，成为高级开发，熟悉它的业务场景，使用到的技术，以及如何在技术层面提升性能，为我们的产品带来更多的价值
    3-5年内的话，个人还是会选择做技术，不过这时候就要具备创新性，在工作范围之外，拓宽知识领域边界，提升自己的能力
    能不能用同样技术或者逻辑去解决其它领域问题，或者是解决很复杂的问题
5. 你还有什么问题要问我
    我加入公司之后，公司对我们的一些职业生涯发展上面的帮助，或者是说有怎样的晋升途径?
-- 谈薪环节    
6. 你的预期薪资是多少（在面试之前，对自己有个预期）
    这个的话，据我了解，一般都会有一个定级，想问下，薪酬结构是怎样的
    具体回答：（体现自己的能力与专业）
        不要说：具体金额
    我期望有一个符合市场预期的涨幅，就是看公司能给到多少，只要有一个合理的涨幅就可以
7. 什么时候可以到岗
    已经离职: 收到offer一周内到岗
    已经提了离职：我需要回去做好交接，最快两周时间，最慢三周
    在职: 一个月的时间
8. 如何回答离职原因
   千万不要说上家公司的不好
   第一点，之前的项目一直在改动，没有新项目，（不要说之前项目很传统），个人接触不到新的东西
   第二点，在我的职业规划里面，希望能进到一个好的平台，能和一群优秀的人一起共事，我觉得是一件非常有趣的事情
9. 大学里面最受挫的事 （其实问的是：面对失败，你的心态和处理方法）应变能力和学习能力。
    最受挫的事情应该是在大一初期，其实我大一第一年是学的是工业设计，因为我特别喜欢那种艺术感，但是呢，工业设计的必修课素描对于我来说真的是太难了，有段时间，都在想要不要退学。
    后来的话，我请教我们的老师，老师说其实你可以去寻找你所喜欢的东西。大学第一年是由c语言基础课程的，但是就特别喜欢它，看到一些抽象的代码，能够去解决实际问题。就心想我可以去转计算机学院啊，
    因为国内想转专业的话，并不是说你不喜欢就可以转，反而要求你成绩绩点很高。当时我就开始准备英语，高数等尽量提高其他课程成绩，最后在期末，我其实是以专业第一的成绩转走呢，也算达到我的目标了。
10. 请用三个词来描述自己
    适应能力强，有责任心和做事有始
    适应能力强：我对新环境适应能力是比较强的， 之前实习是在苏州，毕业之后是在上海
    有责任心：举个例子：对于一些工作上不明确的地方，我会花时间去搞懂他
    做事有始有终：我习惯做一件事，下定决心去做，肯定付出百分百的努力，就算失败了我也会去总结失败教训

面试官您好，我叫宁强，21年毕业之后一直在上海甄云信息科技有限公司，担任数智中心数据工具部后端研发，
日常主要任务维护数据同步链路稳定，最近接触的项目是关于数据仓库指标体系建立， 
目标在于帮助数据产品人员快速进行数仓建模，产生报表及相关指标。上面就是我的个人介绍，面试官，您看，有什么想问的？

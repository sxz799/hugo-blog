---
title: Go语言Context学习笔记
date: 2022-08-16 16:16:07
tags:
- go
categories:
- go基础


---

### 前言
之前学习了怎么在所有的协程运行结束后让程序停止。这次学一下怎么让运行中的协程停止。比如我们开了1个协程去监控一个程序，如果我们手动取消监控就要让协程主动停止任务，该怎么实现呢？用 select+channel 做检测！
<!--more-->
```go
func main() {
   var wg sync.WaitGroup
   wg.Add(1)
   stopCh := make(chan bool) //用来停止监控狗
   go func() {
      defer wg.Done()
      watchDog(stopCh,"【监控狗1】")
   }()
   time.Sleep(5 * time.Second) //先让监控狗监控5秒
   stopCh <- true //发停止指令
   wg.Wait()
}
func watchDog(stopCh chan bool,name string){
   //开启for select循环，一直后台监控
   for{
      select {
      case <-stopCh:
         fmt.Println(name,"停止指令已收到，马上停止")
         return
      default:
         fmt.Println(name,"正在监控……")
      }
      time.Sleep(1*time.Second)
   }
}
```
### 初识Context

在实际应用中为了更好的利用资源肯定不会只开一个协程去处理任务，如果开了多个协程去监控，那怎么同时取消多个协程呢？使用多个channel吗？如果是几百上千个协程呢？使用channel的局限性就提现出来了。这时候就要用到Context包了。context不仅可以同时取消多个协程，还可以定时取消！先看下使用Context修改后的代码
```go
func main() {
   var wg sync.WaitGroup
   wg.Add(1)
   ctx,stop:=context.WithCancel(context.Background())
   go func() {
      defer wg.Done()
      watchDog(ctx,"【监控狗1】")
   }()
   time.Sleep(5 * time.Second) //先让监控狗监控5秒
   stop() //发停止指令
   wg.Wait()
}
func watchDog(ctx context.Context,name string) {
   //开启for select循环，一直后台监控
   for {
      select {
      case <-ctx.Done():
         fmt.Println(name,"停止指令已收到，马上停止")
         return
      default:
         fmt.Println(name,"正在监控……")
      }
      time.Sleep(1 * time.Second)
   }
}
```
相比 select+channel 的方案，Context 方案主要有 4 个改动点。
> 1.watchDog 的 stopCh 参数换成了 ctx，类型为 context.Context。

> 2.原来的 case <-stopCh 改为 case <-ctx.Done()，用于判断是否停止。

> 3.使用 context.WithCancel(context.Background()) 函数生成一个可以取消的 Context，用于发送停止指令。这里的 context.Background() 用于生成一个空 Context，一般作为整个 Context 树的根节点。

> 4.原来的 stopCh <- true 停止指令，改为 context.WithCancel 函数返回的取消函数 stop()。

可以看到，这和修改前的整体代码结构一样，只不过从 channel 换成了 Context。以上示例只是 Context 的一种使用场景，它的能力不止于此，现在来看下什么是 Context。
首先，Context是并发安全的。Context 是一个接口，它具备**手动、定时、超时**发出取消信号、传值等功能，主要用于控制多个协程之间的协作，尤其是取消操作。一旦取消指令下达，那么被 Context 跟踪的这些协程都会收到取消信号，就可以做清理和退出操作。
Context 接口只有四个方法：
```go
type Context interface {
   Deadline() (deadline time.Time, ok bool)
   Done() <-chan struct{}
   Err() error
   Value(key interface{}) interface{}
}
```

> Deadline 方法可以获取设置的截止时间，第一个返回值 deadline 是截止时间，到了这个时间点，Context 会自动发起取消请求，第二个返回值 ok 代表是否设置了截止时间。

> Done 方法返回一个只读的 channel，类型为 struct{}。在协程中，如果该方法返回的 chan 可以读取，则意味着 Context 已经发起了取消信号。通过 Done 方法收到这个信号后，就可以做清理操作，然后退出协程，释放资源。

> Err 方法返回取消的错误原因，即因为什么原因 Context 被取消。

> Value 方法获取该 Context 上绑定的值，是一个键值对，所以要通过一个 key 才可以获取对应的值。

### Context树

我们不需要自己实现 Context 接口，Go 语言提供了函数可以帮助我们生成不同的 Context，通过这些函数可以生成一颗 Context 树，这样 Context 才可以关联起来，父 Context 发出取消信号的时候，子 Context 也会发出，这样就可以控制不同层级的协程退出。

从使用功能上分，有四种实现好的 Context。

空 Context：不可取消，没有截止时间，主要用于 Context 树的根节点。

可取消的 Context：用于发出取消信号，当取消的时候，它的子 Context 也会取消。

可定时取消的 Context：多了一个定时的功能。

值 Context：用于存储一个 key-value 键值对。

有了根节点 Context 后，这颗 Context 树要怎么生成呢？需要使用 Go 语言提供的四个函数。

> 1.WithCancel(parent Context)：生成一个可取消的 Context。

> 2.WithDeadline(parent Context, d time.Time)：生成一个可定时取消的 Context，参数 d 为定时取消的具体时间。

> 3.WithTimeout(parent Context, timeout time.Duration)：生成一个可超时取消的 Context，参数 timeout 用于设置多久后取消

> 4.WithValue(parent Context, key, val interface{})：生成一个可携带 key-value 键值对的 Context。

以上四个生成 Context 的函数中，前三个都属于可取消的 Context，它们是一类函数，最后一个是值 Context，用于存储一个 key-value 键值对。

如果一个 Context 有子 Context，在该 Context 取消时会发生什么呢？

当节点 Ctx2 取消时，它的子节点 Ctx4、Ctx5 都会被取消，如果还有子节点的子节点，也会被取消。也就是说根节点为 Ctx2 的所有节点都会被取消，其他节点如 Ctx1、Ctx3 和 Ctx6 则不会。

下面代码是演示验证：
```go
func main() {
	fmt.Println("程序启动时间：", time.Now().Format("2006-01-02 15:04:05"))
	var wg sync.WaitGroup

	ctx0, stopAll := context.WithCancel(context.Background())
	ctx1, stopCtx1 := context.WithCancel(ctx0) //ctx1 手动停止
	ctx1_1, _ := context.WithCancel(ctx1)
	ctx1_2, _ := context.WithCancel(ctx1)

	endTime := time.Now().Add(time.Second * 10)
	fmt.Println("ctx2停止时间为：", endTime.Format("2006-01-02 15:04:05"))
	ctx2, _ := context.WithDeadline(ctx0, endTime) //指定时间停止 10s后

	ctx3, _ := context.WithTimeout(ctx0, time.Second*15) //15秒后停止

	wg.Add(6)
	go func() {
		defer wg.Done()
		watchDog(ctx0, "【ctx0】")
	}()
	go func() {
		defer wg.Done()
		watchDog(ctx1, "【ctx1】")
	}()
	go func() {
		defer wg.Done()
		watchDog(ctx2, "【ctx2】")
	}()
	go func() {
		defer wg.Done()
		watchDog(ctx3, "【ctx3】")
	}()
	go func() {
		defer wg.Done()
		watchDog(ctx1_1, "【ctx1_1】")
	}()
	go func() {
		defer wg.Done()
		watchDog(ctx1_2, "【ctx1_2】")
	}()

	time.Sleep(5 * time.Second)  //先让ctx监控5秒
	stopCtx1()                   //发停止指令 手动关闭ctx1
	time.Sleep(15 * time.Second) //再让ctx监控15秒 然后关闭根ctx
	stopAll()
	wg.Wait()
}
func watchDog(ctx context.Context, name string) {
	//开启for select循环，一直后台监控
	for {
		select {
		case <-ctx.Done():
			log.Println(name, "停止指令已收到，马上停止")
			return
		default:
			log.Println(name, "正在运行……")
		}
		time.Sleep(1000 * time.Millisecond)
	}
}

运行结果：
程序启动时间： 2022-11-04 14:11:38
ctx2停止时间为： 2022-11-04 14:11:48
2022/11/04 14:11:38 【ctx1_2】 正在运行……
2022/11/04 14:11:38 【ctx3】 正在运行……
2022/11/04 14:11:38 【ctx1_1】 正在运行……
2022/11/04 14:11:38 【ctx2】 正在运行……
2022/11/04 14:11:38 【ctx0】 正在运行……
2022/11/04 14:11:38 【ctx1】 正在运行……
2022/11/04 14:11:39 【ctx1_1】 正在运行……
2022/11/04 14:11:39 【ctx1】 正在运行……
2022/11/04 14:11:39 【ctx2】 正在运行……
2022/11/04 14:11:39 【ctx0】 正在运行……
2022/11/04 14:11:39 【ctx3】 正在运行……
2022/11/04 14:11:39 【ctx1_2】 正在运行……
2022/11/04 14:11:40 【ctx1_2】 正在运行……
2022/11/04 14:11:40 【ctx3】 正在运行……
2022/11/04 14:11:40 【ctx0】 正在运行……
2022/11/04 14:11:40 【ctx1】 正在运行……
2022/11/04 14:11:40 【ctx2】 正在运行……
2022/11/04 14:11:40 【ctx1_1】 正在运行……
2022/11/04 14:11:41 【ctx0】 正在运行……
2022/11/04 14:11:41 【ctx1_1】 正在运行……
2022/11/04 14:11:41 【ctx3】 正在运行……
2022/11/04 14:11:41 【ctx1_2】 正在运行……
2022/11/04 14:11:41 【ctx2】 正在运行……
2022/11/04 14:11:41 【ctx1】 正在运行……
2022/11/04 14:11:42 【ctx0】 正在运行……
2022/11/04 14:11:42 【ctx1】 正在运行……
2022/11/04 14:11:42 【ctx1_1】 正在运行……
2022/11/04 14:11:42 【ctx2】 正在运行……
2022/11/04 14:11:42 【ctx1_2】 正在运行……
2022/11/04 14:11:42 【ctx3】 正在运行……
2022/11/04 14:11:43 【ctx3】 正在运行……
2022/11/04 14:11:43 【ctx2】 正在运行……
2022/11/04 14:11:43 【ctx1_2】 停止指令已收到，马上停止
2022/11/04 14:11:43 【ctx1】 停止指令已收到，马上停止
2022/11/04 14:11:43 【ctx1_1】 停止指令已收到，马上停止
2022/11/04 14:11:43 【ctx0】 正在运行……
2022/11/04 14:11:44 【ctx0】 正在运行……
2022/11/04 14:11:44 【ctx3】 正在运行……
2022/11/04 14:11:44 【ctx2】 正在运行……
2022/11/04 14:11:45 【ctx0】 正在运行……
2022/11/04 14:11:45 【ctx3】 正在运行……
2022/11/04 14:11:45 【ctx2】 正在运行……
2022/11/04 14:11:46 【ctx3】 正在运行……
2022/11/04 14:11:46 【ctx0】 正在运行……
2022/11/04 14:11:46 【ctx2】 正在运行……
2022/11/04 14:11:47 【ctx2】 正在运行……
2022/11/04 14:11:47 【ctx3】 正在运行……
2022/11/04 14:11:47 【ctx0】 正在运行……
2022/11/04 14:11:48 【ctx0】 正在运行……
2022/11/04 14:11:48 【ctx3】 正在运行……
2022/11/04 14:11:48 【ctx2】 停止指令已收到，马上停止
2022/11/04 14:11:49 【ctx3】 正在运行……
2022/11/04 14:11:49 【ctx0】 正在运行……
2022/11/04 14:11:50 【ctx0】 正在运行……
2022/11/04 14:11:50 【ctx3】 正在运行……
2022/11/04 14:11:51 【ctx3】 正在运行……
2022/11/04 14:11:51 【ctx0】 正在运行……
2022/11/04 14:11:52 【ctx0】 正在运行……
2022/11/04 14:11:52 【ctx3】 正在运行……
2022/11/04 14:11:53 【ctx3】 停止指令已收到，马上停止
2022/11/04 14:11:53 【ctx0】 正在运行……
2022/11/04 14:11:54 【ctx0】 正在运行……
2022/11/04 14:11:55 【ctx0】 正在运行……
2022/11/04 14:11:56 【ctx0】 正在运行……
2022/11/04 14:11:57 【ctx0】 正在运行……
2022/11/04 14:11:58 【ctx0】 停止指令已收到，马上停止
```
通过对运行结果的分析可以发现在 `stopCtx1` 执行前 所有的ctx都在运行

程序的启动时间为`2022-11-04 14:11:38` 很具代码来看 ctx1及ctx1_1、ctx1_2 都应该在5秒后停止即 `2022-11-04 14:11:43`

ctx2的停止直接与设置的deadline一致

ctx3与设置的超时时间一致

### Context传值

Context 不仅可以取消，还可以传值，通过这个能力，可以把 Context 存储的值供其他协程使用。

代码演示:
```go
func main() {
	fmt.Println("程序启动时间：", time.Now().Format("2006-01-02 15:04:05"))
	var wg sync.WaitGroup
	wg.Add(1)
	ctx, stop := context.WithCancel(context.Background())
	valCtx := context.WithValue(ctx, "userId", 123)
	go func() {
		defer wg.Done()
		getUser(valCtx)
	}()
	time.Sleep(5 * time.Second)
	stop()
	wg.Wait()
}
func getUser(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			log.Println("【获取用户】", "协程退出")
			return
		default:
			userId := ctx.Value("userId")
			log.Println("【获取用户】", "用户ID为：", userId)
			time.Sleep(1 * time.Second)
		}
	}
}


运行结果:

程序启动时间： 2022-11-04 14:19:36
2022/11/04 14:19:36 【获取用户】 用户ID为： 123
2022/11/04 14:19:37 【获取用户】 用户ID为： 123
2022/11/04 14:19:38 【获取用户】 用户ID为： 123
2022/11/04 14:19:39 【获取用户】 用户ID为： 123
2022/11/04 14:19:40 【获取用户】 用户ID为： 123
2022/11/04 14:19:41 【获取用户】 协程退出
```

### Context 使用原则

Context 是一种非常好的工具，使用它可以很方便地控制取消多个协程。在 Go 语言标准库中也使用了它们，比如 net/http 中使用 Context 取消网络的请求。

要更好地使用 Context，有一些使用原则需要尽可能地遵守。

> Context 不要放在结构体中，要以参数的方式传递。

> Context 作为函数的参数时，要放在第一位，也就是第一个参数。

> 要使用 context.Background 函数生成根节点的 Context，也就是最顶层的 Context。

> Context 传值要传递必须的值，而且要尽可能地少，不要什么都传。

> Context 多协程安全，可以在多个协程中放心使用。

以上原则是规范类的，Go 语言的编译器并不会做这些检查，要靠自己遵守。
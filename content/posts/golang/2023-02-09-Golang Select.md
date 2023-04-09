---
title: "Golang Select"
date: 2023-02-09T11:29:08+08:00
draft: false
tags:
- golang
categories:
- golang
---


## go select用处

select是一种go可以处理多个通道之间的机制，看起来和switch语句很相似，但是select其实和IO机制中的select一样，多路复用通道，随机选取一个进行执行，如果说通道(channel)实现了多个goroutine之前的同步或者通信，那么select则实现了多个通道(channel)的同步或者通信，并且select具有阻塞的特性。

<!--more-->

select 是 Go 中的一个控制结构，类似于用于通信的 switch 语句。每个 case 必须是一个通信操作，要么是发送要么是接收。

select 随机执行一个可运行的 case。如果没有 case 可运行，它将阻塞，直到有 case 可运行。一个默认的子句应该总是可运行的。

```go
select {
    case <-ch1:
        // 如果从 ch1 信道成功接收数据，则执行该分支代码
    case ch2 <- 1:
        // 如果成功向 ch2 信道成功发送数据，则执行该分支代码
    default:
        // 如果上面都没有成功，则进入 default 分支处理流程
}
```
select里的case后面并不带判断条件，而是一个信道的操作，不同于switch里的case

golang 的 select 就是监听 IO 操作，当 IO 操作发生时，触发相应的动作每个case语句里必须是一个IO操作，确切的说，应该是一个面向channel的IO操作。

> 注：Go 语言的 select 语句借鉴自 Unix 的 select() 函数，在 Unix 中，可以通过调用 select() 函数来监控一系列的文件句柄，一旦其中一个文件句柄发生了 IO 动作，该 select() 调用就会被返回（C 语言中就是这么做的），后来该机制也被用于实现高并发的 Socket 服务器程序。Go 语言直接在语言级别支持 select关键字，用于处理并发编程中通道之间异步 IO 通信问题。

注意：如果 ch1 或者 ch2 信道都阻塞的话，就会立即进入 default 分支，并不会阻塞。但是如果没有 default 语句，则会阻塞直到某个信道操作成功为止。

* select语句只能用于信道的读写操作

* select中的case条件(非阻塞)是并发执行的，select会选择先操作成功的那个case条件去执行，如果多个同时返回，则随机选择一个执行，此时将无法保证执行顺序。对于阻塞的case语句会直到其中有信道可以操作，如果有多个信道可操作，会随机选择其中一个 case 执行
* 对于case条件语句中，如果存在信道值为nil的读写操作，则该分支将被忽略，可以理解为从select语句中删除了这个case语句
* 如果有超时条件语句，判断逻辑为如果在这个时间段内一直没有满足条件的case,则执行这个超时case。如果此段时间内出现了可操作的case,则直接执行这个case。一般用超时语句代替了default语句
* 对于空的select{}，会引起死锁
* 对于for中的select{}, 也有可能会引起cpu占用过高的问题


## 示例

只能用于信道的操作
![](https://cdn.jsdelivr.net/gh/sxz799/tuchuang-blog/img/202302/202302091115011.png)

## select的特性场景

### 竞争选举
```go
func main() {
	ch1 := make(chan any, 1)
	ch2 := make(chan any, 1)
	ch3 := make(chan any, 1)
	ch1 <- 1
	ch2 <- 2
	ch3 <- 3
	select {
	case i := <-ch1:
		fmt.Printf("从ch1读取了数据%d", i)
	case j := <-ch2:
		fmt.Printf("从ch2读取了数据%d", j)
	case m := <-ch3:
		fmt.Printf("从ch3读取了数据%d", m)
	}
}

```

### 超时处理（保证不阻塞）
```go
func main() {
	ch1 := make(chan any, 1)

	go func() {
		time.Sleep(time.Second * 3)
		ch1 <- 1
	}()
	select {
	case str := <-ch1:
		fmt.Println("receive str", str)
	case <-time.After(time.Second * 5):
		fmt.Println("timeout!!")
	}

	ch2 := make(chan any, 1)
	go func() {
		time.Sleep(time.Second * 7)
		ch2 <- 1
	}()
	select {
	case str := <-ch2:
		fmt.Println("receive str", str)
	case <-time.After(time.Second * 5):
		fmt.Println("timeout!!")
	}

}

运行结果：
receive str 1
timeout!!

```

### 判断buffered channel是否阻塞

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	bufChan := make(chan int, 5)

	go func() {
		time.Sleep(time.Second)
		for {
			<-bufChan
			time.Sleep(5 * time.Second)
		}
	}()

	for {
		select {
		case bufChan <- 1:
			fmt.Println("add success")
			time.Sleep(time.Second)
		default:
			fmt.Println("资源已满，请稍后再试")
			time.Sleep(time.Second)
		}
	}
}
运行结果
add success
add success
add success
add success
add success
add success
add success
资源已满，请稍后再试
资源已满，请稍后再试
资源已满，请稍后再试
资源已满，请稍后再试
add success
资源已满，请稍后再试
资源已满，请稍后再试
资源已满，请稍后再试
资源已满，请稍后再试
add success
资源已满，请稍后再试
资源已满，请稍后再试
资源已满，请稍后再试
资源已满，请稍后再试
add success
资源已满，请稍后再试
资源已满，请稍后再试
...

```


### 阻塞main函数

```go
package main
import (
    "fmt"
    "time"
)

func main()  {
    bufChan := make(chan int)
    
    go func() {
        for{
            bufChan <-1
            time.Sleep(time.Second)
        }
    }()

    go func() {
        for{
            fmt.Println(<-bufChan)
        }
    }()
     
    select{}
}
```

如果换成for 也能阻塞main退出，但是对cpu的占用会变高
```go
package main
import (
    "fmt"
    "time"
)

func main()  {
    bufChan := make(chan int)
    
    go func() {
        for{
            bufChan <-1
            time.Sleep(time.Second)
        }
    }()


    go func() {
        for{
            fmt.Println(<-bufChan)
        }
    }()
     
    for{}
}
```

![](https://cdn.jsdelivr.net/gh/sxz799/tuchuang-blog/img/202302/202302091132277.png)

![](https://cdn.jsdelivr.net/gh/sxz799/tuchuang-blog/img/202302/202302091132405.png)

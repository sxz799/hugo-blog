---
title: Go语言使用channel进行goroutine通信
date: 2022-08-15 10:38:35
tags:
- go
categories:
- go基础


---
#### 声明channel

channel是go语言中的一种数据类型，也叫通道
声明方式
```go
ch:=make(chan string, n)
```
- ch : channel的变量名
- chan : 声明channel的关键字
- string : channel中存储额数据类型
- n: 缓冲长度(不填时代表无缓冲)
<!--more-->


> 如果给一个 nil 的 channel 发送数据，会造成永远阻塞。  
> 如果从一个 nil 的 channel 中接收数据，也会造成永久阻塞。 给一个已经关闭的 channel 发送数据，会引起 panic  
> 从一个已经关闭的 channel 接收数据，如果缓冲区中为空，则返回一个零 值。
> 无缓冲的 channel 是同步的，而有缓冲的 channel 是非同步的。 


## channel的操作
1.发送数据
```go
ch <- "你好"
```

2.接受数据
```go
str := <-ch
fmt.Println(str) // 你好
```
3.测试
```go
func main() {
	ch := make(chan string, 3) // 3 是指channel的缓冲长度为3
	i := 0
	go func() {
		for ; i < 10; i++ {
			ch <- strconv.Itoa(i)
			log.Println("向ch中->发送了  ", i, "此时ch的长度为：", len(ch))
		}
	}()
	go func() {
		for {
			time.Sleep(time.Second * 2)
			log.Println("在ch中<-取出了     ", <-ch, "此时ch的长度为:", len(ch))
		}
	}()
	for {
		time.Sleep(time.Second * 3)
		if len(ch) == 0 {
			break
		}
	}
}

输出结果：

2022/08/15 11:25:28 向ch中->发送了   0 此时ch的长度为： 1
2022/08/15 11:25:28 向ch中->发送了   1 此时ch的长度为： 2
2022/08/15 11:25:28 向ch中->发送了   2 此时ch的长度为： 3
2022/08/15 11:25:30 在ch中<-取出了      0 此时ch的长度为: 3
2022/08/15 11:25:30 向ch中->发送了   3 此时ch的长度为： 3
2022/08/15 11:25:32 向ch中->发送了   4 此时ch的长度为： 3
2022/08/15 11:25:32 在ch中<-取出了      1 此时ch的长度为: 3
2022/08/15 11:25:34 在ch中<-取出了      2 此时ch的长度为: 3
2022/08/15 11:25:34 向ch中->发送了   5 此时ch的长度为： 3
2022/08/15 11:25:36 在ch中<-取出了      3 此时ch的长度为: 3
2022/08/15 11:25:36 向ch中->发送了   6 此时ch的长度为： 3
2022/08/15 11:25:38 在ch中<-取出了      4 此时ch的长度为: 3
2022/08/15 11:25:38 向ch中->发送了   7 此时ch的长度为： 3
2022/08/15 11:25:40 在ch中<-取出了      5 此时ch的长度为: 3
2022/08/15 11:25:40 向ch中->发送了   8 此时ch的长度为： 3
2022/08/15 11:25:42 在ch中<-取出了      6 此时ch的长度为: 3
2022/08/15 11:25:42 向ch中->发送了   9 此时ch的长度为： 3
2022/08/15 11:25:44 在ch中<-取出了      7 此时ch的长度为: 2
2022/08/15 11:25:46 在ch中<-取出了      8 此时ch的长度为: 1
2022/08/15 11:25:48 在ch中<-取出了      9 此时ch的长度为: 0

```
4.结果解析

- 在第一个匿名函数中向channel中发送数据 由于ch的缓冲长度只有3 所以在 11:25:28 这一秒内连续发送了3个字符串进去后ch就开始阻塞

- 2秒后第二个匿名函数的Sleep结束开始在ch中取数据,取出一个数据后ch不再阻塞，有一个空闲位置，然后第一个匿名函数再往ch中写入一个数据就再次进入阻塞状态

- 就这样每2秒就取出一个数据然后再写入数据直到11:25:42 此时第一个匿名函数的for循环已经结束，第一个匿名函数已经执行完成了，第二个匿名函数仍在每2秒读取数据，此时ch的长度就开始减少了直到最后长度为0 程序退出


## select的使用
假设要从网上下载一个文件，我启动了 3 个 goroutine 进行下载，并把结果发送到 3 个 channel 中。其中，哪个先下载好，就会使用哪个 channel 的结果。这样我怎么知道才能知道那个channel中线有数据呢？通过下面的代码架构实现
```go
select {
case i1 = <-c1:
     //todo
case i2 <- c2:
	//todo
default:
	// default todo
}
```
下面实现刚才的模拟下载的代码
```go
func downloadFile(chanName string) string {
	//模拟下载文件,可以自己随机time.Sleep点时间试试
	rand.Seed(time.Now().Unix())
	time.Sleep(time.Second * time.Duration(rand.Intn(5)))
	return chanName + ":filePath"
}
func main() {
	firstCh := make(chan string)
	secondCh := make(chan string)
	threeCh := make(chan string)
	//同时开启3个goroutine下载
	go func() {
		firstCh <- downloadFile("firstCh")
	}()
	go func() {
		secondCh <- downloadFile("secondCh")
	}()
	go func() {
		threeCh <- downloadFile("threeCh")
	}()
	//开始select多路复用，哪个channel能获取到值，
	var finalPath string
	//就说明哪个最先下载好，就用哪个。
	select {
	case filePath := <-firstCh:
		finalPath = filePath
	case filePath := <-secondCh:
		finalPath = filePath
	case filePath := <-threeCh:
		finalPath = filePath
	}
	fmt.Println(finalPath)
}
```
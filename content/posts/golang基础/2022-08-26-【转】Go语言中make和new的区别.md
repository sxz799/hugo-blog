---
title: Go语言中make和new的区别
date: 2022-08-26 13:55:59
tags:
- go
categories:
- go基础


---
程序的运行都需要内存，比如像变量的创建、函数的调用、数据的计算等。所以在需要内存的时候就要申请内存，进行内存分配。在 C/C++ 这类语言中，内存是由开发者自己管理的，需要主动申请和释放，而在 Go 语言中则是由该语言自己管理的，开发者不用做太多干涉，只需要声明变量，Go 语言就会根据变量的类型自动分配相应的内存。
<!--more-->
Go 语言程序所管理的虚拟内存空间会被分为两部分：`堆内存`和`栈内存`。栈内存主要由 Go 语言来管理，开发者无法干涉太多，堆内存才是我们开发者发挥能力的舞台，因为程序的数据大部分分配在堆内存上，一个程序的大部分内存占用也是在堆内存上。

> 小提示：我们常说的 Go 语言的内存垃圾回收是针对堆内存的垃圾回收。

变量的声明、初始化就涉及内存的分配，比如声明变量会用到 var 关键字，如果要对变量初始化，就会用到 = 赋值运算符。除此之外还可以使用内置函数 new 和 make，这两个函数在前面的代码中已经见过，它们的功能非常相似，但可能还是比较迷惑，今天就基于内存分配，进而引出内置函数 new 和 make，学习他们的不同，以及使用场景。
## 变量
### 变量的声明
`var s string //使用var关键字声明一个变量`

该示例只是声明了一个变量 s，类型为 string，并没有对它进行初始化，所以它的值为 string 的零值，也就是 ""（空字符串）。

之前学到 string 其实是个值类型，现在我们来声明一个指针类型的变量试试，如下所示：

`var sp *string`

发现也是可以的，但是它同样没有被初始化，所以它的值是 *string 类型的零值，也就是 nil。

### 变量的赋值
变量可以通过 = 运算符赋值，也就是修改变量的值。如果在声明一个变量的时候就给这个变量赋值，这种操作就称为变量的初始化。如果要对一个变量初始化，可以有三种办法。
*  声明时直接初始化，比如 var s string = "我的Blog"。
*  声明后再进行初始化，比如  s="我的Blog"（假设已经声明变量 s）。
*  使用 := 简单声明，比如 s:="我的Blog"。

> 小提示：变量的初始化也是一种赋值，只不过它发生在变量声明的时候，时机最靠前。也就是说，当你获得这个变量时，它就已经被赋值了。

下面通过代码演示
```go
func main() {
   var s string
   s = "张三"
   fmt.Println(s)
}
运行结果：
张三
```
看下面的代码
```go
func main() {
   var sp *string
   fmt.Println(sp)
   *sp = "Golang"
   fmt.Println(*sp)
}
运行结果：
<nil>
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x108979a]

```
可以看到通过var直接声明一个指针 此时他的值是nil
而对于值类型来说，即使只声明一个变量，没有对其初始化，该变量也会有分配好的内存。
在下面的示例中，我声明了一个变量 s，并没有对其初始化，但是可以通过 &s 获取它的内存地址。这其实是 Go 语言帮我们做的，可以直接使用。
```go
func main() {
   var s string
   fmt.Printf("%p\n",&s)
}
运行结果
0xc00010c210

```

于是可以得到结论：**如果要对一个变量赋值，这个变量必须有对应的分配好的内存，这样才可以对这块内存操作，完成赋值的目的**。
> 小提示：其实不止赋值操作，对于指针变量，如果没有分配内存，取值操作一样会报 nil 异常，因为没有可以操作的内存。

所以一个变量必须要经过声明、内存分配才能赋值，才可以在声明的时候进行初始化。指针类型在声明的时候，Go 语言并没有自动分配内存，所以不能对其进行赋值操作，这和值类型不一样。
> 小提示：map 和 chan 也一样，因为它们本质上也是指针类型。

所以下面这段代码就会报错
```go
func main() {
	var mp map[string]int
	mp["小米"] = 16
}
运行结果
panic: assignment to entry in nil map

```

## new 函数

上面我们发现声明指针后是没有分配内存的，那么new函数就是用来分配内存的
```go
func main() {
   var sp *string
   fmt.Println(sp)
   sp = new(string)//关键点
   fmt.Println(sp)
   *sp = "张三"
   fmt.Println(*sp)
}
运行结果
<nil>
0xc000010250
张三

```
通过结果我们发现 `sp = new(string)`执行后 指针sp就指向了0xc000010250 再给这块内存赋值就没问题了。

内置函数 new 的作用是什么呢？可以通过它的源代码定义分析，如下所示：
```go
// The new built-in function allocates memory. The first argument is a type,
// not a value, and the value returned is a pointer to a newly
// allocated zero value of that type.
func new(Type) *Type
``` 
它的作用就是根据传入的类型申请一块内存，然后返回指向这块内存的指针，指针指向的数据就是该类型的零值。

## 变量初始化

### 值类型初始化
不在多说了，看下演示代码即可
```go
type person struct {
	name string
	age  int
}

func main() {
	var s string = "golang"
	s1 := "golang2"
	p := person{name: "张三", age: 18}
}

```

### 指针变量初始化
在前面我们知道了 new 函数可以申请内存并返回一个指向该内存的指针，但是这块内存中数据的值默认是该类型的零值，在一些情况下并不满足业务需求。比如我想得到一个 *person 类型的指针，并且它的 name 是张三、age 是 20，但是 new 函数只有一个类型参数，并没有初始化值的参数，此时该怎么办呢？要达到这个目的可以自定义一个函数，对指针变量进行初始化，如下所示：
```go
type person struct {
	name string
	age  int
}

func NewPerson() *person{
   p:=new(person)
   p.name = "张三"
   p.age = 20
   return p
}
func main() {
	pp := NewPerson()
	fmt.Print(pp)
}
运行结果
&{张三 20}

```

也可以对NewPerson函数进行优化，让他可以接受参数
```go
type person struct {
	name string
	age  int
}

func NewPerson(name string, age int) *person {
	p := new(person)
	p.name = name
	p.age = age
	return p
}
func main() {
	pp := NewPerson("李四", 22)
	fmt.Print(pp)
}

运行结果
&{李四 22}

```

### make 函数
在使用 make 函数创建 map 的时候，其实调用的是 makemap 函数，如下所示：
```go
// makemap implements Go map creation for make(map[k]v, hint).
func makemap(t *maptype, hint int, h *hmap) *hmap{
  //省略无关代码
}
```
makemap 函数返回的是 *hmap 类型，而 hmap 是一个结构体，它的定义如下面的代码所示：
```go
// A header for a Go map.
type hmap struct {
   // Note: the format of the hmap is also encoded in cmd/compile/internal/gc/reflect.go.
   // Make sure this stays in sync with the compiler's definition.
   count     int // # live cells == size of map.  Must be first (used by len() builtin)
   flags     uint8
   B         uint8  // log_2 of # of buckets (can hold up to loadFactor * 2^B items)
   noverflow uint16 // approximate number of overflow buckets; see incrnoverflow for details
   hash0     uint32 // hash seed
   buckets    unsafe.Pointer // array of 2^B Buckets. may be nil if count==0.
   oldbuckets unsafe.Pointer // previous bucket array of half the size, non-nil only when growing
   nevacuate  uintptr        // progress counter for evacuation (buckets less than this have been evacuated)
   extra *mapextra // optional fields
}
```
可以看到，我们平时使用的 map 关键字其实非常复杂，它包含 map 的大小 count、存储桶 buckets 等。要想使用这样的 hmap，不是简单地通过 new 函数返回一个 *hmap 就可以，还需要对其进行初始化，这就是 make 函数要做的事情，如下所示：

`m:=make(map[string]int,10)`

是不是发现 make 函数和上一小节中自定义的 NewPerson 函数很像？其实 make 函数就是 map 类型的工厂函数，它可以根据传递它的 K-V 键值对类型，创建不同类型的 map，同时可以初始化 map 的大小。
> 小提示：make 函数不只是 map 类型的工厂函数，还是 chan、slice 的工厂函数。它同时可以用于 slice、chan 和 map 这三种类型的初始化。

## 总结
new 函数只用于分配内存，并且把内存清零，也就是返回一个指向对应类型零值的指针。new 函数一般用于需要显式地返回指针的情况，不是太常用。

make 函数只用于 slice、chan 和 map 这三种内置类型的创建和初始化，因为这三种类型的结构比较复杂，比如 slice 要提前初始化好内部元素的类型，slice 的长度和容量等，这样才可以更好地使用它们。

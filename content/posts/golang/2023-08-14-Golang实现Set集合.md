---
title: "Golang实现Set集合"
date: 2023-08-14T10:17:14+08:00
lastmod: 2023-08-14T10:17:14+08:00
draft: false
tags:
- golang
categories:
- goalng
---


代码:

<!--more-->

``` go
package main

import (
	"fmt"
)

type Empty struct {
}

type Set struct {
	m map[any]Empty
}

func (s *Set) Add(items ...interface{}) {
	for _, item := range items {
		s.m[item] = Empty{}
	}
}

func (s *Set) Remove(item any) {
	delete(s.m, item)
}

func (s *Set) Contains(item any) bool {
	_, ok := s.m[item]
	return ok
}

func (s *Set) Clear() {
	s.m = make(map[any]Empty)
}

func (s *Set) Size() int {
	return len(s.m)
}

func NewSet(items ...any) *Set {
	s := &Set{}
	s.m = make(map[any]Empty)
	s.Add(items...)
	return s
}

func main() {
	set := NewSet("AA", "C", 546, false, false, true)
	for a := range set.m {
		fmt.Print(" ", a)
	}
	fmt.Println()
	set.Add("dd", "ff", 23.2)
	set.Remove("C")
	for a := range set.m {
		fmt.Print(" ", a)
	}
	set.Clear()
	fmt.Println()
	fmt.Println("Size: ", set.Size())
}
```

//运行结果
> AA C 546 false true  
> 546 false true dd ff 23.2 AA  
> Size:  0  



<!--more-->

---
title: 【转】如何解决经典的Too many connections故障？背后原理是什么
date: 2022-05-09 14:49:06
tags: 
- mysql
categories:
- mysql笔记


---

其实核心就是一行命令：
<!--more-->
ulimit -HSn 65535

然后就可以用如下命令检查最大文件句柄数是否被修改了
```
cat /etc/security/limits.conf
```

如果都修改好之后，可以在MySQL的my.cnf里确保max_connections参数也调整好了，然后可以重启服务器，然后重启MySQL，这样的话，linux的最大文件句柄就会生效了，MySQL的最大连接数也会生效了。

设置之后，我们要确保变更落地到/etc/security/limits.conf文件里，永久性的设置进程的资源限制

所以执行ulimit -HSn 65535命令后，要用如下命令检查一下是否落地到配置文件里去了。
```
cat /etc/security/limits.conf
```
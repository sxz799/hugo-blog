---
title: "ssh生成密钥命令及配置"
date: 2023-11-30T19:48:37+08:00
lastmod: 2023-11-30T19:48:37+08:00
draft: false
tags:
- ssh
categories:
- 技巧
---

记录一下使用ssh-keygen生成ssh密钥说明
<!--more-->
```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

一路回车即可
```
cat ~/.ssh/id_rsa.pub
```


如果出现错误提示`kex_exchange_identification: Connection closed by remote`  
解决方案:
~/.ssh/config 文件（没有就新增）

```
Host github.com
    HostName ssh.github.com
    # ProxyCommand nc -X 5 -x 127.0.0.1:7890 %h %p ## 配置使用socks5代理连接
    User git
    Port 443

```

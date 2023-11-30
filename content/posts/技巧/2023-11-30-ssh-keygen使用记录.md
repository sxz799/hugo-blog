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



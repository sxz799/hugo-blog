---
title: "2023 05 12 Github拉取代码时提示kex_exchange_identification解决方案"
date: 2023-05-12T19:58:41+08:00
lastmod: 2023-05-12T19:58:41+08:00
draft: false
tags:
categories:
---

最近在github上拉取和推送代码时经常报`kex_exchange_identification`的错误,但是更换手机热点后就可以正常推代码,查了一下发现可能是梯子的问题，这里记录一下搜到的解决方案。

<!--more-->

## 解决方案

在`.ssh`目录下创建一个config文件,内容如下

```
Host github.com
    HostName ssh.github.com
    User git
    Port 443
```

如果这个文件已经存在,添加或修改对应内容即可。主要目的是使用443端口。

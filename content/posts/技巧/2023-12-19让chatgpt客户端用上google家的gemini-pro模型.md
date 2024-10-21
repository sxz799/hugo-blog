---
title: "让chatgpt客户端用上google家的geminipro模型"
date: 2023-12-19T10:57:03+08:00
lastmod: 2023-12-19T10:57:03+08:00
draft: false
tags:
- chatgpt
- gemini
categories:
- 技巧
---

google在前段时间发布了gemini大模型，目前中号的gemini-pro已经免费开放使用,只需要申请api即可。但是目前在国内还是有一定的使用门槛的，所以写这篇日志来记录下如何流程使用gemini模型。

[项目地址](https://github.com/sxz799/gemini2chatgpt)

<!--more-->

## 前提条件

1. 谷歌账号
2. 科学上网环境(准备阶段使用)
3. github账号(非必要,如果有的话，可以给我点个star)

## 第一步 申请gemini模型API

[申请地址:https://ai.google.dev/?hl=zh-cn](https://ai.google.dev/?hl=zh-cn)

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/19/20231219111232.png)

点击后需要你登录谷歌账号，就不在截图展示了

进入Google AI Studio后 点击 `Get Api key`  
再点击 `Create API key in new project` ,复制保存生成的API key 备用
![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/19/20231219111414.png)



## 第二步 使用Render构建API转换接口

### 旧方案(已收费)

[Render:https://dashboard.render.com/](https://dashboard.render.com/)

使用google账号或者github账号登录(也可以用邮箱登录),登录后进入控制台

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/19/20231219111927.png)


新建一个 Web Service 选择第二项

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/19/20231219112731.png)

在 Image URL里填写 `sxz799/gemini2chatgpt:latest`
等待输入框右侧出现绿的的对号就可以点Next了

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/19/20231219112943.png)

项目名称可以随便填 地区选一个和你距离近的 重要的是类型勾选`Free` (钱多就当我没说)

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/19/20231219113139.png)


最后点击最下面的蓝色的Create Web Service

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/19/20231219113633.png)

耐心等待几分钟，让项目部署起来。等出现了Live标志项目就部署好了，这时复制左上角的网址，这个就是gemini的接口地址了。
打开连接后出现部署成功就说明成功了。

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/19/20231219113608.png)

### 新方案

render账号绑定github后fork[项目](https://github.com/sxz799/gemini2chatgpt)  
创建web Service时从仓库中选择，这样就又出现免费选项了

## 第三步 在支持chatgpt的应用中使用

在chat-next-web中使用

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/19/20231219122819.png)

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/12/20/20231220143710.png)


## 备注

由于Render免费容器,在没有访问请求的时候会自动暂停,所以你需要一个定时任务来唤醒render.频率设置在5分钟一次即可。









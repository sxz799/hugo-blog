---
title: "使用Vercel部署托管在github上的前端项目"
date: 2023-04-06T16:40:53+08:00
lastmod: 2023-04-06T16:40:53+08:00
draft: false
tags:
- 技巧
- Vercel
- Vue
- 前端
categories:
- 技巧

---

之前写了一个便携剪切板小工具，部署在家里的群晖上面，方便工作时随时写日报。前段时间发现可以用Vercel部署前端项目，还可以自定义域名，这样就不用每次都输入端口信息了。

<!--more-->



### 申请Vercel账号

[官网链接](https://vercel.com/login)建议直接使用github登录。

### 导入github上的前端项目

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202304/202304061645020.png)

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202304/202304061646153.png)

导入很简单，点几下鼠标就可以。

导入完成后页面大概这个样子，可以直接点击预览图进入

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202304/202304061647953.png)

### 配置域名

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202304/202304061650162.png)

根据提示操作即可，刚导入的项目，绿框那里应该是有一个默认的域名的。

添加域名后，会提示让你在你的域名控制台添加一条CNAME的解析记录，按照提示添加即可。

解析记录添加完成后,vercel会自动帮你申请并配置SSL证书。


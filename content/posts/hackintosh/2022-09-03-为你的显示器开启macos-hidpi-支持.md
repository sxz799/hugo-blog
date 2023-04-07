---
title: 为你的显示器开启macos hidpi 支持
date: 2022-09-03 23:03:07
categories:
- hackintosh
tags:
- hackintosh

---

## 前言
前段时间购买了一个4k分辨率的便携显示器,连接nuc8黑苹果后发现无法开启hidpi 但是在缩放分辨率中能看到1080p的选项，使用此选项也能实现hidpi的效果，但是作为一个强迫症患者，不能在设置中原始显示还是有点难受的。所以就有了这个教程。
<!--more-->
为什么不用github上的脚本呢？没有为什么，就是不喜欢脚本。

## 准备工作

hackintool软件 [下载地址](https://github.com/headkaze/Hackintool/releases)

## 正式开始
### 第一步 打开hackintool软件并切换到显示器页

![](https://raw.githubusercontent.com/sxzhi799/blog_tuchuang/main/img/202209/202209132317669.png)

### 第二步 根据显示器真实分辨率选择配置
* 4k显示器

![](https://raw.githubusercontent.com/sxzhi799/blog_tuchuang/main/img/202209/202209132318541.png)

* 2k显示器

![](https://raw.githubusercontent.com/sxzhi799/blog_tuchuang/main/img/202209/202209132319359.png)


操作完成后会在桌面出现这三个文件及一个目录,我们需要的就是这一个一DisplayVender-xxxx的目录

![](https://raw.githubusercontent.com/sxzhi799/blog_tuchuang/main/img/202209/202209132320165.png)

![](https://raw.githubusercontent.com/sxzhi799/blog_tuchuang/main/img/202209/202209132320000.png)

### 第三步 将目录放到指定文件夹内重启即可
我用的是macos12.5系统

`/Library/Displays/Contents/Resources/Overrides`

关于这个目录可以查看hackintool的帮助页面


如果找不到这个目录，按照路径创建目录即可，如果没有权限，就用终端获取管理员权限后创建


下面内容是hackintool的官方说明
```
显示器EDID修补
使用EDID修补你可以进行显示器型号的修改以及添加缩放选项。操作方法如下：
    1.从显示列表中选择你要编辑的显示器
    2.如果显示器的EDID没有分辨率范围或不好，有选择性地添加/修复分辨率范围
    3.单击“添加”按钮添加分辨率，再单击分辨率值进行编辑。选中某个分辨率值再点击“删除”按钮即可删除此分辨率。
    4.编辑完成后，点击“导出”按钮在桌面上生成修改好的补丁文件。
安装
安装EDID补丁有两种方法：安装显示器补丁文件，以及显示器驱动：
安装显示器补丁文件：
    •将生成的DisplayVendorID-x文件夹复制到/system/library/displays/contents/resources/overrides（对于El Capitan系统则是/system/library/displays/overrides ）
    •将生成的icons.plist复制到/system/library/displays/contents/resources/overrides（对于El Capitan则是/system/library/displays/overrides）
安装显示器驱动：
   •将生成的DisplayEDID-x-x.kext复制到/library/extensions或efi/clover/kexts/other（取决于您的配置）
注意：在复制文件之前，请先关闭系统完整性保护（SIP)

其他信息
对于16:10且想使用缩放分辨率的显示器，可以选择如下类型显示器：

•iMac显示器

•MacBook Pro显示器

•影院高清显示器

•LED影院显示屏

对于16:9的，则可以选择：

•Apple Thunderbolt显示器（此种切勿用在内部显示器上！）

•iMac视网膜显示

•MacBook Air显示器
```

### 第四步 重启电脑查看是否生效

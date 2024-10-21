---
title: "GithubAction自动编译项目学习笔记"
date: 2023-05-09T14:32:21+08:00
lastmod: 2023-05-09T14:32:21+08:00
draft: false
tags:
 - github
 - 自动化
categories:
 - 技巧
---

最近项目上线要将旧系统的数据导入新系统，旧系统的数据导出到excel文件，然后将文件整理后导入新系统。但是整理文件的时候总是会出现一些简单的错误，每次都有人工校对或者导入时提示太麻烦，于是写了一个小工具让整理数据的门店人员整理数据后自行检测一次。由于数据库使用的是sqlite，我本地的开发环境又是mac，这就导致golang交叉编译时要配置gcc,试了一下，感觉太麻烦了。也尝试过开个虚拟机进行编译，发现效果也不满意。后来发现github action可以在推送项目后自动构建项目，于是实现了项目推到github后,由Github自动编译并打包项目。

<!--more-->

### 在github仓库的Action页面创建workflow

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202305/202305101403088.png)

可以在这里根据你项目类型选择一个现有的模板进行创建(这里创建后会在项目根目录创建一个`.github`隐藏目录，目录内有一个`workflows`文件夹,文件夹里面就是一个yml格式的CI配置文件，所以记得在本地 git pull一下把这个目录拉到本地)

### 一个脚本的注释说明
```yml
name: CI

# 标识在推送 main 分支时执行
on:
  push:
    branches: [main]
# 任务列表
jobs:
  # 任务名称
  build:
    # 策略 和后面用到的编译环境相关
    strategy:
      matrix:
        node-version: [16.x]
        # See supported Node.js release schedule at https://nodejs.org/en/about/releases/
    # 运行环境  支持 ubunutu Windows macos
    runs-on: ubuntu-latest
    # 容器 我这里使用容器是因为项目要部署到centos系统 而且用到了sqlite 编译是需要gcc环境
    container: docker.io/centos:7
    # 步骤
    steps:
      # 使用checkout切换到指定分支
    - uses: actions/checkout@v3
      # 安装依赖 针对上面提到的gcc 非必要
    - name: intall deps
      run: |
        yum install -y wget tar gcc automake autoconf libtool make
      # 配置go 编译环境
    - name: Set up Go
      uses: actions/setup-go@v3
      with:
        go-version: 1.19
      # 执行编译任务 工作目录在当前目录的server目录内 编译后的app文件在 server/bin 内 后面任务会用到这个文件
    - name: Build Server
      run:  go build -ldflags="-s -w" -o bin/app .
      working-directory: ./server
      

     # 配置前端node 编译环境
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
     # 执行编译任务 工作目录在当前目录的web目录内 编译后的app文件在 web/dist 内 后面任务会用到这个文件
    - name: Build Web
      run: npm install && npm run build
      working-directory: ./web
     # 移动编译好的文到 gsCheck 目录内
    - name: Move  Files
      run: |
        mkdir gsCheck
        mv server/bin/app gsCheck/
        mv web/dist gsCheck/dist/
     # 指定上传任务 将编译环境内的gsCheck目录内的文件打包为 gscheck-artifact.zip 进行上传
    - name: Upload artifact
      uses: actions/upload-artifact@v2
      with:
       name: gscheck-artifact
       path: ${{ github.workspace }}/gsCheck
     # 指定下载任务 将gscheck-artifact.zip下载 方便你下载编译后的文件
    - name: Download a Build Artifact
      uses: actions/download-artifact@v2.1.1
      with:
       name: gscheck-artifact
    
```

### 下载自动编译后打包的文件

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202305/202305101418953.png)

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202305/202305101418243.png)




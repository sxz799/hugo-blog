---
title: Gin+Vue前后端分离整合部署，不再需要nginx服务器
date: 2022-09-26 19:46:33
tags:
- Gin
- vue
categories:
- 技巧

---

## 前言

最近在学前端，写了个很小的项目
[fileshare-go](https://github.com/sxz799/fileshare-go)

前后端分离,分别用到了antdesignvue和elementUI。
单页面项目，如果用前后端分离去部署的话实在是麻烦。
<!--more-->
Gin框架自带了静态文件服务,所以只需要简单修改代码即可实现前后端整合，当然开发的时候前后端仍然是分离的。

## 修改前端
前端修改起来超级简单
```h
## vue.config.js

const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  publicPath: "/static", //加上这一行即可
  devServer: {
    port: 4000,
    proxy: {
      '/file': {
        ws: false,
        target: "http://127.0.0.1:9091",
        changeOrigin: true
      }
    }
  },
})
```

## 修改后端
后端也是很简单的
在main.go的同级目录下新建一个static目录，然后将前端生成的dist目录下的所有文件都放进去。
然后再gin注册路由之前加上下面的代码即可
```go
func main() {
	util.InitDB()
	model.InitAutoMigrateDB()
	r := gin.Default()

    ///添加的代码///
	r.LoadHTMLGlob("static/index.html")
	r.Static("/static", "static")
	r.GET("/", func(context *gin.Context) {
		context.HTML(200, "index.html", "")
	})
    ////////

	router.RegRouter(r)
	r.Run(":" + viper.GetString("server.port"))
}
```

## 打包项目
后端编译后只需要将static目录和主程序一块打包即可。

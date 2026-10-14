---
title: antdesignvue在iPhone手机上传文件时选择文件
date: 2022-10-10 23:54:47
tags:
- 技巧
- Vue
- Antd
- 前端
categories:
- 技巧


---

还是这个项目[fileshare-go](https://github.com/sxz799/fileshare-go)的前端相关内容。

突然发现在iPhone上级上传文件的时候直接打开了相机，而在安卓手机上就可以选择相机或者文件。

搜索后发现只需要添加`:capture="null"`即可。
代码如下：
<!--more-->
```html
<div>
        <a-upload-dragger :progress="progress" name="file" :before-upload="beforeUpload" :showUploadList="true"
          :capture="null" :multiple="false" action="/file/upload" @change="handleChange">
          <p class="ant-upload-drag-icon">
            <inbox-outlined></inbox-outlined>
          </p>
          <p class="ant-upload-text">点击或拖拽文件到这里进行上传</p>
        </a-upload-dragger>
</div>
```
这样的话iPhone手机就可以选择图库或者文件了！


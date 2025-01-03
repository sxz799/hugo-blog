---
title: "ruoyi集成minio后的踩坑记录"
date: 2023-10-14T16:43:25+08:00
lastmod: 2023-10-14T16:43:25+08:00
draft: false
tags:
- minio
- ruoyi
categories:
- 技巧
---

上篇文章记录了ruoyi集成minio,今天继续记录一下后续的踩坑及问题处理


<!--more-->



## 1.form表单上传图片后不显示

上传图片后文件确实存到了minio里但是预览界面不显示图片，保存表单后在el-table中却能正常显示。  
### 问题分析
上传图片后数据库里存放的是文件的url 如`http://localhost:9000/ruoyi/2023/10/14/4343_2023/1014003014A006.png`

在ruoyi生成的代码中 el-table中图片用的是封装好的 `image-preview`组件
```
<image-preview :src="scope.row.pic" :width="50" :height="50"/>
```
scope.row.pic的内容就是数据库里存的`http://localhost:9000/ruoyi/2023/10/14/4343_2023/1014003014A006.png`所以可以正常显示

但是在表单中上传文件用的组件是封装好的`image-upload`
```
<image-upload v-model="form.pic"/>
```
下面是image-upload组件源码
```html
<template>
  <div class="component-upload-image">
    <el-upload
      multiple
      :action="uploadImgUrl"
      list-type="picture-card"
      :on-success="handleUploadSuccess"
      :before-upload="handleBeforeUpload"
      :limit="limit"
      :on-error="handleUploadError"
      :on-exceed="handleExceed"
      ref="imageUpload"
      :on-remove="handleDelete"
      :show-file-list="true"
      :headers="headers"
      :file-list="fileList"
      :on-preview="handlePictureCardPreview"
      :class="{hide: this.fileList.length >= this.limit}"
    >
      <i class="el-icon-plus"></i>
    </el-upload>

    <!-- 上传提示 -->
    <div class="el-upload__tip" slot="tip" v-if="showTip">
      请上传
      <template v-if="fileSize"> 大小不超过 <b style="color: #f56c6c">{{ fileSize }}MB</b> </template>
      <template v-if="fileType"> 格式为 <b style="color: #f56c6c">{{ fileType.join("/") }}</b> </template>
      的文件
    </div>

    <el-dialog
      :visible.sync="dialogVisible"
      title="预览"
      width="800"
      append-to-body
    >
      <img
        :src="dialogImageUrl"
        style="display: block; max-width: 100%; margin: 0 auto"
      />
    </el-dialog>
  </div>
</template>

<script>
import { getToken } from "@/utils/auth";

export default {
  props: {
    value: [String, Object, Array],
    // 图片数量限制
    limit: {
      type: Number,
      default: 5,
    },
    // 大小限制(MB)
    fileSize: {
       type: Number,
      default: 5,
    },
    // 文件类型, 例如['png', 'jpg', 'jpeg']
    fileType: {
      type: Array,
      default: () => ["png", "jpg", "jpeg"],
    },
    // 是否显示提示
    isShowTip: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      number: 0,
      uploadList: [],
      dialogImageUrl: "",
      dialogVisible: false,
      hideUpload: false,
      baseUrl: process.env.VUE_APP_BASE_API,
      uploadImgUrl: process.env.VUE_APP_BASE_API + "/common/uploadMinio", // 上传的图片服务器地址
      headers: {
        Authorization: "Bearer " + getToken(),
      },
      fileList: []
    };
  },
  watch: {
    value: {
      handler(val) {
        if (val) {
          // 首先将值转为数组
          const list = Array.isArray(val) ? val : this.value.split(',');
          // 然后将数组转为对象数组
          this.fileList = list.map(item => {
            if (typeof item === "string") {
              if (item.indexOf(this.baseUrl) === -1) {
                  item = { name: this.baseUrl + item, url: this.baseUrl + item };
              } else {
                  item = { name: item, url: item };
              }
            }
            return item;
          });
        } else {
          this.fileList = [];
          return [];
        }
      },
      deep: true,
      immediate: true
    }
  },
  computed: {
    // 是否显示提示
    showTip() {
      return this.isShowTip && (this.fileType || this.fileSize);
    },
  },
  methods: {
    // 上传前loading加载
    handleBeforeUpload(file) {
      let isImg = false;
      if (this.fileType.length) {
        let fileExtension = "";
        if (file.name.lastIndexOf(".") > -1) {
          fileExtension = file.name.slice(file.name.lastIndexOf(".") + 1);
        }
        isImg = this.fileType.some(type => {
          if (file.type.indexOf(type) > -1) return true;
          if (fileExtension && fileExtension.indexOf(type) > -1) return true;
          return false;
        });
      } else {
        isImg = file.type.indexOf("image") > -1;
      }

      if (!isImg) {
        this.$modal.msgError(`文件格式不正确, 请上传${this.fileType.join("/")}图片格式文件!`);
        return false;
      }
      if (this.fileSize) {
        const isLt = file.size / 1024 / 1024 < this.fileSize;
        if (!isLt) {
          this.$modal.msgError(`上传头像图片大小不能超过 ${this.fileSize} MB!`);
          return false;
        }
      }
      this.$modal.loading("正在上传图片，请稍候...");
      this.number++;
    },
    // 文件个数超出
    handleExceed() {
      this.$modal.msgError(`上传文件数量不能超过 ${this.limit} 个!`);
    },
    // 上传成功回调
    handleUploadSuccess(res, file) {
      if (res.code === 200) {
        this.uploadList.push({ name: res.fileName, url: res.fileName });
        this.uploadedSuccessfully();
      } else {
        this.number--;
        this.$modal.closeLoading();
        this.$modal.msgError(res.msg);
        this.$refs.imageUpload.handleRemove(file);
        this.uploadedSuccessfully();
      }
    },
    // 删除图片
    handleDelete(file) {
      const findex = this.fileList.map(f => f.name).indexOf(file.name);
      if(findex > -1) {
        this.fileList.splice(findex, 1);
        this.$emit("input", this.listToString(this.fileList));
      }
    },
    // 上传失败
    handleUploadError() {
      this.$modal.msgError("上传图片失败，请重试");
      this.$modal.closeLoading();
    },
    // 上传结束处理
    uploadedSuccessfully() {
      if (this.number > 0 && this.uploadList.length === this.number) {
        this.fileList = this.fileList.concat(this.uploadList);
        this.uploadList = [];
        this.number = 0;
        this.$emit("input", this.listToString(this.fileList));
        this.$modal.closeLoading();
      }
    },
    // 预览
    handlePictureCardPreview(file) {
      this.dialogImageUrl = file.url;
      this.dialogVisible = true;
    },
    // 对象转成指定字符串分隔
    listToString(list, separator) {
      let strs = "";
      separator = separator || ",";
      for (let i in list) {
        if (list[i].url) {
          strs += list[i].url.replace(this.baseUrl, "") + separator;
        }
      }
      return strs != '' ? strs.substr(0, strs.length - 1) : '';
    }
  }
};
</script>
<style scoped lang="scss">
// .el-upload--picture-card 控制加号部分
::v-deep.hide .el-upload--picture-card {
    display: none;
}
// 去掉动画效果
::v-deep .el-list-enter-active,
::v-deep .el-list-leave-active {
    transition: all 0s;
}

::v-deep .el-list-enter, .el-list-leave-active {
    opacity: 0;
    transform: translateY(0);
}
</style>


```


重点在下面这部分代码

```js

<el-upload
      <!-- 无关紧要的代码  -->
      :file-list="fileList"
      <!-- 无关紧要的代码  -->
    >
<!-- 无关紧要的代码  -->
watch: {
    value: {
      handler(val) {
        if (val) {
          // 首先将值转为数组
          const list = Array.isArray(val) ? val : this.value.split(',');
          // 然后将数组转为对象数组
          this.fileList = list.map(item => {
            if (typeof item === "string") {
              if (item.indexOf(this.baseUrl) === -1) {
                  item = { name: this.baseUrl + item, url: this.baseUrl + item };
              } else {
                  item = { name: item, url: item };
              }
            }
            return item;
          });
        } else {
          this.fileList = [];
          return [];
        }
      },
      deep: true,
      immediate: true
    }
  },
```

我们看一下elementui的文档
![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/10/2023/10140052839.png)

这个file-list存的应该是图片的实际url,而这个组件默认是存储在服务器本地所以封装后给我们拼接了baseUrl
而这个baseUrl
```js
data() {
    return {
      //省略部分代码
      baseUrl: process.env.VUE_APP_BASE_API,
      //省略部分代码
    };
  },
```
通过开发者工具我们也能看到图片的请求地址如下  

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/10/2023/10140056386.png)

这样我们就只需要去掉前面拼接的url地址即可  

```js
data() {
    return {
      //省略部分代码
      //baseUrl: process.env.VUE_APP_BASE_API, //文件存储在本地
      baseUrl: "", //文件存储在OSS
      //省略部分代码
    };
```

修改后我们再看下效果

![](https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/2023/10/2023/10140100621.png)

而且预览也是没问题的,问题完美解决!

当然除了图片上传 ruoyi封装的其他组件(文件上传、富文本等)也有同样的问题,解决方案也都差不多,去掉process.env.VUE_APP_BASE_API即可！

## 2.文件上传组件`file-upload`

和图片上传组件修改方式相同!

## 3.富文本编辑器`editor`

原理是相同的，但是改的地方不一样
```js
handleUploadSuccess(res, file) {
      // 如果上传成功
      if (res.code == 200) {
        // 获取富文本组件实例
        let quill = this.Quill;
        // 获取光标所在位置
        let length = quill.getSelection().index;
        // 插入图片  res.url为服务器返回的图片地址
        //quill.insertEmbed(length, "image", process.env.VUE_APP_BASE_API + res.fileName);
        // 插入图片  res.url为服务器返回的图片地址 存储在OSS中
        quill.insertEmbed(length, "image", res.fileName);
        // 调整光标到最后
        quill.setSelection(length + 1);
      } else {
        this.$message.error("图片插入失败");
      }
    },

```

## 4.修改头像

### 后端部分
在更换了接口后发现上传头像后,头像文件仍然存在本地,查看请求接口后发现上传头像并没有走上传图片的接口,而是一个单独的接口
接口位置
`com/ruoyi/web/controller/system/SysProfileController.java`

```java
    /**
     * 头像上传
     */
    @Log(title = "用户头像", businessType = BusinessType.UPDATE)
    @PostMapping("/avatar")
    public AjaxResult avatar(@RequestParam("avatarfile") MultipartFile file) throws Exception
    {
        if (!file.isEmpty())
        {
            LoginUser loginUser = getLoginUser();
            // String avatar = FileUploadUtils.upload(RuoYiConfig.getAvatarPath(), file, MimeTypeUtils.IMAGE_EXTENSION);
            //使用OSS
            String avatar = FileUploadUtils.uploadMinio(file);
            if (userService.updateUserAvatar(loginUser.getUsername(), avatar))
            {
                AjaxResult ajax = AjaxResult.success();
                ajax.put("imgUrl", avatar);
                // 更新缓存用户头像
                loginUser.getUser().setAvatar(avatar);
                tokenService.setLoginUser(loginUser);
                return ajax;
            }
        }
        return error("上传图片异常，请联系管理员");
    }
```

### 前端部分

后端在修改完成后提示上传成功,数据库里也变成了minio的url,但是前端页面却不显示头像了,打开调试工具后发现还是VUE_APP_BASE_API的原因

文件位置
`/ruoyi-ui/src/views/system/user/profile/userAvatar.vue`

```js
uploadImg() {
      this.$refs.cropper.getCropBlob(data => {
        let formData = new FormData();
        formData.append("avatarfile", data);
        uploadAvatar(formData).then(response => {
          this.open = false;
          // this.options.img = process.env.VUE_APP_BASE_API + response.imgUrl;
          // 使用OSS
          this.options.img =  response.imgUrl;
          store.commit('SET_AVATAR', this.options.img);
          this.$modal.msgSuccess("修改成功");
          this.visible = false;
        });
      });
    },
```

修改完代码后发现图片上传确实成功了，也显示了上传的新头像,但是页面刷新后却不显示了

`src/store/modules/user.js`

```js
// 获取用户信息
    GetInfo({ commit, state }) {
      return new Promise((resolve, reject) => {
        getInfo().then(res => {
          const user = res.user
          //const avatar = (user.avatar == "" || user.avatar == null) ? require("@/assets/images/profile.jpg") : process.env.VUE_APP_BASE_API + user.avatar;
          const avatar = (user.avatar == "" || user.avatar == null) ? require("@/assets/images/profile.jpg") : user.avatar;
          if (res.roles && res.roles.length > 0) { // 验证返回的roles是否是一个非空数组
            commit('SET_ROLES', res.roles)
            commit('SET_PERMISSIONS', res.permissions)
          } else {
            commit('SET_ROLES', ['ROLE_DEFAULT'])
          }
          commit('SET_ID', user.userId)
          commit('SET_NAME', user.userName)
          commit('SET_AVATAR', avatar)
          resolve(res)
        }).catch(error => {
          reject(error)
        })
      })
    },
```

通过上面的代码我们发现在获取用户信息的头像时,还是拼接了VUE_APP_BASE_API,去掉之后就正常了！


## 再次优化

我们按照上面的修改方式，数据库里会存储minio文件服务器的地址，这样如果文件服务器的IP发生了变化，就要修改数据库。过程就会很繁琐，所以可以优化一下，让数据库里只存文件名

### 后端部分
文件位置：`com/ruoyi/common/utils/file/FileUploadUtils.java`

```java
    private static final String uploadMinino(String bucketName, MultipartFile file, String[] allowedExtension)
            throws FileSizeLimitExceededException, IOException, FileNameLengthLimitExceededException,
            InvalidExtensionException
    {
        int fileNamelength = file.getOriginalFilename().length();
        if (fileNamelength > FileUploadUtils.DEFAULT_FILE_NAME_LENGTH)
        {
            throw new FileNameLengthLimitExceededException(FileUploadUtils.DEFAULT_FILE_NAME_LENGTH);
        }
        assertAllowed(file, allowedExtension);
        try
        {
            String fileName = extractFilename(file);
            String pathFileName = MinioUtil.uploadFile(bucketName, fileName, file);
//          return pathFileName; //注释这里
            return fileName; //直接返回文件名,这样数据库里就只存文件名
        }
        catch (Exception e)
        {
            throw new IOException(e.getMessage(), e);
        }
    }

```

### 前端部分

文件位置：`.env`

```
VUE_APP_MINIO_URL = 'http://127.0.0.1:9000/ruoyi/'  //添加文件服务器地址及桶名称
```

其他要改的地方  
之前url将baseUrl从`process.env.VUE_APP_BASE_API`修改为`""`  
现在需要将`process.env.VUE_APP_BASE_API`修改为`process.env.VUE_APP_MINIO_URL`  







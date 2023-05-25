---
title: 让Gin-Vue-Admin的表单支持图片
date: 2023-01-10 15:31:07
categories:
- go
tags:
- go

---

在学习[gin-vue-admin](https://www.gin-vue-admin.com/)时发现生成代码时并不支持选择表单输入类型，都是默认的输入框或者下拉框，这样在传图片或附件是就需要手动修改前端来实现此功能。

<!--more-->

## 数据结构

如下图所示

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202301/202301132327144.png)

## 数据列表部分

代码前后对比

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202301/202301132330514.png)

需要导入`CustonPic`模块

```h
import CustomPic from '@/components/customPic/index.vue'
```

效果图

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202301/202301132332131.png)

## 表单部分

数据列表还是挺简单的，麻烦的是表单部分

页面效果

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202301/202301132332345.png)

代码前后对比

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202301/202301132334540.png)

需要定义和导入和修改的东西比较多

```h
// 要添加的地方：

import {useUserStore} from "@/pinia/modules/user";

const userStore = useUserStore()
const emit = defineEmits(['on-success'])
const path = ref(import.meta.env.VITE_BASE_API)
let fileList = []


const uploadSuccess = (res) => {
  const { data } = res
  if (data.file) {
    emit('on-success', data.file.url)
    formData.value.pic=data.file.url
  }
}

const uploadError = () => {
  ElMessage({
    type: 'error',
    message: '上传失败'
  })
}

const removeFile = () => {
    formData.value.pic=''
}

// 要修改的地方：

const updateStudentFunc = async(row) => {
    const res = await findStudent({ ID: row.ID })
    type.value = 'update'
    if (res.code === 0) {
        formData.value = res.data.restudent
        if(formData.value.pic!=''){
          fileList=[{"name":"pic.jpg","url":"/api/"+formData.value.pic}]
        }else {
          fileList=[]
        }
        dialogFormVisible.value = true
    }
}

const closeDialog = () => {
    dialogFormVisible.value = false
    fileList=[]
    formData.value = {
        name: '',
        gender: '',
        pic: '',
        }
}
```


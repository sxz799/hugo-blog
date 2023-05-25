---
title: 让Gin-Vue-Admin的字典值支持字符串
date: 2023-01-09 19:29:57
categories:
- go
tags:
- go

---

最近在学习[gin-vue-admin](https://www.gin-vue-admin.com/)开发平台，发现在配置字典时，字典值只能使用int，不能使用string，这样就会导致后期做报表开发时，查看数据库内容时容易摸不到头脑，所以准备改一下源码，使其字典值支持string！

<!--more-->

gva版本: 2.5.5 (2022/12/14)

## 后端部分

1. 修改 `sys_dictionary_detail.go` 中结构体的定义
```go
// model/system/sys_dictionary_detail.go line:12
// 修改Value的数据类型为string
type SysDictionaryDetail struct {
	global.GVA_MODEL
	Label           string `json:"label" form:"label" gorm:"column:label;comment:展示值"`                                  // 展示值
	Value           string `json:"value" form:"value" gorm:"column:value;comment:字典值"`                                  // 字典值
	Status          *bool  `json:"status" form:"status" gorm:"column:status;comment:启用状态"`                              // 启用状态
	Sort            int    `json:"sort" form:"sort" gorm:"column:sort;comment:排序标记"`                                    // 排序标记
	SysDictionaryID int    `json:"sysDictionaryID" form:"sysDictionaryID" gorm:"column:sys_dictionary_id;comment:关联标记"` // 关联标记
}
```

2. 修改`dictionary_detail.go`中默认字典的配置
文件位置: `source/system/dictionary_detail.go`  
这里就不贴代码了，根据IDE的错误提示把原来的int类型的Value数据改为string即可

3. 修改字典server中Value的类型
```go
//service/system/sys_dictionary_detail.go line:71
//修改前：	
	if info.Value != 0 {
		db = db.Where("value = ?", info.Value)
	}
//修改后：	
	if info.Value != "" {
		db = db.Where("value = ?", info.Value)
	}

```

4. 修改前端文件模板

这里不贴代码了，看上去很乱，贴两张图，比较清晰明了

文件位置: `resource/autocode_template/web/form.vue.tpl`

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202301/202301132326963.png)

文件位置: `resource/autocode_template/web/table.vue.tpl`

![](https://gh.sxz799.online/https://raw.githubusercontent.com/sxz799/tuchuang-blog/main/img/202301/202301132326364.png)

## 前端部分
1. 修改字典配置页，字典值改为string
```html
// src/view/superAdmin/dictionary/sysDictionaryDetail.vue line:89
//修改前：

<el-form-item label="字典值" prop="value">
          <el-input-number
            v-model.number="formData.value"
            step-strictly
            :step="1"
            placeholder="请输入字典值"
            clearable
            :style="{width: '100%'}"
          />
        </el-form-item>

//修改后：

<el-form-item label="字典值" prop="value">
          <el-input
            v-model="formData.value"
            placeholder="请输入字典值"
            clearable
            :style="{width: '100%'}"
          />
        </el-form-item>

```

2. 修改代码生成器页面代码实现string类型可配置字典

```html
// src/view/systemTools/autoCode/component/fieldDialog.vue line:68

//修改前：

<el-form-item label="关联字典" prop="dictType">
        <el-select
          v-model="middleDate.dictType"
          style="width:100%"
          :disabled="middleDate.fieldType!=='int'"
          placeholder="请选择字典"
          clearable
        >
          <el-option
            v-for="item in dictOptions"
            :key="item.type"
            :label="`${item.type}(${item.name})`"
            :value="item.type"
          />
        </el-select>
      </el-form-item>

//修改后：

<el-form-item label="关联字典" prop="dictType">
        <el-select
          v-model="middleDate.dictType"
          :disabled="middleDate.fieldType!=='string'"
          placeholder="请选择字典"
          clearable
        >
          <el-option
            v-for="item in dictOptions"
            :key="item.type"
            :label="`${item.type}(${item.name})`"
            :value="item.type"
          />
        </el-select>
      </el-form-item>

```

## 修改完成！

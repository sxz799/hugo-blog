---
title: "记录一下ruoyi框架前端子表时删除按钮不生效的bug"
date: 2023-10-12T22:00:07+08:00
lastmod: 2023-10-12T22:00:07+08:00
draft: false
tags:
- vue
- ruoyi
categories:
- 技巧
---

遇到一个跟奇怪的bug,ruoyi框架前端使用el-table做子表时删除按钮不生效,但是删除后再保存,删除掉的记录并不会存入数据库,所以分析应该是页面渲染的问题。而且只有在新建表单时才会这样。

<!--more-->
全部代码
```html
<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="姓名" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入姓名"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="年龄" prop="age">
        <el-input
          v-model="queryParams.age"
          placeholder="请输入年龄"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="性别" prop="sex">
        <el-select v-model="queryParams.sex" placeholder="请选择性别" clearable>
          <el-option
            v-for="dict in dict.type.sys_user_sex"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['admin:student:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['admin:student:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['admin:student:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['admin:student:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="studentList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="主键" align="center" prop="id" />
      <el-table-column label="姓名" align="center" prop="name" />
      <el-table-column label="年龄" align="center" prop="age" />
      <el-table-column label="性别" align="center" prop="sex">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.sys_user_sex" :value="scope.row.sex"/>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['admin:student:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['admin:student:remove']"
          >删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 添加或修改学生对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="form.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="年龄" prop="age">
          <el-input v-model="form.age" placeholder="请输入年龄" />
        </el-form-item>
        <el-form-item label="性别" prop="sex">
          <el-select v-model="form.sex" placeholder="请选择性别">
            <el-option
              v-for="dict in dict.type.sys_user_sex"
              :key="dict.value"
              :label="dict.label"
              :value="dict.value"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-divider content-position="center">书信息</el-divider>
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" icon="el-icon-plus" size="mini" @click="handleAddBook">添加</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button type="danger" icon="el-icon-delete" size="mini" @click="handleDeleteBook">删除</el-button>
          </el-col>
        </el-row>
        <el-table :data="form.bookList" :row-class-name="rowBookIndex" @selection-change="handleBookSelectionChange" ref="book">
          <el-table-column type="selection" width="50" align="center" />
          <el-table-column label="序号" align="center" prop="index" width="50"/>
          <el-table-column label="书名" prop="name" width="150">
            <template slot-scope="scope">
              <el-input v-model="scope.row.name" placeholder="请输入书名" />
            </template>
          </el-table-column>
          <el-table-column label="页码" prop="pageSize" width="150">
            <template slot-scope="scope">
              <el-input v-model="scope.row.pageSize" placeholder="请输入页码" />
            </template>
          </el-table-column>
        </el-table>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listStudent, getStudent, delStudent, addStudent, updateStudent } from "@/api/admin/student";

export default {
  name: "Student",
  dicts: ['sys_user_sex'],
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 子表选中数据
      checkedBook: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 学生表格数据
      studentList: [],
      // 书表格数据

      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        name: null,
        age: null,
        sex: null
      },
      // 表单参数
      form: {
        bookList: [],
      },
      // 表单校验
      rules: {
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询学生列表 */
    getList() {
      this.loading = true;
      listStudent(this.queryParams).then(response => {
        this.studentList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      console.log(this.form.bookList)
      this.form = {
        id: null,
        name: null,
        age: null,
        sex: null,
      };
      this.form.bookList=[];
      console.log(this.form.bookList)
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加学生";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids
      getStudent(id).then(response => {
        this.form = response.data;
        // this.bookList = response.data.bookList;
        this.open = true;
        this.title = "修改学生";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          // this.form.bookList = this.bookList;
          if (this.form.id != null) {
            updateStudent(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addStudent(this.form).then(response => {
              this.$modal.msgSuccess("新增成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids;
      this.$modal.confirm('是否确认删除学生编号为"' + ids + '"的数据项？').then(function() {
        return delStudent(ids);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
	/** 书序号 */
    rowBookIndex({ row, rowIndex }) {
      row.index = rowIndex + 1;
    },
    /** 书添加按钮操作 */
    handleAddBook() {
      let obj = {};
      obj.name = "123";
      obj.pageSize = "345";
      this.form.bookList.push(obj);
    },
    /** 书删除按钮操作 */
    handleDeleteBook() {
      if (this.checkedBook.length === 0) {
        this.$modal.msgError("请先选择要删除的书数据");
      } else {
        const bookList = this.form.bookList;
        const checkedBook = this.checkedBook;
        this.form.bookList = bookList.filter(function(item) {
          return checkedBook.indexOf(item.index) === -1
        });
      }
    },
    /** 复选框选中数据 */
    handleBookSelectionChange(selection) {
      this.checkedBook = selection.map(item => item.index)
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('admin/student/export', {
        ...this.queryParams
      }, `student_${new Date().getTime()}.xlsx`)
    }
  }
};
</script>

```


User: 我会给你两份代码 帮我解释这两个代码的不同之处 如果你明白了 就回复请发送第一份代码

GPT: 当然，我可以帮你解释两份代码的不同之处。请发送第一份代码，然后我会分析并解释其不同之处。

User:
```js
reset() {
      console.log(this.form.bookList)
      this.form = {
        id: null,
        name: null,
        age: null,
        sex: null,
        bookList : []
      };
      console.log(this.form.bookList)
      this.resetForm("form");
    },
```
GPT: 这段代码看起来是一个重置表单的函数。它做了以下几件事情：

使用 console.log 打印出 this.form.bookList 的值。
将 this.form 对象的属性重置为默认值，包括 id、name、age、sex，以及将 bookList 设置为空数组。
再次使用 console.log 打印出 this.form.bookList 的值。
调用 this.resetForm("form") 函数，可能是为了进一步重置表单的某些方面。
这段代码的主要目的是将表单的内容重置为初始状态，包括清空 bookList 数组。不过，需要注意的是，这段代码中的 this.resetForm("form") 函数调用可能会对整个重置过程产生影响，具体效果取决于 resetForm 函数的实现细节。如果你想了解两份代码的不同之处，请继续提供第二份代码。

User:
```js
reset() {
      console.log(this.form.bookList)
      this.form = {
        id: null,
        name: null,
        age: null,
        sex: null,
      };
      this.form.bookList=[];
      console.log(this.form.bookList)
      this.resetForm("form");
    },
```
GPT: 这是第二份代码，与第一份代码相比，有以下不同之处：

第一份代码在重置 this.form 对象的同时，将 bookList 设置为空数组。而第二份代码分两步进行，首先重置了 this.form 对象的属性（id、name、age、sex），然后单独将 this.form.bookList 设置为空数组。

第一份代码使用了两次 console.log 分别在重置前后输出 this.form.bookList 的值，而第二份代码只在重置前后各输出了一次 this.form.bookList 的值。

总的来说，这两份代码都达到了相同的目标，即重置表单对象 this.form，但是它们的实现方式略有不同。第一份代码在一个语句中同时重置了整个 this.form 对象和 bookList 数组，而第二份代码分两步进行，先重置对象的属性，然后再清空数组。这两种方式在功能上应该是等效的，但第二份代码更明确地分开了这两个步骤。

User: 代码定义是这样的
```js
form: {
        bookList: [],
      },
```
GPT: 理解了，你的代码中定义了一个 form 对象，其中包含一个名为 bookList 的空数组。然后，你之前提供的两份代码都是用于重置这个 form 对象的一部分。在这种情况下，第一份和第二份代码都是等效的，因为它们都将 bookList 数组重置为空数组，只是实现方式略有不同。你可以选择使用其中任何一份代码来完成这个任务，取决于你的代码风格和偏好。

User: 为什么第二种代码会导致数组缺失 `ob: Observer` 属性

GPT:

`__ob__` 属性通常与使用 Vue.js 这样的响应式框架时相关。Vue.js使用 `__ob__` 来追踪和管理响应式数据对象。它是Vue的内部属性，通常不应该直接访问或修改。

在第二份代码中，当你单独对 this.form.bookList 赋值一个新空数组时，这可能会破坏Vue的响应式系统对原始数组的追踪。Vue使用 `__ob__` 来实现响应式数据变化的侦听和更新。

如果你需要重置 bookList 数组，而不想破坏Vue的响应性，你可以使用 splice 方法或 Vue.set 方法来修改数组，以确保Vue能够正确追踪这些更改，而不会导致 `__ob__` 丢失。

例如：

// 使用 splice 方法  
`this.form.bookList.splice(0, this.form.bookList.length);`

// 或者使用 Vue.set 方法  
`this.$set(this.form, 'bookList', []);`  
这样做将确保 bookList 数组的变化会被Vue正常追踪，而不会导致 `__ob__`丢失。

User: 为什么第一种方式不会导致 `__ob__` 丢失

GPT: 第一种方式不会导致 `__ob__` 丢失，因为它在重置 this.form 对象时，同时也将 bookList 属性重新赋值为空数组。这个操作保持了 bookList 属性在 this.form 对象内的引用不变，因此 Vue.js 的响应式系统能够继续追踪 bookList 属性的变化。

在第一种方式中，重置代码如下：
```
this.form = {
  id: null,
  name: null,
  age: null,
  sex: null,
  bookList: [] // 在这里重新赋值为空数组，但保持了属性引用
};
```
由于 bookList 属性的引用没有改变，Vue.js 的响应式系统能够正常追踪该属性的变化，不会导致 `__ob__`丢失。

相比之下，第二种方式中的单独对 this.form.bookList 赋值一个新的空数组，这可能会破坏了Vue的响应性，因为这实际上是改变了 bookList 属性的引用，导致 Vue.js 无法正确追踪属性的变化，从而可能导致 `__ob__` 丢失。

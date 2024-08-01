---
title: Python自动化-Selenium基操

date: 2022-10-18 17:13:11
tags:
- python
- 自动化
categories:
- python


---

最近有一个新的需求要在集团的一个内部系统中根据条件获取获取Excel数据并导入另外一个系统，要用到一些自动化相关内容，所以记录一下。
<!--more-->

## 什么是Selenium

`Selenium`是一个用于Web应用程序测试的工具。Selenium测试直接运行在浏览器中，就像真正的用户在操作一样。支持的浏览器包括IE（7, 8, 9, 10, 11），Mozilla Firefox，Safari，Google Chrome，Opera，Edge等。这个工具的主要功能包括：`测试与浏览器的兼容性`——测试应用程序是否能够很好得工作在不同浏览器和操作系统之上。`测试系统功能`——创建回归测试检验软件功能和用户需求。支持自动录制动作和自动生成.Net、Java、Perl等不同语言的测试脚本。

## 下载安装Selenium

需要安装好python环境,不在叙述。
下载安装命令
```
pip3 install selenium
```

## 下载浏览器驱动

淘宝镜像地址：`https://registry.npmmirror.com/binary.html?path=chromedriver/`
Google官方地址：`https://chromedriver.storage.googleapis.com/index.html`
根据操作系统类型下载即可

## 使用Selenium

Selenium支持的浏览器很多，这里以Chrome为例。
```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service

s = Service('driver/chromedriver') # 这里的chromedriver就是刚才下载的驱动

browser = webdriver.Chrome(service=s)

url = 'https://www.baidu.com'
browser.get(url)

time.sleep(1)

searchText = browser.find_element(By.XPATH, '//*[@id="kw"]')
searchText.send_keys("blog.sxz799.cyou")

time.sleep(2)

searchButton = browser.find_element(By.XPATH, '//*[@id="su"]')
searchButton.click()

time.sleep(10) 
browser.quit() #10秒后退出浏览器

```

运行后的效果为打开浏览器并搜索`blog.sxz799.cyou`

大致流程就是获取html中的元素并进行操作。

## 获取元素Xpath方法
先打开百度首页
找到输入框，`鼠标右键 -> 检查`


在弹出的右侧开发者工具窗口中找到输入框对应的元素

`鼠标右键-> Copy -> Copy XPath`



此时剪切板中就保存了输入框的XPath(`//*[@id="kw"]`)，搜索按钮同理。


## 代码优化及封装获取元素函数

### 优化
可以初始化chrome driver驱动时设置一下隐式等待的时间，此代码仅需调用一次即可。

```python
browser = webdriver.Chrome(service=s)
browser.implicitly_wait(10)  # 隐式等待 整个页面渲染 不影响性能
```


> 第一行代码: Creates a new instance of the chrome driver. 

> 第一行代码: Starts the service and then creates new instance of chrome driver.

> 第二行代码: Sets a sticky timeout to implicitly wait for an element to be found,    or a command to complete. This method only needs to be called one    time per session. To set the timeout for calls to    execute_async_script, see set_script_timeout.

### 封装

```python
def get_element(by: str, value: str):  # 定位方式，定位字符串
    from time import time
    success = True
    start = time()
    try:
        browser.find_element(by, value)
    except Exception as e:
        success = False
        print(e)
        print(f'获取元素超时：耗时：{time() - start}')
    return [success, browser.find_element(by, value)]
```

### 调用

```python
result = get_element(By.XPATH, '//*[@id="kw"]')
if result[0]:
    result[1].click()
```

## 设置文件默认下载位置
```python
options = webdriver.ChromeOptions()
prefs = {'profile.default_content_settings.popups': 0, 'download.default_directory': '/Users/sxz799/Desktop/downLoadDir'}
options.add_experimental_option('prefs', prefs)
browser = webdriver.Chrome(service=s, options=options)
```
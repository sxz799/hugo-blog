---
title: "清理微软Edge浏览器在MacOS中的历史版本"
date: 2024-09-11T10:02:10+08:00
lastmod: 2024-09-11T10:02:10+08:00
draft: false
tags:
- default1
- default1
categories:
- default
---

清理两个地方

<!--more-->

# 1
```
open "/Applications/Microsoft Edge.app/Contents/Frameworks/Microsoft Edge Framework.framework/Versions"
```

# 2 
```
open "/Users/$(whoami)/Library/Application Support/Microsoft/EdgeUpdater/apps/msedge-stable"
open "/Users/$(whoami)/Library/Application Support/Microsoft/EdgeUpdater/apps/msedge-updater"
```

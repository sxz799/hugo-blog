---
title: "Redis基础"
date: 2023-02-19T10:50:23+08:00
draft: false
tags:
- redis
categories:
- redis
---

# Redis常用数据结构

字符串（String）、哈希(Hash)、列表（list）、集合（set）、有序集合（ZSET）。
<!--more-->
 
## 字符串（String）

字符串类型是Redis最基础的数据结构。键都是字符串类型。值最大不能超过512MB。

### 命令

#### SET

set key value  `set abc 123`

常用参数
`set key value [NX|XX] [GET] [EX seconds|PX milliseconds|EXAT unix-time-seconds|PXAT unix-time-milliseconds|KEEPTTL]`

> NX : 键不存在才可以设置成功   
> XX : 键存在才可以设置成功  
> EX|PX|EXAT|PXAT : 设置过期时间 秒 毫秒 秒时间戳 毫秒时间戳  
> KEEPTTL：保留设置前指定键的生存时间 (6.0版本添加的可选参数) 
> GET：返回指定键原本的值，若键不存在时返回nil

#### GET

get key `get abc`

#### GETSET

GETSET命令用于设置键值对的值并返回旧值，若键值对不存在则返回nil。若键存在但不为字符串类型，则返回错误。

getset key value `getset abc 123`

DEL命令被用于删除指定的一个或多个键值对，当其中某个键值对不存在时将被忽略。DEL命令可被用于所有数据类型，不仅限于字符串。

#### EXPIRE / PEXPIRE

EXPIRE key seconds [NX|XX|GT|LT]

```
NX：只有当key没有设置过期时间，才会执行命令（已经设置过的，不能再设置）
XX ：只有当key有过期时间，才会执行命令设置（没有设置过的，不能设置）
GT ：只有当新的过期时间大于当前过期时间时，才会设置（只会增加过期时间）
LT ：只有当新的过期时间小于当前过期时间时，才会设置（只会减少过期时间）
```

EXPIRE/PEXPIRE命令被用于设置某个键的过期时间，其值以秒作为单位。当设置过期时间后使用SET（不使用KEEPTTL参数）、GETSET等命令，所设置的过期时间将被覆盖。EXPIRE可被用于所有数据类型，不仅限于字符串。

#### TTL / PTTL
TTL命令用于获取指定键的剩余生存时间（time to live, TTL），其值以秒作为生存时间的单位。TTL命令可被用于所有数据类型，不仅限于字符串。

TTL key

PTTL命令同样用于获取指定键的剩余生存时间，与TTL区别为其以毫秒作为单位。

PTTL key


#### MSET

mset key value [key value ...]

MSET命令用于设置一个或多个键值对，该命令永远返回OK。MSET与SET命令相同，都会替代存在的键的值。

#### MGET
mget key [key ...]

MGET用于获取所有指定的键值。当某个键不存在时，将返回一个特殊的值nil。

#### MSETNX

MSETNX key value [key value ...]

MSETNX命令用于设置一个或多个键值对，仅当所有键都不存在时才会执行。同样，MSETNX也具备原子性，所有的键会被一起被设置。

当所有的键被设置，则返回1  
当所有的键都没有被设置，即至少一个键已存在的情况，则返回0

#### GETDEL

GETDEL key

GETDEL命令是Redis 6.2.0中新增的命令，它用于获取指定键值对的值，并在获取后将其删除（仅限于该键值对类型为字符串时）。


#### GETEX

GETEX key [EX seconds|PX milliseconds|EXAT timestamp|PXAT milliseconds-timestamp|PERSIST]

GETEX命令支持EX、PX、EXAT、PXAT以及PERSIST，分别为：
```
EX：设置以秒为单位的过期时间
PX：设置以毫秒为单位的过期时间
EXAT：设置以秒为单位的UNIX时间戳所对应的时间为过期时间
PXAT：设置以毫秒为单位的UNIX时间戳所对应的时间为过期时间
PERSIST：移除键值对关联的过期时间
```

#### INCR

incr命令用于对值做自增操作,返回结果分为三种情况：

值不是整数,返回错误。

值是整数，返回自增后的结果。

键不存在，按照值为0自增,返回结果为1。（会设置键）

除了incr命令，Redis提供了decr(自减)、 incrby(自增指定数字)、decrby(自减指定数字)、incrbyfloat（自增浮点数)

#### append 

追加

```
127.0.0.1:6379> set a aa
OK
127.0.0.1:6379> append a bb
(integer) 4
127.0.0.1:6379> get a
"aabb"
```

#### strlen

```
127.0.0.1:6379> strlen a
(integer) 4
```

#### setrange 
设置指定位置的字符
```
127.0.0.1:6379> get a
"aabb"
127.0.0.1:6379> setrange a 2 c
(integer) 4
127.0.0.1:6379> set a
(error) ERR wrong number of arguments for 'set' command
127.0.0.1:6379> get a
"aacb"
```

#### getrange 

截取字符串

```
127.0.0.1:6379> get a
"aacb"
127.0.0.1:6379> getrange a 2 3
"cb"
```
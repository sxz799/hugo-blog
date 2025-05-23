---
title: "Redis基础"
date: 2023-02-19T10:50:23+08:00
draft: false
tags:
- redis
categories:
- redis
---



### Redis是什么？

Redis是一个使用 C 语言编写的，高性能**非关系型的键值对数据库**。与传统数据库不同的是，Redis 的数据是存在**内存**中的，所以读写速度非常快，被广泛应用于**缓存**方向。Redis可以将数据写入磁盘中，保证了数据的安全不丢失，而且Redis的操作是**原子性**的。

<!--more-->

### Redis常用数据结构

#### 基本数据类型
1. 字符串（String）
2. 哈希(Hash)
3. 列表（list）
4. 集合（set）
5. 有序集合（ZSET）。

#### 特殊的数据类型：

1. Bitmap：位图，可以认为是一个以位为单位数组，数组中的每个单元只能存0或者1，数组的下标在 Bitmap 中叫做偏移量。Bitmap的长度与集合中元素个数无关，而是与基数的上限有关。

2. Hyperloglog。HyperLogLog 是用来做基数统计的算法，其优点是，在输入元素的数量或者体积非常非常大时，计算基数所需的空间总是固定的、并且是很小的。典型的使用场景是统计独立访客。

3. Geospatial ：主要用于存储地理位置信息，并对存储的信息进行操作，适用场景如定位、附近的人等。


### Redis常用命令

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


### Redis为什么快?

1. **数据存在内存中**：Redis的数据存在内存中，读写速度非常快，而且Redis的操作是原子性的。
2. **数据结构简单**：Redis支持的数据结构简单，对数据操作也简单，操作的时间复杂度低。
3. **单线程**：Redis是单线程的，避免了线程切换的开销。
4. **非阻塞IO**：Redis使用epoll作为IO多路复用技术，非阻塞IO。
5. **持久化**：Redis支持数据持久化，可以将数据写入磁盘中，保证了数据的安全不丢失。

### Redis的为什么不能做主数据库?

1. **数据存储在内存中**：Redis的数据存储在内存中，内存的容量有限，无法存储大量数据。
2. **单线程**：Redis是单线程的，无法充分利用多核CPU的优势。
3. **持久化**：Redis的持久化机制不够完善，无法保证数据的安全不丢失。
4. **数据结构简单**：Redis支持的数据结构简单，无法支持复杂的查询操作。
5. **非关系型数据库**：Redis是非关系型数据库，不支持SQL查询。

### Redis的线程模型？

Redis基于Reactor模式开发了网络事件处理器，这个处理器被称为文件事件处理器。它的组成结构为4部分：`多个套接字`、`IO多路复用程序`、`文件事件分派器`、`事件处理器`。
因为文件事件分派器队列的消费是单线程的，所以Redis才叫单线程模型。

* 文件事件处理器使用I/O多路复用（multiplexing）程序来同时监听多个套接字， 并根据套接字目前执行的任务来为套接字关联不同的事件处理器。
* 当被监听的套接字准备好执行连接accept、read、write、close等操作时， 与操作相对应的文件事件就会产生， 这时文件事件处理器就会调用套接字之前关联好的事件处理器来处理这些事件。

虽然文件事件处理器以单线程方式运行， 但通过使用 I/O 多路复用程序来监听多个套接字， 文件事件处理器既实现了高性能的网络通信模型， 又可以很好地与 redis 服务器中其他同样以单线程方式运行的模块进行对接， 这保持了 Redis 内部单线程设计的简单性

### Redis应用场景有哪些？

1. 缓存热点数据，缓解数据库的压力。
2. 利用 Redis 原子性的自增操作，可以实现计数器的功能，比如统计用户点赞数、用户访问数等。
3. 分布式锁。在分布式场景下，无法使用单机环境下的锁来对多个节点上的进程进行同步。可以使用 Redis 自带的 SETNX 命令实现分布式锁，除此之外，还可以使用官方提供的 RedLock 分布式锁实现。
4. 简单的消息队列，可以使用Redis自身的发布/订阅模式或者List来实现简单的消息队列，实现异步操作。
5. 限速器，可用于限制某个用户访问某个接口的频率，比如秒杀场景用于防止用户快速点击带来不必要的压力。
6. 好友关系，利用集合的一些命令，比如交集、并集、差集等，实现共同好友、共同爱好之类的功能。

### Memcached和Redis的区别？

1. MemCached 数据结构单一，仅用来缓存数据，而 Redis 支持多种数据类型。
2. MemCached 不支持数据持久化，重启后数据会消失。Redis 支持数据持久化。
3. Redis 提供主从同步机制和 cluster 集群部署能力，能够提供高可用服务。Memcached 没有提供原生的集群模式，需要依靠客户端实现往集群中分片写入数据。
4. Redis 的速度比 Memcached 快很多。
5. Redis 使用单线程的多路 IO 复用模型，Memcached使用多线程的非阻塞 IO 模型。（Redis6.0引入了多线程IO，用来处理网络数据的读写和协议解析，但是命令的执行仍然是单线程）
6. value 值大小不同：Redis 最大可以达到 512M；memcache 只有 1mb。

### 为什么要用 Redis 而不用 map/guava 做缓存?

使用自带的 map 或者 guava 实现的是本地缓存，最主要的特点是轻量以及快速，生命周期随着 jvm 的销毁而结束，并且在多实例的情况下，每个实例都需要各自保存一份缓存，缓存不具有一致性。

使用 redis 或 memcached 之类的称为分布式缓存，在多实例的情况下，各实例共用一份缓存数据，缓存具有一致性。

### Redis的内存用完了会怎样？

如果达到设置的上限，Redis的写命令会返回错误信息（但是读命令还可以正常返回）。

也可以配置内存淘汰机制，当Redis达到内存上限时会冲刷掉旧的内容。

### Redis如何做内存优化？

可以好好利用Hash,list,sorted set,set等集合类型数据，因为通常情况下很多小的Key-Value可以用更紧凑的方式存放到一起。尽可能使用散列表（hashes），散列表（是说散列表里面存储的数少）使用的内存非常小，所以你应该尽可能的将你的数据模型抽象到一个散列表里面。比如你的web系统中有一个用户对象，不要为这个用户的名称，姓氏，邮箱，密码设置单独的key，而是应该把这个用户的所有信息存储到一张散列表里面。

### keys命令存在的问题？

redis的单线程的。keys指令会导致线程阻塞一段时间，直到执行完毕，服务才能恢复。scan采用渐进式遍历的方式来解决keys命令可能带来的阻塞问题，每次scan命令的时间复杂度是，但是要真正实现keys的功能，需要执行多次scan。

scan的缺点：在scan的过程中如果有键的变化（增加、删除、修改），遍历过程可能会有以下问题：新增的键可能没有遍历到，遍历出了重复的键等情况，也就是说scan并不能保证完整的遍历出来所有的键。


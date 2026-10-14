---
date: '2026-10-14T05:27:42Z'
draft: false
title: '在docker中使用wireguard组件虚拟局域网'
---

### 服务端部署
```
docker run -d \
  --name=wireguard \
  --network=host \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=Asia/Shanghai \
  -e SERVERURL=你的域名 \
  -e SERVERPORT=51820 \
  -e PEERS=客户端标记1,客户端标记2 \
  -e INTERNAL_SUBNET=10.66.66.0 \
  -e ALLOWEDIPS=10.66.66.0/24 \
  -e PERSISTENTKEEPALIVE_PEERS=all \
  -e LOG_CONFS=false \
  -v /vol1/1000/docker映射/wireguard/config:/config \
  -v /lib/modules:/lib/modules \
  --restart unless-stopped \
  linuxserver/wireguard:latest
  ```

  其中SERVERURL填写域名
  /vol1/1000/docker映射/wireguard/config 为映射路径
  部署完成后 /vol1/1000/docker映射/wireguard/config目录下会生成一个`peer_客户端标记1`目录
  复制目录内的`peer_客户端标记1.conf`文件备用


  ### 客户端命令

```
  docker run -d \
  --name wireguard-client \
  --network host \
  --cap-add NET_ADMIN \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=Asia/Shanghai \
  -v "/vol1/1000/docker/wireguard-client:/config" \
  --restart unless-stopped \
  linuxserver/wireguard:latest
```

将上一步`peer_客户端标记1`目录内生成的`peer_客户端标记1.conf`改名为`wg0.conf`并放到`/vol1/1000/docker/wireguard-client`

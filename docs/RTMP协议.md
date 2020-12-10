#### LSB 和 MSB 内存布局

数据:
 short s = 0x0205;

LSB 在内存布局
->05 02


MSB 在内存布局
->00 05



#### RTMB握手
1. 客户端提供c0+c1包， c0:版本号; c1: 时间戳 (4B) +  0 (4B) + 随机值(1528 B)
c0: 0x3 => clientsig[-1]
c1: uptime(4B) + 0(4B) + 1528 =>clientsig
c0+c1 => 1536 + 1

2. 接收服务端的数据包 s0+s1
s0 = 1B (如果s0 与 c0 版本号不一致)
s1 = 1536 => serversig （就是客户端发送的 1536B ）
//FMS Version ? serversig[4]/[5]/[6]/[7]

1. 收到s0+s1后，把收到的s1当成c2发送出去
c2：s1

4. 最后比较
if (memcmp(serversig, clientsig, RTMP_SIG_SIZE) == 0) {
	//匹配成功
}


#### RTMB 消息格式 
B: 字节； b: 比特
msg = msg_head | msg_body
msg_head = message type (1B) | payload length (3B) | timestamp (4B) | stream id (3B)
msg_body = chunk_msg...
chunk_msg = chunk header | chunk data
chunk header = chunk basic header(1~3B) | chunk message header | extended timestamp
chunk basic header = fmt(2b) + cs id(6b/ 6b+8b / 6b+8b+8b) # cs id(0/1/2被保留)

>chunk message header 块消息头有四种不同的格式，由块基本头中的 "fmt" 字段进行选择。
类型0: 11B;   
类型1: 7B;
类型2: 3B; 
类型3: 0B(没有消息头);

##### chunk message header 类型0:
* 用于块流开始
* 格式：
> chunk message header = timestamp(3B) | message length(3B) | message type id(1B) | msg stream id(4B) 

##### chunk message header 类型1:
* 用于中间块流
* 格式：
> chunk message header = timestamp delta(3B) | message length(3B) | message type id(1B)

##### chunk message header 类型2:
* 用于中间块流
* 这一块具有和前一块相同的流 ID 和消息长度 
* 格式：
> chunk message header = timestamp delta(3B) 

##### chunk message header 类型3:
* 用于中间块流
* 网络比较稳定， 发送的数据块的间隔时间（timestamp delta）一样，就不在需要发送 timestamp delta
* 格式：
> chunk message header = 无(0B)

message type id: 类型0 与 类型1的块， 类型在这里发送， 8-音频， 9-视频；
msg stream id: LSB格式， 对于同一块 chunk 下的这个值是一样的。但是 chunk stream id (cs id) 是不一样的；



#### RTMB流媒体连接
1. RTMP_Connect
   1. RTMP_Connect0 # socket 连接
   2. RTMP_Connect0 # RTMP 连接

2. RTMP_ConnectStream
   1. RTMP_ReadPacket # 读取socket消息，不处理
   2. RTMP_ClientPacket # 处理及消息响应， 按  **RTMB 消息格式** 格式处理
   






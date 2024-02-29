# GT
 A project of GT.
 
 ![image](https://github.com/Vikkdsun/GT/assets/114153159/428dac69-37c0-48cd-8ea5-ab8e61f222bd)

# GT收发器
---
## 简介
GT收发器是集成在FPGA芯片内部的固定电路，其是***电流驱动型差分标准（CML）***，因此我们只需要关心该固定电路与FPGA的逻辑部分接口时序即可。GT收发器是高速串行通信，并行通信在时钟很快的情况下，PCB布线很难。
## 8B/10B编码
FPGA实现千兆以太网主要是通过FPGA设计协议栈，通过PHY芯片将数据传输出去，PHY芯片就是对MAC数据做4B/5B编码，然后在接受方通过***CDR***恢复时钟采集数据。

GT收发器可以选择8B/10B编码，这里暂时不对8B/10B编码原理进行描述，其意味着***把8bit数据编码为10bit***，主要目的在于由于接收方使用CDR恢复时钟，如果接收到的数据全是1或者全是0，也就是没有***直流平衡***，对于时钟恢复挑战很大，8B/10B编码就是可以解决这个问题。

其主要包括K码和D码，其中D码表示数据。其编码效果为：

8bit = 3bit + 5 bit

3bit --> 4bit

5bit --> 6bit

例：K28.5 意味着：

***后面低5bit的数是28 前面高3bit是5*** 

也就是K28.5 = 101 11100 = 0xBC

例D16.2 = 010 10000 = 0x50

## GT收发器结构
![image](https://github.com/Vikkdsun/GT/assets/114153159/ea9a24dc-d268-4926-893b-067f6d5e9e80)

### TX
PCS是在FPGA内实现的，对传过来的数据做编码（比如以太网的PHY：4B/5B编码）、以及处理跨时钟域等***数字信号处理***，然后交给***PMA***。PCS内有两个时钟域，对跨时钟的处理主要采用：1.弹性BUFFER 2.相位纠正电路
PMA将编码好的数字信号做串化（PISO），发送出去，PMA做***模拟信号处理（PRE/POST Emp）***，其最后端有个高速DAC（TX Driver）。

### RX
PMA前端有个均衡器，收到的信号在走导线等电路部分时会有电平衰减，接收端无法识别电平，***均衡器对损耗高的信号做调整，损耗不多的不调整***，恢复出来的信号方便识别，减少失真。之后经过高速ADC，然后解串给到PCS。
PCS在进行***极性控制***（Polarity）之后进行***逗号检测***（CommaDetect）和***对齐***（Align），然后8B/10B解码，之后经过***弹性Buffer***跨时钟，8B/10B编码不需要进入GearBox，***GearBox是对64B/66B编码使用***。最后给回用户。

### 弹性Buffer
8B/10B编码 10bit有1024个字符，8bit有256个，从10bit的组成列表里取256个作为数据字符（D码），再取几个作为K码。利用率不会达到百分之百，因为数据中混合K码。弹性Buffer中会有数据和K码。
比如：写的快 读的慢 那么buffer内会满（***上溢***） 而且又有数据又有K码，当快满时，Buffer会删一些K码，比如连续的几个K码 会删除掉一些 剩下的K码 仍然可以用来对齐和同步。
比如SGMII 前导码发6个55 但是接收端收到5个55 这就是因为弹性Buffer发生了上溢。

又或者，当写的慢，读的快，快要读空了（***下溢***），导致后面都读0，弹性Buffer这时候会填充很多K码。

所以我们在写GT时，在tx模块***空闲时要时不时发送同步码序列***。

### 时钟
![image](https://github.com/Vikkdsun/GT/assets/114153159/19342a96-3475-425d-adef-1d923b503e18)
XCLK：PMA前端时钟，

RXUSRCLK：用户时钟

RXUSRCLK2：写代码时 always就用这个时钟驱动

GT Bank有两对参考时钟（差分），但是我们只能用其一。这个时钟进来后，首先经过IBUFDS_GTE2（差分转单端、单端转差分），之后两条路，一个交给QPLL，另一个交给各自的通道，交给通道的CPLL。

图中可以看到，QPLL和CPLL是可以选择使用哪个的，那么选择哪个？

***CPLL在限速率低（<6Gps）首选，高限速率（10Gbps）用QPLL。***

在架构上，Quad（或Q）的概念包含一组四个GTXE2_CHANNEL/GTHE2_CHANNEL原语、一个GTXE2_COMMON/ GTHE2_COMMON原语、两个专用外部参考时钟引脚对和专用参考时钟路由。必须为每个收发器实例化GTXE2_CHANNEL/GTHE2_CHANNEL原语。如果需要高性能QPLL，则还必须实例化GTXE2_COMMON/GTHE2_COMMON原语。当仅使用CPLL时，即使不使用QPLL，也必须实例化GTXE2_COMMON/GTHE2_COMMON原语，这由7系列FPGA收发器向导自动处理。

![image](https://github.com/Vikkdsun/GT/assets/114153159/940b8717-c6d0-49fc-9f2c-b523bf441fee)

QPLL性能更好，但是一个GT BANK（四个通道）这四个通道要共用GT COMMON

![image](https://github.com/Vikkdsun/GT/assets/114153159/554a7724-9742-45a4-a577-219545169e08)

这里***GTREFCLK0 GTREFCLK1***就是***GT BANK上的两个时钟***，还可以选择GTNORTHREFCLK，这意味着，当前bank***可以选择他上面（NORTH）的Bank的时钟***，同理GTSOURTHBREFCK就是下面的时钟

CPLL也是同理 有多种时钟选择

![image](https://github.com/Vikkdsun/GT/assets/114153159/3cc87dbc-a756-4a52-bd39-5944cab20bcc)

***一个参考时钟最多驱动四个channel，多了可能抖动。***

![image](https://github.com/Vikkdsun/GT/assets/114153159/3e0727fd-f503-4dc5-821a-ee3843eb1148)

TXUSRCLK TXUSRCLK2是通过外部PLL生成 接到GT的 TXOUTCLK是GT Bank参考时钟生成的，输出后路由到别的bank上，FPGA可以使用该时钟，称之为全局时钟，使用该时钟经过PLL（或MMCM）产生TXUSRCLK和TXUSRCLK2，交给PCS做编码同时USRCLK2交给FPGA让FPGA对数据进行处理，数据和TXUSRCLK2同步

![image](https://github.com/Vikkdsun/GT/assets/114153159/af5d237b-96a3-4844-98b1-0ab056c852ce)

### PCS中的跨时钟域

做跨时钟处理：

1.TX Buffer （FIFO）

2.相位调整电路

一般第一种方法更常用，简单且成熟，但是处理延时大，在要求高的地方，用不了这个。
第二种方法的难度更大，但是潜伏期低

### RX端PMA的均衡器

LPM和DFE：当传输距离短、速度低用LPM，LPM低功耗；距离长，使用DFE。

### 眼图

![image](https://github.com/Vikkdsun/GT/assets/114153159/7b1f0a1d-ff9d-4d5d-9f70-9f9da408ead3)

眼宽：眼宽越小表示电平稳定时间短、变化缓慢、压摆率低、时钟容易采集到跳变沿，反映了采样精准度。

眼高：眼高小表示01电平相近，反应接收器能承受的最低电平标准，比如眼高1v，电平标准为0.8 大于0.8为1 那么表示正确接受了信号。

一般来讲 发送端眼图很好 但是到接收端，眼图就变差了，均衡器就是让眼图变好，眼睛变大的电路。	

### 时钟矫正和字节对齐

CDR产生的时钟会有累计误差，在发送数据时，发送特殊的一段序列，在接收时，检测到这段序列时对CDR进行调整。

比如在发送数据前先发送一个K28.5同步头再加一个数据码，来帮助CDR矫正。

字节对齐：这里对齐是指字节对齐！

由于串行通信，我们不知道一个字节从哪个bit开始算。

处理方法：

发送端定时发送一个K28.5作为逗号，接收端接收时窗口扫描 找K28.5 找到之后就找到了串并转换的开始



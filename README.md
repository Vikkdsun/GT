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

通过设置***时钟纠正***菜单的纠正序列的长度，***决定了补充的个数和删除的个数***

![image](https://github.com/Vikkdsun/GT/assets/114153159/11c5b71c-3d32-4b7b-8cdb-d74629e387e1)

***比如图中所示，序列为1 也就是要删除或者补充纠正码 就只删除或补充一个***

### 时钟
![image](https://github.com/Vikkdsun/GT/assets/114153159/19342a96-3475-425d-adef-1d923b503e18)
XCLK：PMA前端时钟，

RXUSRCLK：用户时钟

RXUSRCLK2：写代码时 always就用这个时钟驱动

2Byte/4Byte mode:

![image](https://github.com/Vikkdsun/GT/assets/114153159/88f0cb6a-b5b9-4a09-ab64-be86f97f9d11)

![image](https://github.com/Vikkdsun/GT/assets/114153159/410f2f22-bb97-4284-aaa4-2a19b0940cd9)

4Byte/8Byte mode:

![image](https://github.com/Vikkdsun/GT/assets/114153159/bdc636d2-181e-4e99-9b00-f6723bee69a3)

![image](https://github.com/Vikkdsun/GT/assets/114153159/5f2e6faf-030e-41a6-87a9-2f5c744d3074)


***尽管TXUSRCLK、TXUSRCLK2和发射机参考时钟可能以不同的频率运行，但它们的源必须是一个振荡器。因此，TXUSRCLK和TXUSRCLK 2必须是发射机参考时钟的倍频或分频版本。***

GT Bank有两对参考时钟（差分），但是我们只能用其一。这个时钟进来后，首先经过IBUFDS_GTE2（差分转单端、单端转差分），之后两条路，一个交给QPLL，另一个交给各自的通道，交给通道的CPLL。

图中可以看到，QPLL和CPLL是可以选择使用哪个的，那么选择哪个？

***CPLL在限速率低（<6.6Gps）首选，高限速率（10Gbps）用QPLL。***

在架构上，Quad（或Q）的概念包含一组四个GTXE2_CHANNEL/GTHE2_CHANNEL原语、一个GTXE2_COMMON/ GTHE2_COMMON原语、两个专用外部参考时钟引脚对和专用参考时钟路由。必须为每个收发器实例化GTXE2_CHANNEL/GTHE2_CHANNEL原语。如果需要高性能QPLL，则还必须实例化GTXE2_COMMON/GTHE2_COMMON原语。当仅使用CPLL时，即使不使用QPLL，也必须实例化GTXE2_COMMON/GTHE2_COMMON原语，这由7系列FPGA收发器向导自动处理。

![image](https://github.com/Vikkdsun/GT/assets/114153159/940b8717-c6d0-49fc-9f2c-b523bf441fee)

QPLL性能更好，但是一个GT BANK（四个通道）这四个通道要共用GT COMMON

![image](https://github.com/Vikkdsun/GT/assets/114153159/554a7724-9742-45a4-a577-219545169e08)

这里***GTREFCLK0 GTREFCLK1***就是***GT BANK上的两个时钟***，还可以选择GTNORTHREFCLK，这意味着，当前bank***可以选择他上面（NORTH）的Bank的时钟***，同理GTSOURTHBREFCK就是下面的时钟

CPLL也是同理 有多种时钟选择

![image](https://github.com/Vikkdsun/GT/assets/114153159/3cc87dbc-a756-4a52-bd39-5944cab20bcc)

![image](https://github.com/Vikkdsun/GT/assets/114153159/93610150-9904-4499-a28d-cccbb96ce607)


***一个参考时钟最多驱动四个channel，多了可能抖动。但是看手册好像说是最多12个***

![image](https://github.com/Vikkdsun/GT/assets/114153159/6698e47e-76c2-4130-beee-b62db6e5c1ba)

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

### 初始化和复位

![image](https://github.com/Vikkdsun/GT/assets/114153159/a96060d2-95e8-440b-90cb-d7a51b2937a2)

GTX/GTH收发器必须在FPGA器件上电和配置后进行初始化，然后才能使用。GTX/GTH发射机（TX）和接收机（RX）可以独立和并行初始化，如图2-12所示。GTX/GTH收发器TX和RX初始化包括两个步骤：1.初始化驱动TX/RX的相关PLL。2.初始化TX和RX数据路径（PMA + PCS）。GTX/GTH收发器TX和RX可以从QPLL或CPLL接收时钟。在TX和RX初始化之前，必须首先初始化TX和RX使用的相关PLL（QPLL/CPLL）。TX和RX所使用的任何PLL均单独复位，其复位操作完全独立于所有TX和RX复位。只有在相关PLL锁定后，才能初始化TX和RX数据路径。

![image](https://github.com/Vikkdsun/GT/assets/114153159/e3394ad4-1963-4880-ab41-782497e047a4)

![image](https://github.com/Vikkdsun/GT/assets/114153159/5326ee39-b0dd-4525-9ccf-4e1cd05f2d72)

TX/GTH收发器提供两种类型的复位：初始化和组件。初始化复位：该复位用于完整的GTX/GTH收发器初始化。必须在设备上电和配置后使用。在正常操作期间，在必要时，GTTXRESET和GTRXRESET还可以用于重新初始化GTX/GTH收发器TX和RX。GTTXRESET是GTX/GTH收发器TX的初始化复位端口。GTRXRESET是GTX/GTH收发器RX的初始化复位端口。组件复位我们不关心，其实就是PMA、PCS分别复位

![image](https://github.com/Vikkdsun/GT/assets/114153159/56780945-74f7-41d9-9998-aed2f6cf7d16)

GTX/GTH收发器RX复位可以在两种不同的模式下操作：顺序模式和单一模式。GTX/GTH收发器TX复位只能在顺序模式下操作。

1.顺序模式：复位状态机从初始化或组件复位输入驱动为高电平开始，并在复位状态机中请求复位状态之后的所有状态中继续进行，如图2-15（GTX/GTH收发器TX）或图2-20（GTX/GTH收发器RX）所示，直至完成。当（TX/RX）RESETDONE从低电平转换到高电平时，用信号通知顺序模式复位流程的完成。

2.单一模式：复位状态机仅在由其属性设置的预定时间内独立地执行所请求的组件复位。它不处理请求状态之后的任何状态，如图2-20所示的GTX/GTH收发器RX。所请求的复位可以是任何部件复位，以复位PMA、PCS或其内部的功能块。当RXRESETDONE从低电平转换为高电平时，信号表示单模式复位完成。

GTX/GTH收发器初始化复位必须使用顺序模式。所有组件复位都可以在顺序模式或单模式下操作，但TX复位除外，它只能在顺序模式下操作。

![image](https://github.com/Vikkdsun/GT/assets/114153159/76a5709a-223c-4147-9429-1015d6b04351)

![image](https://github.com/Vikkdsun/GT/assets/114153159/2424c912-12b1-491f-9574-9ac2285a2b25)

CPLL复位：***CPLLPD信号在检测到参考时钟的时钟沿之前一直置位，检测到后释放，释放后CPLL必须先复位，然后在开始使用***

![image](https://github.com/Vikkdsun/GT/assets/114153159/b67ab37b-2298-4a84-a2dc-72bd3f2c3c2f)


locked表示复位完成，复位完成后cpll才有效，此信号高有效

QPLL复位：***使用前必须先复位***

![image](https://github.com/Vikkdsun/GT/assets/114153159/67710958-ee05-474f-86a9-20e22183f18e)

TX复位：

之前我们看到2-15图的流程了，但有一点要注意***在检测到TXUSERRDY为高电平之前，TX复位状态机不会复位PCS***

![image](https://github.com/Vikkdsun/GT/assets/114153159/29315ee4-fd04-4e5e-a033-214916910370)

![image](https://github.com/Vikkdsun/GT/assets/114153159/c7d0a83b-a9ea-4d3c-91c3-0095854e971b)

![image](https://github.com/Vikkdsun/GT/assets/114153159/564e4144-e5a6-458e-8851-e0a33c3842a4)

![image](https://github.com/Vikkdsun/GT/assets/114153159/6ead08b4-5c15-410c-90a4-0be33fe5b4e6)

![image](https://github.com/Vikkdsun/GT/assets/114153159/116de337-6aea-4ceb-9ee2-12621b91509d)

如图2-16所示，建议使用来自CPLL或QPLL的相关PLLLOCK来释放从高电平到低电平的GTTXRESET。TX复位状态机在检测到GTTXRESET为高电平时等待，并启动复位序列，直到GTTXCLK被释放为低电平。

RX复位：

![image](https://github.com/Vikkdsun/GT/assets/114153159/a63aab22-8c84-48e9-8102-1b02d78c382d)

![image](https://github.com/Vikkdsun/GT/assets/114153159/3350ac70-1474-4aea-bb8b-42eb52d545db)

![image](https://github.com/Vikkdsun/GT/assets/114153159/1be46c8c-d503-4196-bac1-dec115d934fe)

![image](https://github.com/Vikkdsun/GT/assets/114153159/8c6373e1-3dc4-4fb2-a0bc-3ea6d4695180)

环回：

![image](https://github.com/Vikkdsun/GT/assets/114153159/c919d81e-7e59-46a3-86c4-b1fb110ab39d)

Near-End PCS Loopback (path 1 in Figure 2-26)

Near-End PMA Loopback (path 2 in Figure 2-26)

Far-End PMA Loopback (path 3 in Figure 2-26)

Far-End PCS Loopback (path 4 in Figure 2-26)

![image](https://github.com/Vikkdsun/GT/assets/114153159/583a9214-8116-4c7f-8f95-de5d901ed704)


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

发送端发送一个K28.5作为逗号，接收端接收时窗口扫描 找K28.5 找到之后就找到了串并转换的开始

时钟矫正时，时不时发送矫正序列，为了接收端CDR。

### 对于本项目中顶层文件中，GT_IP使用usrclk2产生的reset驱动复位的思考：

![image](https://github.com/Vikkdsun/GT/assets/114153159/7fd0fec1-f6d6-4a99-99ca-c37ba7a2f887)

#### 当输入GT的复位一直拉高，QPLL出现的反而比outclk慢，而且由于一直拉高，不会初始化成功

![image](https://github.com/Vikkdsun/GT/assets/114153159/e9d289e8-ed20-4318-a008-eba6f8945e11)

#### 上图才是正常时序，也就是i_tx_reset一直为0（不复位）产生一个QPLL的reset(图中有两个reset 上面_i是ip输出的 下面的_t是做了或操作 送到COMMON的真正reset)，过了这个reset后，QPLL先lock，然后才有outclk然后userclk2，最后初始化成功

![image](https://github.com/Vikkdsun/GT/assets/114153159/0125115e-92a8-4e22-8529-c8438a652d13)

#### 但是当我们在i_tx_reset（图中最上面的信号）一直为1（没有clk2时）时，不会产生QPLL的reset，很快产生outclk以及outclk2，虽然QPLL很快lock，但是还是慢于outclk，这时错误的，随着clk2的产生，i_tx_reset又变0了，然后QPLL重新reset了，又重新产生了outclk和userclk2，这回顺序才对

#### 从中我们知道，GT输入的TX_reset为高不会限制QPLL和outclk的产生，但是变0的话会有一个QPLL的reset，然后重新生成QPLL、然后outclk。

#### 但是tx_reset为高会限制GT的初始化，虽然产生了QPLL和outclk，但是GT还没初始化成功，只有QPLL成功lock，然后outclk成功输出一段时间后，才有初始化成功，也就是图中第二个金色信号

>总结 输入GT的复位可以一直为0，这样会让QPLL先复位一下再重新生成，生成之后才有outclk
>输入GT的复位可以先1后0，先1，outclk生成，并且快于QPLL，但是复位变0后，QPLL重新生成，outclk就消失了，直到QPLL成功生成后，才有，这回变成正常时序了。
>但是输入GT的复位不能一直为1，首先时序不对，其次不会初始化成功。

>也就是必须现有QPLL，然后有outclk和useclk2，然后才有GT的工作状态。

All reset ports described in this section initiate the internal reset state machine when driven High. The internal reset state machines are held in the reset state until these same reset ports are driven Low. These resets are all asynchronous. The guideline for the pulse width of these asynchronous resets is one period of the reference clock, unless otherwise noted.

本节所述的所有复位端口在驱动为高电平时启动内部复位状态机。内部复位状态机保持在复位状态，直到这些相同的复位端口被驱动为低电平。这些重置都是异步的。除非另有说明，否则这些异步复位的脉冲宽度准则为参考时钟的一个周期。

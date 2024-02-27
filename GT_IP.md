# GT_IP

该链接可供参考：

[https://blog.csdn.net/lum250/article/details/119952822]

## 第一页

![image](https://github.com/Vikkdsun/GT/assets/114153159/481f18ec-95f0-46ca-8ad7-b1a767812f30)

GT Type: GT有以下几种类型

***GTP、GTX、GTH 和 GTZ：***

> 这四个是 Xilinx 7 系列 FPGA 全系所支持的 GTSGT 的意思是 Gigabyte TransceiverSG 比特收发器。通常称呼为 Serdes高速收发器SGTS或者用具体型号·例如(GTX)来称呼。
> 7 系列中，按支持的最高线速率排序，GTP 是最低的、GTZ 是最高的，GTP 被用于 A7 系列，GTZ 被用于少数 V7 系列。从 K7 到 V7，最常见的是 GTX 和 GTH。GTH 的最高线速率比GTX 稍微高一点点。
> GTX 和 GTH 的文档都是 UG476从这里就能看出来S这两个 GT 的基本结构大同小异。所以掌握一个,另一个基本也就熟悉了。
> 
参考自知乎：[https://zhuanlan.zhihu.com/p/46052855?utm_id=0]

## 第二页

![image](https://github.com/Vikkdsun/GT/assets/114153159/2a18af28-c54e-408a-b320-c166d3b3eb09)

Protocol：在本项目中，我们自己设置协议，所以选择Start from scratch

Line Rate：设置线速率，在这里我们设置为10

TX off（TX off）：关闭发送/接收通道，这里不关闭

Reference Clock：参考时钟，在原理图上挑选GT Bank上的时钟，在7100这张卡上我们设置200Mhz时钟

![image](https://github.com/Vikkdsun/GT/assets/114153159/aba617fc-b5a2-4f91-a13b-9efeb0211522)

Quad Column：根据原理图确定GT收发器的是左还是右，在这张板卡上只有Right一个选择

Use Common DRP：是否使用***COMMON block 的 DRP（动态重新配置）***（这里我们认为COMMON block就是例程中的COMMON模块，生成QPLL的）

PLL Selection：选择QPLL或者CPLL，本项目设置10G速率，只能使用QPLL

Transcevies Selection：

根据作图选中使用的收发器Channel，然后勾选

TX clock source：选择时钟源 这里选择本Bank的Q0时钟，这里***Refclk后面的数字表示本bank的第几个时钟***，***Q后面的数字代表第几个bank的时钟***

![image](https://github.com/Vikkdsun/GT/assets/114153159/b911d420-7401-4276-b2d2-49e595541b8e)

后面的选项本项目没有选中

## 第三页

![image](https://github.com/Vikkdsun/GT/assets/114153159/9b6d74e5-18a3-4981-8f61-61f42f07d828)

External Data Width：外部数据位宽，是和FPGA进行交互的数据位宽，这里设置为32

Encoding：选择编码方式，这里设置为8B/10B

internal Data Width：内部数据位宽，因为数据编码是8B/10B，32外部位宽对应的就是40内部位宽

DRP/System Clok Fre：DRP和系统一起用的系统时钟，我们这里设置为100Mhz

Option Ports：本项目没有用到，这里不做讨论

Enable TX Buffer：是否使用缓冲区，这里我们认为这个Buffer就是我们采用的跨时钟弹性Buffer

UsrClksource：Usrclk的时钟源选择，我们这里TX使用其outclk，RX也用Tx的outclk，这一点在例程中或项目代码中都可以看到 usr_clk这个模块输入的只有TXoutclk

Outclksource：选择使用GT收发器输入的参考时钟作为Outclk的源

Optional Ports：本项目不做选择，具体参考顶层链接

## 第四页

![image](https://github.com/Vikkdsun/GT/assets/114153159/847fcf56-f180-4efd-8c0f-5730d75d1c82)

![image](https://github.com/Vikkdsun/GT/assets/114153159/1d0040bd-e50a-4e1e-a927-bc5c1e12932d)

COMMA Detection：逗号检测，Comma Value设置逗号码，本项目采用K28.5，COMMA mask是逗号掩码，我们10bit全都有效 所以设为1

Align to：

![image](https://github.com/Vikkdsun/GT/assets/114153159/7cf056e6-1d0e-4ab7-a352-0ffe470ee41f)

Decode valid comma only：这里不做选择，选中会限制只检测指定字符

Combine plus/minus commas：这里不做选择，我们认为选中则使得comma为两个字符即两个K28.5

Optional Ports：这里我们只选择RXBYTEISALIGN，这是指示当前返回给用户的数据是否***字节对齐***了 高电平有效

Differencial Swing：这里我们没有用任何协议，设置为定制

RX Equalization：均衡器，根据实际情况选择，我们这里采用LPM，因为我们短距离通信

RX Termination：电压设置为可编程，根据***眼图***判断设置电压大小，我们设置为800，也就是电压大于800，在接收端认为是1，反之为0

Optinal Ports：对选择的ports做一下解释：

POLARITY：极性翻转与否，设为1也就是发送接口或者接收接口的P/N相反

DIFFCTRL：控制发送端输出驱动摆动控制，我们认为指示控制压摆

POSTCURSOR与PRECURSOR：后加重与前加重，这是为了考虑到发送过程中眼图缩小而对发送端电压方法的方法，我们这里对两种加重全选

## 第五页

![image](https://github.com/Vikkdsun/GT/assets/114153159/764e2b03-47fd-48d5-bb81-cd9c48be64d8)

这页我们只选中了LOOPBACK，其他是和PCIe等协议有关的

## 第六页

![image](https://github.com/Vikkdsun/GT/assets/114153159/ed62b1d3-ba9d-4c30-b362-e599c9c9cc52)

这里我们只关心时钟纠正，序列长度设置为2，使用的同步码为一个K码一个数据码，对应的8bit为0xBC和0x50，由于0x50是数据码，所以没有勾选K码选项

## 第七页

![image](https://github.com/Vikkdsun/GT/assets/114153159/24102ba1-554f-44a4-967f-57ff82f28c3c)

总结页面，在这里可以看到USRCLK和USRCLK2为250Mhz，其计算方法为：

10G / 40（内部数据位宽）

## 以上我们就配置好了GT收发器的IP核

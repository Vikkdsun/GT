# 介绍GT_ex工程中引入的模块
## gt_trans_common_reset
该模块使用***系统时钟和tx_reset***信号创造QPLL的复位信号，但是这个复位信号不会直接被引出Channel模块，而是和GT_IP的QPLL复位信号相或再引出
## gt_trans_GT_USRCLK_SOURCE
该模块是使用GT_IP输出的***tx_outclk***，以及GT_IP的MMCM接口创造rxusrclk rxusrclk2 txusrclk txusrclk2等时钟
## gt_trans_common
该模块和QPLL有关，利用***参考时钟和系统时钟***

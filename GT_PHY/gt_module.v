`timescale 1ns/1ps

module gt_module(
    input                   i_sys_clk           ,
    input                   i_bank_refclk_n     ,
    input                   i_bank_refclk_p     ,

    input                   i_tx0_reset         ,
    input                   i_rx0_reset         ,
    input                   i_tx1_reset         ,
    input                   i_rx1_reset         ,

    output                  o_tx0_done          ,
    output                  o_rx0_done          ,
    output                  o_tx1_done          ,
    output                  o_rx1_done          ,

    input                   i_rx0_polarity      ,
    input                   i_tx0_polarity      ,
    input                   i_rx1_polarity      ,
    input                   i_tx1_polarity      ,

    input  [4:0]            i_tx0postcursor     ,
    input  [4:0]            i_tx0precursor      ,
    input  [3:0]            i_tx0diffctrl       ,
    input  [4:0]            i_tx1postcursor     ,
    input  [4:0]            i_tx1precursor      ,
    input  [3:0]            i_tx1diffctrl       ,

    input  [8:0]            i_0_drpaddr_in      ,
    input                   i_0_drpclk_in       ,
    input  [15:0]           i_0_drpdi_in        ,
    output [15:0]           o_0_drpdo_out       ,
    input                   i_0_drpen_in        ,
    output                  o_0_drprdy_out      ,
    input                   i_0_drpwe_in        ,

    input  [8:0]            i_1_drpaddr_in      ,
    input                   i_1_drpclk_in       ,
    input  [15:0]           i_1_drpdi_in        ,
    output [15:0]           o_1_drpdo_out       ,
    input                   i_1_drpen_in        ,
    output                  o_1_drprdy_out      ,
    input                   i_1_drpwe_in        ,

    input                   i_gtxrxp_0          ,
    input                   i_gtxrxn_0          ,
    output                  o_gtxtxn_0          ,
    output                  o_gtxtxp_0          ,

    input                   i_gtxrxp_1          ,
    input                   i_gtxrxn_1          ,
    output                  o_gtxtxn_1          ,
    output                  o_gtxtxp_1          ,

    input [2:0]             i_loopback_0        ,
    input [2:0]             i_loopback_1        ,

    input  [31:0]           i_txdata_0          ,
    output [31:0]           o_rxdata_0          ,
    output                  o_rx_aligned_0      ,
    output [3:0]            o_rxcharisk_0       ,
    input  [3:0]            i_txcharisk_0       ,

    input  [31:0]           i_txdata_1          ,
    output [31:0]           o_rxdata_1          ,
    output                  o_rx_aligned_1      ,
    output [3:0]            o_rxcharisk_1       ,
    input  [3:0]            i_txcharisk_1       ,

    output                  o_tx0_clk           ,
    output                  o_rx0_clk           ,
    output                  o_tx1_clk           ,
    output                  o_rx1_clk           
);

wire                        w_gtrefclk                      ;

wire                        w_qplllock                      ;
wire                        w_qpllrefclklost                ;
wire                        w_qpllreset                     ;
wire                        w_qplloutclk                    ;
wire                        w_qplloutrefclk                 ;


IBUFDS_GTE2 IBUFDS_GTE2_u0  
(
    .O                              (w_gtrefclk             ),
    .ODIV2                          (                       ),
    .CEB                            (0                      ),
    .I                              (i_bank_refclk_p        ),
    .IB                             (i_bank_refclk_n        )
);

gt_trans_common #(
    .WRAPPER_SIM_GTRESET_SPEEDUP        (),     // Set to "true" to speed up sim reset
    .SIM_QPLLREFCLK_SEL                 (3'b001             )     
)
gt_trans_common_u
(
    .QPLLREFCLKSEL_IN                   (3'b001             ),
    .GTREFCLK0_IN                       (w_gtrefclk         ),
    .GTREFCLK1_IN                       (0),
    .QPLLLOCK_OUT                       (w_qplllock         ),

    .QPLLLOCKDETCLK_IN                  (i_sys_clk          ),
    .QPLLOUTCLK_OUT                     (w_qplloutclk       ),
    .QPLLOUTREFCLK_OUT                  (w_qplloutrefclk    ),
    .QPLLREFCLKLOST_OUT                 (w_qpllrefclklost   ),   
    .QPLLRESET_IN                       (w_qpllreset        )
);

gt_channel gt_channel_u0(
    .i_sys_clk               (i_sys_clk         ),
    .i_gt_refclk             (w_gtrefclk        ),
    .i_tx_reset              (i_tx0_reset       ),
    .i_rx_reset              (i_rx0_reset       ),
    .o_tx_done               (o_tx0_done        ),
    .o_rx_done               (o_rx0_done        ),

    .i_rx_polarity           (i_rx0_polarity    ),
    .i_tx_polarity           (i_tx0_polarity    ),
    .i_txpostcursor          (i_tx0postcursor   ),
    .i_txprecursor           (i_tx0precursor    ),
    .i_txdiffctrl            (i_tx0diffctrl     ),

    .i_drpaddr_in            (i_0_drpaddr_in    ),
    .i_drpclk_in             (i_0_drpclk_in     ),
    .i_drpdi_in              (i_0_drpdi_in      ),
    .o_drpdo_out             (o_0_drpdo_out     ),
    .i_drpen_in              (i_0_drpen_in      ),
    .o_drprdy_out            (o_0_drprdy_out    ),
    .i_drpwe_in              (i_0_drpwe_in      ),

    .i_loopback              (i_loopback_0      ),

    .i_qplllock              (w_qplllock        ),
    .i_qpllrefclklost        (w_qpllrefclklost  ),
    .o_qpllreset             (w_qpllreset       ),
    .i_qplloutclk            (w_qplloutclk      ),
    .i_qplloutrefclk         (w_qplloutrefclk   ),

    .i_gtxrxp                (i_gtxrxp_0        ),
    .i_gtxrxn                (i_gtxrxn_0        ),
    .o_gtxtxn                (o_gtxtxn_0        ),
    .o_gtxtxp                (o_gtxtxp_0        ),

    .i_txdata                (i_txdata_0        ),
    .o_rxdata                (o_rxdata_0        ),
    .o_rx_aligned            (o_rx_aligned_0    ),
    .o_rxcharisk             (o_rxcharisk_0     ),
    .i_txcharisk             (i_txcharisk_0     ),

    .o_tx_clk                (o_tx0_clk         ),
    .o_rx_clk                (o_rx0_clk         )
);

gt_channel gt_channel_u1(
    .i_sys_clk               (i_sys_clk         ),
    .i_gt_refclk             (w_gtrefclk        ),
    .i_tx_reset              (i_tx1_reset       ),
    .i_rx_reset              (i_rx1_reset       ),
    .o_tx_done               (o_tx1_done        ),
    .o_rx_done               (o_rx1_done        ),

    .i_rx_polarity           (i_rx1_polarity    ),
    .i_tx_polarity           (i_tx1_polarity    ),
    .i_txpostcursor          (i_tx1postcursor   ),
    .i_txprecursor           (i_tx1precursor    ),
    .i_txdiffctrl            (i_tx1diffctrl     ),

    .i_drpaddr_in            (i_1_drpaddr_in    ),
    .i_drpclk_in             (i_1_drpclk_in     ),
    .i_drpdi_in              (i_1_drpdi_in      ),
    .o_drpdo_out             (o_1_drpdo_out     ),
    .i_drpen_in              (i_1_drpen_in      ),
    .o_drprdy_out            (o_1_drprdy_out    ),
    .i_drpwe_in              (i_1_drpwe_in      ),

    .i_loopback              (i_loopback_1      ),

    .i_qplllock              (w_qplllock        ),
    .i_qpllrefclklost        (w_qpllrefclklost  ),
    .o_qpllreset             (),    
    .i_qplloutclk            (w_qplloutclk      ),
    .i_qplloutrefclk         (w_qplloutrefclk   ),

    .i_gtxrxp                (i_gtxrxp_1        ),
    .i_gtxrxn                (i_gtxrxn_1        ),
    .o_gtxtxn                (o_gtxtxn_1        ),
    .o_gtxtxp                (o_gtxtxp_1        ),

    .i_txdata                (i_txdata_1        ),
    .o_rxdata                (o_rxdata_1        ),
    .o_rx_aligned            (o_rx_aligned_1    ),
    .o_rxcharisk             (o_rxcharisk_1     ),
    .i_txcharisk             (i_txcharisk_1     ),

    .o_tx_clk                (o_tx1_clk         ),
    .o_rx_clk                (o_rx1_clk         )
);


endmodule

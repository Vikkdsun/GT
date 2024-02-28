`timescale 1ns/1ps

module gt_channel(
    input                       i_sys_clk               ,
    input                       i_gt_refclk             ,
    input                       i_tx_reset              ,
    input                       i_rx_reset              ,
    output                      o_tx_done               ,
    output                      o_rx_done               ,

    input                       i_rx_polarity           ,
    input                       i_tx_polarity           ,
    input  [4:0]                i_txpostcursor          ,
    input  [4:0]                i_txprecursor           ,
    input  [3:0]                i_txdiffctrl            ,

    input  [8:0]                i_drpaddr_in            ,
    input                       i_drpclk_in             ,
    input  [15:0]               i_drpdi_in              ,
    output [15:0]               o_drpdo_out             ,
    input                       i_drpen_in              ,
    output                      o_drprdy_out            ,
    input                       i_drpwe_in              ,

    input  [2:0]                i_loopback              ,

    input                       i_qplllock              ,
    input                       i_qpllrefclklost        ,
    output                      o_qpllreset             ,
    input                       i_qplloutclk            ,
    input                       i_qplloutrefclk         ,

    input                       i_gtxrxp                ,
    input                       i_gtxrxn                ,
    output                      o_gtxtxn                ,
    output                      o_gtxtxp                ,

    input  [31:0]               i_txdata                ,
    output [31:0]               o_rxdata                ,
    output                      o_rx_aligned            ,
    output [3:0]                o_rxcharisk             ,
    input  [3:0]                i_txcharisk             ,

    output                      o_tx_clk                ,
    output                      o_rx_clk                
);


wire                            w_common_reset          ;
wire                            w_gt_trans_qpllreset    ;
assign                          o_qpllreset = w_common_reset | w_gt_trans_qpllreset;

wire                            tx_mmcm_lock_in         ;
wire                            tx_mmcm_reset_out       ;
wire                            rx_mmcm_lock_in         ;
wire                            rx_mmcm_reset_out       ;

wire                            w_gt0_rxusrclk          ;
wire                            w_gt0_rxusrclk2         ;
wire                            w_gt0_txusrclk          ;
wire                            w_gt0_txusrclk2         ;

wire                            w_gt0_txoutclk          ;

assign                          o_tx_clk = w_gt0_txusrclk2;
assign                          o_rx_clk = w_gt0_rxusrclk2;

gt_trans_common_reset  #(
    .STABLE_CLOCK_PERIOD            ()        // Period of the stable clock driving this state-machine, unit is [ns]
)   
gt_trans_common_reset_u
(       
    .STABLE_CLOCK                   (i_sys_clk              ),             //Stable Clock, either a stable clock from the PCB
    .SOFT_RESET                     (i_tx_reset             ),               //User Reset, can be pulled any time
    .COMMON_RESET                   (w_common_reset         )           //Reset QPLL
);

gt_trans_GT_USRCLK_SOURCE gt_trans_GT_USRCLK_SOURCE_u
(
    .GT0_TXUSRCLK_OUT               (w_gt0_txusrclk         ),
    .GT0_TXUSRCLK2_OUT              (w_gt0_txusrclk2        ),

    .GT0_TXOUTCLK_IN                (w_gt0_txoutclk         ),
    .GT0_TXCLK_LOCK_OUT             (tx_mmcm_lock_in        ),
    .GT0_TX_MMCM_RESET_IN           (tx_mmcm_reset_out      ),

    .GT0_RXUSRCLK_OUT               (w_gt0_rxusrclk         ),
    .GT0_RXUSRCLK2_OUT              (w_gt0_rxusrclk2        ),

    .GT0_RXCLK_LOCK_OUT             (rx_mmcm_lock_in        ),
    .GT0_RX_MMCM_RESET_IN           (rx_mmcm_reset_out      )
);

gt_trans  gt_trans_i
(
    .sysclk_in                      (i_sys_clk              ), // input wire sysclk_in
    .soft_reset_tx_in               (i_tx_reset             ), // input wire soft_reset_tx_in
    .soft_reset_rx_in               (i_rx_reset             ), // input wire soft_reset_rx_in
    .dont_reset_on_data_error_in    (0                      ), // input wire dont_reset_on_data_error_in
    .gt0_tx_fsm_reset_done_out      (o_tx_done              ), // output wire gt0_tx_fsm_reset_done_out
    .gt0_rx_fsm_reset_done_out      (), // output wire gt0_rx_fsm_reset_done_out
    .gt0_data_valid_in              (1                      ), // input wire gt0_data_valid_in

    .gt0_tx_mmcm_lock_in            (tx_mmcm_lock_in        ), // input wire gt0_tx_mmcm_lock_in
    .gt0_tx_mmcm_reset_out          (tx_mmcm_reset_out      ), // output wire gt0_tx_mmcm_reset_out
    .gt0_rx_mmcm_lock_in            (rx_mmcm_lock_in        ), // input wire gt0_rx_mmcm_lock_in
    .gt0_rx_mmcm_reset_out          (rx_mmcm_reset_out      ), // output wire gt0_rx_mmcm_reset_out

    .gt0_drpaddr_in                 (i_drpaddr_in           ), // input wire [8:0] gt0_drpaddr_in
    .gt0_drpclk_in                  (i_drpclk_in            ), // input wire gt0_drpclk_in
    .gt0_drpdi_in                   (i_drpdi_in             ), // input wire [15:0] gt0_drpdi_in
    .gt0_drpdo_out                  (o_drpdo_out            ), // output wire [15:0] gt0_drpdo_out
    .gt0_drpen_in                   (i_drpen_in             ), // input wire gt0_drpen_in
    .gt0_drprdy_out                 (o_drprdy_out           ), // output wire gt0_drprdy_out
    .gt0_drpwe_in                   (i_drpwe_in             ), // input wire gt0_drpwe_in

    .gt0_dmonitorout_out            (), // output wire [7:0] gt0_dmonitorout_out
    .gt0_loopback_in                (i_loopback             ), // input wire [2:0] gt0_loopback_in
    .gt0_eyescanreset_in            (0                      ), // input wire gt0_eyescanreset_in
    .gt0_rxuserrdy_in               (1                      ), // input wire gt0_rxuserrdy_in
    .gt0_eyescandataerror_out       (), // output wire gt0_eyescandataerror_out
    .gt0_eyescantrigger_in          (0                      ), // input wire gt0_eyescantrigger_in
    .gt0_rxusrclk_in                (w_gt0_rxusrclk         ), // input wire gt0_rxusrclk_in
    .gt0_rxusrclk2_in               (w_gt0_rxusrclk2        ), // input wire gt0_rxusrclk2_in
    .gt0_rxdata_out                 (o_rxdata               ), // output wire [31:0] gt0_rxdata_out
    .gt0_rxdisperr_out              (), // output wire [3:0] gt0_rxdisperr_out
    .gt0_rxnotintable_out           (), // output wire [3:0] gt0_rxnotintable_out
    .gt0_gtxrxp_in                  (i_gtxrxp               ), // input wire gt0_gtxrxp_in
    .gt0_gtxrxn_in                  (i_gtxrxn               ), // input wire gt0_gtxrxn_in
    .gt0_rxbyteisaligned_out        (o_rx_aligned           ), // output wire gt0_rxbyteisaligned_out
    .gt0_rxdfelpmreset_in           (0                      ), // input wire gt0_rxdfelpmreset_in
    .gt0_rxmonitorout_out           (), // output wire [6:0] gt0_rxmonitorout_out
    .gt0_rxmonitorsel_in            (0                      ), // input wire [1:0] gt0_rxmonitorsel_in
    .gt0_rxoutclkfabric_out         (), // output wire gt0_rxoutclkfabric_out
    .gt0_gtrxreset_in               (i_rx_reset             ), // input wire gt0_gtrxreset_in
    .gt0_rxpmareset_in              (i_rx_reset             ), // input wire gt0_rxpmareset_in
    .gt0_rxpolarity_in              (i_rx_polarity          ), // input wire gt0_rxpolarity_in
    .gt0_rxcharisk_out              (o_rxcharisk            ), // output wire [3:0] gt0_rxcharisk_out
    .gt0_rxresetdone_out            (o_rx_done              ), // output wire gt0_rxresetdone_out
    .gt0_txpostcursor_in            (i_txpostcursor         ), // input wire [4:0] gt0_txpostcursor_in
    .gt0_txprecursor_in             (i_txprecursor          ), // input wire [4:0] gt0_txprecursor_in
    .gt0_gttxreset_in               (i_tx_reset             ), // input wire gt0_gttxreset_in
    .gt0_txuserrdy_in               (1                      ), // input wire gt0_txuserrdy_in
    .gt0_txusrclk_in                (w_gt0_txusrclk         ), // input wire gt0_txusrclk_in
    .gt0_txusrclk2_in               (w_gt0_txusrclk2        ), // input wire gt0_txusrclk2_in
    .gt0_txdiffctrl_in              (i_txdiffctrl           ), // input wire [3:0] gt0_txdiffctrl_in
    .gt0_txdata_in                  (i_txdata               ), // input wire [31:0] gt0_txdata_in
    .gt0_gtxtxn_out                 (o_gtxtxn               ), // output wire gt0_gtxtxn_out
    .gt0_gtxtxp_out                 (o_gtxtxp               ), // output wire gt0_gtxtxp_out
    .gt0_txoutclk_out               (w_gt0_txoutclk         ), // output wire gt0_txoutclk_out
    .gt0_txoutclkfabric_out         (), // output wire gt0_txoutclkfabric_out
    .gt0_txoutclkpcs_out            (), // output wire gt0_txoutclkpcs_out
    .gt0_txcharisk_in               (i_txcharisk            ), // input wire [3:0] gt0_txcharisk_in
    .gt0_txresetdone_out            (), // output wire gt0_txresetdone_out
    .gt0_txpolarity_in              (i_tx_polarity          ), // input wire gt0_txpolarity_in


    .gt0_qplllock_in                (i_qplllock             ), // input wire gt0_qplllock_in
    .gt0_qpllrefclklost_in          (i_qpllrefclklost       ), // input wire gt0_qpllrefclklost_in
    .gt0_qpllreset_out              (w_gt_trans_qpllreset   ), // output wire gt0_qpllreset_out
    .gt0_qplloutclk_in              (o_rxcharisk            ), // input wire gt0_qplloutclk_in
    .gt0_qplloutrefclk_in           (i_txcharisk            ) // input wire gt0_qplloutrefclk_in
);


endmodule

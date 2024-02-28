`timescale 1ns/1ps

module GT_top(
    input                       i_sysclk                    ,   // can change it to P/N and add a IBUFDS
    input                       i_gtrefclk_p                ,
    input                       i_gtrefclk_n                ,

    output[1:0]                 o_gt0_tx_p                  ,
    output[1:0]                 o_gt0_tx_n                  ,
    input [1:0]                 i_gt0_rx_p                  ,
    input [1:0]                 i_gt0_rx_n                  ,

    input                       i_0_axi_s_valid             ,
    input [3:0]                 i_0_axi_s_keep              ,
    input [31:0]                i_0_axi_s_data              ,
    input                       i_0_axi_s_last              ,
    output                      o_0_axi_s_ready             ,

    output                      o_0_axi_m_valid             ,
    output                      o_0_axi_m_last              ,
    output [3:0]                o_0_axi_m_keep              ,
    output [31:0]               o_0_axi_m_data              ,
    input                       i_0_axi_m_ready             ,

    input                       i_1_axi_s_valid             ,
    input [3:0]                 i_1_axi_s_keep              ,
    input [31:0]                i_1_axi_s_data              ,
    input                       i_1_axi_s_last              ,
    output                      o_1_axi_s_ready             ,

    output                      o_1_axi_m_valid             ,
    output                      o_1_axi_m_last              ,
    output [3:0]                o_1_axi_m_keep              ,
    output [31:0]               o_1_axi_m_data              ,
    input                       i_1_axi_m_ready             
);

wire                            w_rx0_clk                   ;
wire                            w_rx0_rst                   ;
wire                            w_rx0_ByteAlign             ;
wire [31:0]                     w_rx0_data                  ;
wire [3 :0]                     w_rx0_char                  ;

wire                            w_tx0_clk                   ;
wire                            w_tx0_rst                   ;
wire                            w_tx0_done                  ;
wire [31:0]                     w_gt_tx_data_0              ;
wire [3:0]                      w_gt_tx_charisk_0           ;


wire                            w_rx1_clk                   ;
wire                            w_rx1_rst                   ;
wire                            w_rx1_ByteAlign             ;
wire [31:0]                     w_rx1_data                  ;
wire [3 :0]                     w_rx1_char                  ;

wire                            w_tx1_clk                   ;
wire                            w_tx1_rst                   ;
wire                            w_tx1_done                  ;
wire [31:0]                     w_gt_tx_data_1              ;
wire [3:0]                      w_gt_tx_charisk_1           ;

rst_gen#(
    .P_CYCLE    (10)
)
rst_gen_tx0
(
    .i_clk               (w_tx0_clk),
    .o_rst               (w_tx0_rst)
);

rst_gen#(
    .P_CYCLE    (10)
)
rst_gen_rx0
(
    .i_clk               (w_rx0_clk),
    .o_rst               (w_rx0_rst)
);

rst_gen#(
    .P_CYCLE    (10)
)
rst_gen_tx1
(
    .i_clk               (w_tx1_clk),
    .o_rst               (w_tx1_rst)
);

rst_gen#(
    .P_CYCLE    (10)
)
rst_gen_rx1
(
    .i_clk               (w_rx1_clk),
    .o_rst               (w_rx1_rst)
);

gt_module gt_module_u(
    .i_sys_clk           (i_sysclk    ),
    .i_bank_refclk_n     (i_gtrefclk_p),
    .i_bank_refclk_p     (i_gtrefclk_n),

    .i_tx0_reset         (w_tx0_rst),
    .i_rx0_reset         (w_rx0_rst),
    .i_tx1_reset         (w_tx1_rst),
    .i_rx1_reset         (w_rx1_rst),

    .o_tx0_done          (w_tx0_done),
    .o_rx0_done          (),
    .o_tx1_done          (w_tx1_done),
    .o_rx1_done          (),

    .i_rx0_polarity      (0),
    .i_tx0_polarity      (0),
    .i_rx1_polarity      (0),
    .i_tx1_polarity      (0),

    .i_tx0postcursor     (5'b00011),
    .i_tx0precursor      (5'b00111),
    .i_tx0diffctrl       (4'b1100 ),
    .i_tx1postcursor     (5'b00011),
    .i_tx1precursor      (5'b00111),
    .i_tx1diffctrl       (4'b1100 ),

    .i_0_drpaddr_in      (0),
    .i_0_drpclk_in       (0),
    .i_0_drpdi_in        (0),
    .o_0_drpdo_out       ( ),
    .i_0_drpen_in        (0),
    .o_0_drprdy_out      ( ),
    .i_0_drpwe_in        (0),

    .i_1_drpaddr_in      (0),
    .i_1_drpclk_in       (0),
    .i_1_drpdi_in        (0),
    .o_1_drpdo_out       ( ),
    .i_1_drpen_in        (0),
    .o_1_drprdy_out      ( ),
    .i_1_drpwe_in        (0),

    .i_gtxrxp_0          (i_gt0_rx_p[0]),
    .i_gtxrxn_0          (i_gt0_rx_n[0]),
    .o_gtxtxn_0          (o_gt0_tx_p[0]),
    .o_gtxtxp_0          (o_gt0_tx_n[0]),

    .i_gtxrxp_1          (i_gt0_rx_p[1]),
    .i_gtxrxn_1          (i_gt0_rx_n[1]),
    .o_gtxtxn_1          (o_gt0_tx_p[1]),
    .o_gtxtxp_1          (o_gt0_tx_n[1]),

    .i_loopback_0        (0),
    .i_loopback_1        (0),

    .i_txdata_0          (w_gt_tx_data_0    ),
    .o_rxdata_0          (w_rx0_data        ),
    .o_rx_aligned_0      (w_rx0_ByteAlign   ),
    .o_rxcharisk_0       (w_rx0_char        ),
    .i_txcharisk_0       (w_gt_tx_charisk_0 ),

    .i_txdata_1          (w_gt_tx_data_1    ),
    .o_rxdata_1          (w_rx1_data        ),
    .o_rx_aligned_1      (w_rx1_ByteAlign   ),
    .o_rxcharisk_1       (w_rx1_char        ),
    .i_txcharisk_1       (w_gt_tx_charisk_1 ),

    .o_tx0_clk           (w_tx0_clk),
    .o_rx0_clk           (w_rx0_clk),
    .o_tx1_clk           (w_tx1_clk),
    .o_rx1_clk           (w_rx1_clk)
);


phy_module phy_module_u0(
    .i_tx_clk            (w_tx0_clk),
    .i_tx_rst            (w_tx0_rst),
    .i_rx_clk            (w_rx0_clk),
    .i_rx_rst            (w_rx0_rst),

    .i_axi_s_valid       (i_0_axi_s_valid),
    .i_axi_s_keep        (i_0_axi_s_keep ),
    .i_axi_s_data        (i_0_axi_s_data ),
    .i_axi_s_last        (i_0_axi_s_last ),
    .o_axi_s_ready       (o_0_axi_s_ready),

    .o_axi_m_valid       (o_0_axi_m_valid),
    .o_axi_m_last        (o_0_axi_m_last ),
    .o_axi_m_keep        (o_0_axi_m_keep ),
    .o_axi_m_data        (o_0_axi_m_data ),
    .i_axi_m_ready       (i_0_axi_m_ready),

    .i_gt_tx_done        (w_tx0_done        ),
    .o_gt_tx_data        (w_gt_tx_data_0    ),
    .o_gt_tx_charisk     (w_gt_tx_charisk_0 ),
    .i_gt_bytealign      (w_rx0_ByteAlign   ),
    .i_gt_rx_data        (w_rx0_data        ),
    .i_gt_rx_charisk     (w_rx0_char        )
);

phy_module phy_module_u1(
    .i_tx_clk            (w_tx1_clk),
    .i_tx_rst            (w_tx1_rst),
    .i_rx_clk            (w_rx1_clk),
    .i_rx_rst            (w_rx1_rst),

    .i_axi_s_valid       (i_1_axi_s_valid),
    .i_axi_s_keep        (i_1_axi_s_keep ),
    .i_axi_s_data        (i_1_axi_s_data ),
    .i_axi_s_last        (i_1_axi_s_last ),
    .o_axi_s_ready       (o_1_axi_s_ready),

    .o_axi_m_valid       (o_1_axi_m_valid),
    .o_axi_m_last        (o_1_axi_m_last ),
    .o_axi_m_keep        (o_1_axi_m_keep ),
    .o_axi_m_data        (o_1_axi_m_data ),
    .i_axi_m_ready       (i_1_axi_m_ready),

    .i_gt_tx_done        (w_tx1_done        ),
    .o_gt_tx_data        (w_gt_tx_data_1    ),
    .o_gt_tx_charisk     (w_gt_tx_charisk_1 ),
    .i_gt_bytealign      (w_rx1_ByteAlign   ),
    .i_gt_rx_data        (w_rx1_data        ),
    .i_gt_rx_charisk     (w_rx1_char        )
);


endmodule

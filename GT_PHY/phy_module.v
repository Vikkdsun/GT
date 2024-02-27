`timescale 1ns/1ps

module phy_module(
    input                   i_tx_clk            ,
    input                   i_tx_rst            ,
    input                   i_rx_clk            ,
    input                   i_rx_rst            ,

    input                   i_axi_s_valid       ,
    input [3:0]             i_axi_s_keep        ,
    input [31:0]            i_axi_s_data        ,
    input                   i_axi_s_last        ,
    output                  o_axi_s_ready       ,

    output                  o_axi_m_valid       ,
    output                  o_axi_m_last        ,
    output [3:0]            o_axi_m_keep        ,
    output [31:0]           o_axi_m_data        ,
    input                   i_axi_m_ready       ,

    input                   i_gt_tx_done        ,
    output [31:0]           o_gt_tx_data        ,
    output [3:0]            o_gt_tx_charisk     ,
    input                   i_gt_bytealign      ,
    input [31:0]            i_gt_rx_data        ,
    input [3:0]             i_gt_rx_charisk     
);

phy_tx phy_tx_u(
    .i_clk           (i_tx_clk          ),
    .i_rst           (i_tx_rst          ),
    /* ---- UserAxiPort ---- */ 
    .i_axi_s_valid   (i_axi_s_valid     ),
    .i_axi_s_keep    (i_axi_s_keep      ),
    .i_axi_s_data    (i_axi_s_data      ),
    .i_axi_s_last    (i_axi_s_last      ),   
    .o_axi_s_ready   (o_axi_s_ready     ),
    /* ---- GtModulePort ---- */
    .i_gt_tx_done    (i_gt_tx_done      ),
    .o_gt_tx_data    (o_gt_tx_data      ),
    .o_gt_tx_charisk (o_gt_tx_charisk   )
);

phy_rx phy_rx_u(
    .i_clk           (i_rx_clk          ),
    .i_rst           (i_rx_rst          ),
    /* ---- UserAxiPort ---- */ 
    .o_axi_m_valid   (o_axi_m_valid     ),
    .o_axi_m_last    (o_axi_m_last      ),
    .o_axi_m_keep    (o_axi_m_keep      ),
    .o_axi_m_data    (o_axi_m_data      ),
    .i_axi_m_ready   (i_axi_m_ready     ),
    /* ---- GtModulePort ---- */
    .i_gt_bytealign  (i_gt_bytealign    ),
    .i_gt_rx_data    (i_gt_rx_data      ),
    .i_gt_rx_charisk (i_gt_rx_charisk   )
);


endmodule

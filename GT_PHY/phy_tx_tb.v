`timescale 1ns/1ps

module phy_tx_tb();

reg clk, rst, i_gt_tx_done;

initial begin
    rst = 1;
    #1000;
    @(posedge clk);
    rst = 0;
end

initial
begin
    i_gt_tx_done <= 'd0;
    wait(!rst)@(posedge clk);
    i_gt_tx_done <= 'd1;
end

always
begin
    clk = 0;
    #10;
    clk = 1;
    #10;
end 

reg                   i_axi_s_valid ;
reg [3:0]             i_axi_s_keep  ;
reg [31:0]            i_axi_s_data  ;
reg                   i_axi_s_last  ;

initial
begin
    i_axi_s_valid <= 'd0;
    i_axi_s_keep  <= 'd0;
    i_axi_s_data  <= 'd0;
    i_axi_s_last  <= 'd0;
    wait(!rst)@(posedge clk);
    repeat(20)@(posedge clk);
    i_axi_s_valid <= 'd1;
    i_axi_s_keep  <= 'b1111;
    i_axi_s_data  <= 'h12345678;
    i_axi_s_last  <= 'd0;
    @(posedge clk);
    i_axi_s_valid <= 'd1;
    i_axi_s_keep  <= 'b1100;
    i_axi_s_data  <= 'h87654321;
    i_axi_s_last  <= 'd1;
    @(posedge clk);
//     i_axi_s_valid <= 'd1;
//     i_axi_s_keep  <= 'b1111;
//     i_axi_s_data  <= 'h98765432;    
//     i_axi_s_last  <= 'd0;
//     @(posedge clk);
//     i_axi_s_valid <= 'd1;
//     i_axi_s_keep  <= 'b1100;
//     i_axi_s_data  <= 'h12345678;
//     i_axi_s_last  <= 'd1;
//     @(posedge clk);
    i_axi_s_valid <= 'd0;
    i_axi_s_keep  <= 'd0;
    i_axi_s_data  <= 'd0;
    i_axi_s_last  <= 'd0;
    @(posedge clk);
end


 phy_tx phy_tx_u(
     .i_clk           (clk),
     .i_rst           (rst),
     /* ---- UserAxiPort ---- */
     .i_axi_s_valid   (i_axi_s_valid),
     .i_axi_s_keep    (i_axi_s_keep ),
     .i_axi_s_data    (i_axi_s_data ),
     .i_axi_s_last    (i_axi_s_last ),   
     .o_axi_s_ready   (),
     /* ---- GtModulePort ---- */
     .i_gt_tx_done    (i_gt_tx_done),
     .o_gt_tx_data    (),
     .o_gt_tx_charisk ()
 );

//PHY_tx PHY_tx(
//    .i_clk           (clk),
//    .i_rst           (rst),

//    .i_axi_s_data    (i_axi_s_data),
//    .i_axi_s_keep    (i_axi_s_keep ),
//    .i_axi_s_last    (i_axi_s_last ),
//    .i_axi_s_valid   (i_axi_s_valid ),
//    .o_axi_s_ready   (),

//    .i_gt_tx_done    (i_gt_tx_done),
//    .o_gt_tx_data    (),
//    .o_gt_tx_char    ()
//);





endmodule

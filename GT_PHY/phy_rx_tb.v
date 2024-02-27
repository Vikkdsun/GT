`timescale 1ns/1ps

module phy_rx_tb();

reg clk, rst;

initial begin
    rst = 1;
    #1000;
    @(posedge clk);
    rst = 0;
end

always
begin
    clk = 0;
    #10;
    clk = 1;
    #10;
end 

reg                 i_axi_m_ready = 1;
reg                 i_gt_bytealign = 1;
reg [31:0]            i_gt_rx_data      ;
reg [3:0]             i_gt_rx_charisk   ;

initial
begin
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;
    wait(!rst)@(posedge clk);
    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'h12fb50bc;
    i_gt_rx_charisk <= 4'B0101;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h121212fd;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;


    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'hfb50bc12;
    i_gt_rx_charisk <= 4'B1010;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h121212fd;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'h50bc1212;
    i_gt_rx_charisk <= 4'B0100;
    @(posedge clk);
    i_gt_rx_data    <= 'h563412fb;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h121212fd;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'hbc121212;
    i_gt_rx_charisk <= 4'b1000;
    @(posedge clk);
    i_gt_rx_data    <= 'h3412fb50;
    i_gt_rx_charisk <= 4'b0010;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h121212fd;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    ////////////////////////////////////////
    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'h12fb50bc;
    i_gt_rx_charisk <= 4'B0101;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h1212fd12;
    i_gt_rx_charisk <= 4'b0010;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'hfb50bc12;
    i_gt_rx_charisk <= 4'B1010;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h1212fd12;
    i_gt_rx_charisk <= 4'b0010;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'h50bc1212;
    i_gt_rx_charisk <= 4'B0100;
    @(posedge clk);
    i_gt_rx_data    <= 'h563412fb;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h1212fd12;
    i_gt_rx_charisk <= 4'b0010;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'hbc121212;
    i_gt_rx_charisk <= 4'b1000;
    @(posedge clk);
    i_gt_rx_data    <= 'h3412fb50;
    i_gt_rx_charisk <= 4'b0010;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h1212fd12;
    i_gt_rx_charisk <= 4'b0010;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

///////////////////////////////////////////
    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'h12fb50bc;
    i_gt_rx_charisk <= 4'B0101;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h12fd1212;
    i_gt_rx_charisk <= 4'b0100;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'hfb50bc12;
    i_gt_rx_charisk <= 4'B1010;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h12fd1212;
    i_gt_rx_charisk <= 4'b0100;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'h50bc1212;
    i_gt_rx_charisk <= 4'B0100;
    @(posedge clk);
    i_gt_rx_data    <= 'h563412fb;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h12fd1212;
    i_gt_rx_charisk <= 4'b0100;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'hbc121212;
    i_gt_rx_charisk <= 4'b1000;
    @(posedge clk);
    i_gt_rx_data    <= 'h3412fb50;
    i_gt_rx_charisk <= 4'b0010;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h12fd1212;
    i_gt_rx_charisk <= 4'b0100;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    /////////////////////////////////////////////
    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'h12fb50bc;
    i_gt_rx_charisk <= 4'B0101;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'hfd121212;
    i_gt_rx_charisk <= 4'b1000;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'hfb50bc12;
    i_gt_rx_charisk <= 4'B1010;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'hfd121212;
    i_gt_rx_charisk <= 4'b1000;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'h50bc1212;
    i_gt_rx_charisk <= 4'B0100;
    @(posedge clk);
    i_gt_rx_data    <= 'h563412fb;
    i_gt_rx_charisk <= 4'b0001;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'hfd121212;
    i_gt_rx_charisk <= 4'b1000;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;

    repeat(30)@(posedge clk);
    i_gt_rx_data    <= 'hbc121212;
    i_gt_rx_charisk <= 4'b1000;
    @(posedge clk);
    i_gt_rx_data    <= 'h3412fb50;
    i_gt_rx_charisk <= 4'b0010;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'h78563412;
    i_gt_rx_charisk <= 4'b0000;
    @(posedge clk);
    i_gt_rx_data    <= 'hfd121212;
    i_gt_rx_charisk <= 4'b1000;
    @(posedge clk);
    i_gt_rx_data    <= 'd0;
    i_gt_rx_charisk <= 'd0;
    
end

phy_rx phy_rx(
    .i_clk           (clk),
    .i_rst           (rst),
    /* ---- UserAxiPort ---- */
    .o_axi_m_valid   (),
    .o_axi_m_last    (),
    .o_axi_m_keep    (),
    .o_axi_m_data    (),
    .i_axi_m_ready   (i_axi_m_ready),
    /* ---- GtModulePort ---- */
    .i_gt_bytealign  (i_gt_bytealign ),
    .i_gt_rx_data    (i_gt_rx_data   ),
    .i_gt_rx_charisk (i_gt_rx_charisk)
);



endmodule

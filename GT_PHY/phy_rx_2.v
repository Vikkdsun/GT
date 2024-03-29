`timescale 1ns/1ps

module phy_rx(
    input                   i_clk           ,
    input                   i_rst           ,
    /* ---- UserAxiPort ---- */
    output                  o_axi_m_valid   ,
    output                  o_axi_m_last    ,
    output [3:0]            o_axi_m_keep    ,
    output [31:0]           o_axi_m_data    ,
    input                   i_axi_m_ready   ,
    /* ---- GtModulePort ---- */
    input                   i_gt_bytealign  ,
    input [31:0]            i_gt_rx_data    ,
    input [3:0]             i_gt_rx_charisk 
);


reg [31:0]              ri_gt_rx_data                   ;
reg [3:0]               ri_gt_rx_charisk                ;
reg [31:0]              ri_gt_rx_data_1d                ;
reg [3:0]               ri_gt_rx_charisk_1d             ;
reg                     r_sof                           ;
reg [3:0]               r_sof_local                     ;
reg                     r_eof                           ;
reg [3:0]               r_eof_local                     ;
reg [31:0]              r_pre_data                      ;
reg                     r_pre_valid                     ;
reg [31:0]              ro_axi_m_data                   ;
reg                     ro_axi_m_valid                  ;
reg [3:0]               ro_axi_m_keep                   ;
reg                     ro_axi_m_last                   ;

assign                  o_axi_m_data  = ro_axi_m_data   ;
assign                  o_axi_m_valid = ro_axi_m_valid  ;
assign                  o_axi_m_keep  = ro_axi_m_keep   ;
assign                  o_axi_m_last  = ro_axi_m_last   ;

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_gt_rx_data       <= 'd0;
        ri_gt_rx_charisk    <= 'd0;
        ri_gt_rx_data_1d    <= 'd0;
        ri_gt_rx_charisk_1d <= 'd0;
    end else begin
        ri_gt_rx_data       <= i_gt_rx_data   ;
        ri_gt_rx_charisk    <= i_gt_rx_charisk;
        ri_gt_rx_data_1d    <= ri_gt_rx_data   ;
        ri_gt_rx_charisk_1d <= ri_gt_rx_charisk;
    end
end

// sof use ri_data to find
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        r_sof       <= 'd0;
        r_sof_local <= 'd0;
    end else if (ri_gt_rx_data[31:8] == 24'hfb50bc && ri_gt_rx_charisk[3:1] == 3'b101) begin
        r_sof       <= 'd1;
        r_sof_local <= 4'b1000;
    end else if (ri_gt_rx_data[23:0] == 24'hfb50bc && ri_gt_rx_charisk == 4'b0101) begin
        r_sof       <= 'd1;
        r_sof_local <= 4'b0100;
    end else if (ri_gt_rx_data[15:0] == 16'hfb50 && ri_gt_rx_charisk[1] == 1'b1 && ri_gt_rx_data_1d[31:24] == 8'hbc && ri_gt_rx_charisk_1d[3] == 1'b1) begin
        r_sof       <= 'd1;
        r_sof_local <= 4'b0010;
    end else if (ri_gt_rx_data[7:0] == 8'hfb && ri_gt_rx_charisk[0] == 1'b1 && ri_gt_rx_data_1d[31:16] == 16'h50bc && ri_gt_rx_charisk_1d[3:2] == 2'b01) begin
        r_sof       <= 'd1;
        r_sof_local <= 4'b0001;
    end else begin
        r_sof       <= 'd0;
        r_sof_local <= r_sof_local;
    end
end

// eof use i_data/ ri_data/ ri_data_1d all to find 
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        r_eof       <= 'd0;
        r_eof_local <= 'd0;
    end else if (r_sof_local == 4'b1000 && i_gt_rx_data[7:0] == 8'hfd && i_gt_rx_charisk[0] == 1'b1) begin  // pre_eof
        r_eof       <= 'd1;
        r_eof_local <= 4'b0001;
    end else if (r_sof_local == 4'b0010 && ri_gt_rx_data_1d[31:24] == 8'hfd && ri_gt_rx_charisk_1d == 4'b1000) begin    // post_eof
        r_eof       <= 'd1;
        r_eof_local <= 4'b1000;
    end else if (r_sof_local == 4'b0001 && ri_gt_rx_data_1d[23:16] == 8'hfd && ri_gt_rx_charisk_1d[2:0] == 3'b100) begin  // post_eof
        r_eof       <= 'd1;
        r_eof_local <= 4'b0010;
    end else if (r_sof_local == 4'b0001 && ri_gt_rx_data_1d[31:24] == 8'hfd && ri_gt_rx_charisk_1d == 4'b1000) begin // post_eof
        r_eof       <= 'd1;
        r_eof_local <= 4'b0010;
    end else if (r_sof_local == 4'b1000 && ri_gt_rx_data[15:8] == 8'hfd && ri_gt_rx_charisk[1:0] == 2'b10) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0010;
    end else if (r_sof_local == 4'b1000 && ri_gt_rx_data[23:16] == 8'hfd && ri_gt_rx_charisk[2:0] == 3'b100) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0100;
    end else if (r_sof_local == 4'b1000 && ri_gt_rx_data[31:24] == 8'hfd && ri_gt_rx_charisk == 4'b1000) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b1000;
    end else if (r_sof_local == 4'b0010 && ri_gt_rx_data[23:16] == 8'hfd && ri_gt_rx_charisk[2:0] == 3'b100) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0100;
    end else if (r_sof_local == 4'b0010 && ri_gt_rx_data[15:8] == 8'hfd && ri_gt_rx_charisk[1:0] == 2'b10) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0010;
    end else if (r_sof_local == 4'b0010 && ri_gt_rx_data[7:0] == 8'hfd && ri_gt_rx_charisk[0] == 1'b1) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0001;
    end else if (r_sof_local == 4'b0001 && ri_gt_rx_data[15:8] == 8'hfd && ri_gt_rx_charisk[1:0] == 2'b10) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0010;
    end else if (r_sof_local == 4'b0001 && ri_gt_rx_data[7:0] == 8'hfd && ri_gt_rx_charisk[0] == 1'b1) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0001;
    end else if (r_sof_local == 4'b0100 && ri_gt_rx_data[31:24] == 8'hfd && ri_gt_rx_charisk == 4'b1000) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b1000;
    end else if (r_sof_local == 4'b0100 && ri_gt_rx_data[23:16] == 8'hfd && ri_gt_rx_charisk[2:0] == 3'b100) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0100;
    end else if (r_sof_local == 4'b0100 && ri_gt_rx_data[15:8] == 8'hfd && ri_gt_rx_charisk[1:0] == 2'b10) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0010;
    end else if (r_sof_local == 4'b0100 && ri_gt_rx_data[7:0] == 8'hfd && ri_gt_rx_charisk[0] == 1'b1) begin
        r_eof       <= 'd1;
        r_eof_local <= 4'b0001;
    end else begin
        r_eof       <= 'd0;
        r_eof_local <= 'd0;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_pre_valid <= 'd0;
    else if (r_eof)
        r_pre_valid <= 'd0;
    else if (r_sof)
        r_pre_valid <= 'd1;
    else
        r_pre_valid <= r_pre_valid;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_pre_data <= 'd0;
    else if ((r_sof || r_pre_valid) && r_sof_local == 4'b1000)
        r_pre_data <= {ri_gt_rx_data[7:0], ri_gt_rx_data[15:8], ri_gt_rx_data[23:16], ri_gt_rx_data[31:24]};
    else if ((r_sof || r_pre_valid) && r_sof_local == 4'b0100)
        r_pre_data <= {ri_gt_rx_data_1d[31:24], ri_gt_rx_data[7:0], ri_gt_rx_data[15:8], ri_gt_rx_data[23:16]};
    else if ((r_sof || r_pre_valid) && r_sof_local == 4'b0010)
        r_pre_data <= {ri_gt_rx_data_1d[23:16], ri_gt_rx_data_1d[31:24], ri_gt_rx_data[7:0], ri_gt_rx_data[15:8]};
    else if ((r_sof || r_pre_valid) && r_sof_local == 4'b0001) 
        r_pre_data <= {ri_gt_rx_data_1d[15:8], ri_gt_rx_data_1d[23:16], ri_gt_rx_data_1d[31:24], ri_gt_rx_data[7:0]};
    else
        r_pre_data <= 'd0;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_axi_m_keep <= 'd0;
    else if (r_eof && r_eof_local ==4'b0001)
        case(r_sof_local)
            4'b0001 : ro_axi_m_keep <= 4'b1110;
            4'b0010 : ro_axi_m_keep <= 4'b1100;
            4'b0100 : ro_axi_m_keep <= 4'b1000;
            4'b1000 : ro_axi_m_keep <= 4'b1111;
            default : ro_axi_m_keep <= 4'b1111;
        endcase
    else if (r_eof && r_eof_local ==4'b0010)
        case(r_sof_local)
            4'b0001 : ro_axi_m_keep <= 4'b1111;
            4'b0010 : ro_axi_m_keep <= 4'b1110;
            4'b0100 : ro_axi_m_keep <= 4'b1100;
            4'b1000 : ro_axi_m_keep <= 4'b1000;
            default : ro_axi_m_keep <= 4'b1111;
        endcase
    else if (r_eof && r_eof_local ==4'b0100)
        case(r_sof_local)
            4'b0001 : ro_axi_m_keep <= 4'b1000;
            4'b0010 : ro_axi_m_keep <= 4'b1111;
            4'b0100 : ro_axi_m_keep <= 4'b1110;
            4'b1000 : ro_axi_m_keep <= 4'b1100;
            default : ro_axi_m_keep <= 4'b1111;
        endcase
    else if (r_eof && r_eof_local ==4'b1000)
        case(r_sof_local)
            4'b0001 : ro_axi_m_keep <= 4'b1100;
            4'b0010 : ro_axi_m_keep <= 4'b1000;
            4'b0100 : ro_axi_m_keep <= 4'b1111;
            4'b1000 : ro_axi_m_keep <= 4'b1110;
            default : ro_axi_m_keep <= 4'b1111;
        endcase
    else if (r_sof || r_pre_valid)
        ro_axi_m_keep <= 4'b1111;
    else
        ro_axi_m_keep <= 4'b0000;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_axi_m_last <= 'd0;
    else if (r_eof)
        ro_axi_m_last <= 'd1;
    else
        ro_axi_m_last <= 'd0;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_axi_m_data  <= 'd0;
        ro_axi_m_valid <= 'd0;
    end else begin
        ro_axi_m_data  <= r_pre_data;
        ro_axi_m_valid <= r_pre_valid;
    end
end





endmodule

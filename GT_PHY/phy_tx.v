`timescale 1ns/1ps

module phy_tx(
    input                   i_clk           ,
    input                   i_rst           ,
    /* ---- UserAxiPort ---- */
    input                   i_axi_s_valid   ,
    input [3:0]             i_axi_s_keep    ,
    input [31:0]            i_axi_s_data    ,
    input                   i_axi_s_last    ,   
    output                  o_axi_s_ready   ,
    /* ---- GtModulePort ---- */
    input                   i_gt_tx_done    ,
    output [31:0]           o_gt_tx_data    ,
    output [3:0]            o_gt_tx_charisk 
);

localparam                  P_COMMA_CYCLE = 500 ;

wire [31:0]                 w_fifo_dout         ;
wire                        w_fifo_full         ;
wire                        w_fifo_empty        ;
wire                        w_valid_pos         ;
wire [31:0]                 w_lfsr_value        ;
reg                         r_rst               ;
reg                         r_fifo_rden         ;
reg                         ri_axi_s_valid      ;
reg [15:0]                  r_len               ;
reg [3:0]                   ri_axi_s_keep       ;
reg [15:0]                  r_comma_cnt         ;
reg [31:0]                  ro_gt_tx_data       ;
reg [3:0]                   ro_gt_tx_charisk    ;
reg [31:0]                  r_fifo_dout         ;
reg                         r_ready             ;
reg                         ri_gt_tx_done       ;

always@(posedge i_clk)
begin
    r_rst <= i_rst;
end

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        ri_gt_tx_done <= 'd0;
    else
        ri_gt_tx_done <= 'd1;
end

assign                      w_valid_pos = !ri_axi_s_valid & i_axi_s_valid;
assign                      o_gt_tx_data    = ro_gt_tx_data   ;
assign                      o_gt_tx_charisk = ro_gt_tx_charisk;
assign                      o_axi_s_ready = r_ready && ri_gt_tx_done;


always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        ri_axi_s_valid <= 'd0;
    else
        ri_axi_s_valid <= i_axi_s_valid;
end

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        r_fifo_rden <= 'd0;
    else if (w_fifo_empty)
        r_fifo_rden <= 'd0;
    else if (ri_axi_s_valid)
        r_fifo_rden <= 'd1;
    else
        r_fifo_rden <= r_fifo_rden;
end

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        r_len <= 'd0;
    else if (w_valid_pos)
        r_len <= 'd1;
    else if (i_axi_s_valid)
        r_len <= r_len + 1;
    else
        r_len <= r_len;
end

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        ri_axi_s_keep <= 'd0;
    else if (i_axi_s_last)
        ri_axi_s_keep <= i_axi_s_keep;
    else
        ri_axi_s_keep <= ri_axi_s_keep;
end

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        r_comma_cnt <= 'd0;
    else if (r_comma_cnt == P_COMMA_CYCLE)
        r_comma_cnt <= 'd0;
    else if (r_st_current == P_ST_IDLE)
        r_comma_cnt <= r_comma_cnt + 1;
    else
        r_comma_cnt <= r_comma_cnt;
end

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        r_fifo_dout <= 'd0;
    else
        r_fifo_dout <= w_fifo_dout;
end

FIFO_Phy_tx FIFO_Phy_tx_u (
    .clk      (i_clk          ),      // input wire clk
    .din      (i_axi_s_data   ),      // input wire [31 : 0] din
    .wr_en    (i_axi_s_valid  ),  // input wire wr_en
    .rd_en    (r_fifo_rden    ),  // input wire rd_en
    .dout     (w_fifo_dout    ),    // output wire [31 : 0] dout
    .full     (w_fifo_full    ),    // output wire full
    .empty    (w_fifo_empty   )  // output wire empty
);

LFSR_Gen#(
    .P_LFSR_INIT        (16'hA076       )  
)
LFSR_Gen_u
(
    .i_clk              (i_clk          ),
    .i_rst              (r_rst          ),
    .o_lfsr_value       (w_lfsr_value   )
);

localparam                  P_ST_INIT = 0       ,
                            P_ST_IDLE = 1       ,
                            P_ST_PRE  = 2       ,
                            P_ST_FB   = 3       ,
                            P_ST_DATA1= 4       ,
                            // P_ST_DATA2= 5       ,
                            P_ST_FD1  = 5       ,
                            P_ST_FD2  = 6       ,
                            // P_ST_FD3  = 8       ,
                            // P_ST_FD4  = 9       ,
                            P_ST_COMA = 7      ;

reg [7:0]                   r_st_current        ;
reg [7:0]                   r_st_next           ;
reg [15:0]                  r_st_cnt            ;

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        r_st_current <= P_ST_INIT;
    else 
        r_st_current <= r_st_next;
end

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        r_st_cnt <= 'd0;
    else if (r_st_current != r_st_next)
        r_st_cnt <= 'd0;
    else
        r_st_cnt <= r_st_cnt + 1;
end

always@(*)
begin
    case(r_st_current)
        P_ST_INIT   : r_st_next = ri_gt_tx_done ?   P_ST_IDLE   :   P_ST_INIT   ;
        P_ST_IDLE   : r_st_next = ri_axi_s_valid?   P_ST_PRE    :   
                                  r_comma_cnt == P_COMMA_CYCLE  ?   P_ST_COMA   :
                                  P_ST_IDLE     ;
        P_ST_PRE    : r_st_next = P_ST_FB       ;
        P_ST_FB     : r_st_next = P_ST_DATA1    ;
        // r_len >= 3    ?   P_ST_DATA1  :   
        //                           ri_axi_s_keep >= 4'b1110      ?   P_ST_DATA2  :
        //                           ri_axi_s_keep == 4'b1100      ?   P_ST_FD3    :
        //                           ri_axi_s_keep == 4'b1000      ?   P_ST_FD4    :
        //                           P_ST_FB       ;
        P_ST_DATA1  : r_st_next = ri_axi_s_keep >= 4'b1110      ?   !i_axi_s_valid && r_st_cnt == r_len - 2 ?   P_ST_FD1    :
                                                                    P_ST_DATA1      :   
                                                                    !i_axi_s_valid && r_st_cnt == r_len - 3 ?   P_ST_FD2    :
                                                                    P_ST_DATA1      ;
                                //   !i_axi_s_valid && r_st_cnt == r_len - 2       ?   ri_axi_s_keep == 4'b1111    ?   P_ST_FD1    :
                                //                                                     ri_axi_s_keep == 4'b1110    ?   P_ST_FD2    :
                                //                                                     ri_axi_s_keep == 4'b1100    ?   P_ST_FD3    :
                                //                                                     ri_axi_s_keep == 4'b1000    ?   P_ST_FD4    :
                                //   P_ST_DATA1    :   P_ST_DATA1  ;
        // P_ST_DATA2  : r_st_next = ri_axi_s_keep == 4'b1111      ?   P_ST_FD1    :
        //                           ri_axi_s_keep == 4'b1110      ?   P_ST_FD2    :
        //                           P_ST_DATA2    ;
        P_ST_FD1    : r_st_next = P_ST_IDLE     ;
        P_ST_FD2    : r_st_next = P_ST_IDLE     ;
        // P_ST_FD3    : r_st_next = P_ST_IDLE     ;
        // P_ST_FD4    : r_st_next = P_ST_IDLE     ;
        P_ST_COMA   : r_st_next = ri_axi_s_valid?   P_ST_PRE    :
                                  r_st_cnt == 1 ?   P_ST_IDLE   :
                                  P_ST_COMA     ;
        default     : r_st_next = P_ST_INIT     ;
    endcase
end

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst) begin
        ro_gt_tx_data    <= 'd0;
        ro_gt_tx_charisk <= 'd0;
    end else case(r_st_current)
        P_ST_PRE    : begin ro_gt_tx_data    <= 32'h50bc50bc;
                            ro_gt_tx_charisk <= 4'b0101; end
        P_ST_FB     : begin ro_gt_tx_data    <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], 8'hFB};
                            ro_gt_tx_charisk <= 4'b0001; end
        P_ST_DATA1  : begin ro_gt_tx_data    <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};
                            ro_gt_tx_charisk <= 4'b0000; end
        // P_ST_DATA2  : begin ro_gt_tx_data    <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};
        //                     ro_gt_tx_charisk <= 4'b0000; end
        P_ST_FD1    : case(ri_axi_s_keep)
                        4'b1111 : begin ro_gt_tx_data    <= {w_lfsr_value[31:16], 8'hfd, r_fifo_dout[7:0]};
                                                             ro_gt_tx_charisk <= 4'b0010; end
                        4'b1110 : begin ro_gt_tx_data    <= {w_lfsr_value[31:8], 8'hFD};
                                                              ro_gt_tx_charisk <= 4'b0001; end
                        default : begin ro_gt_tx_data    <= {w_lfsr_value[31:8], 8'hFD};
                                                              ro_gt_tx_charisk <= 4'b0001; end
        endcase 

        P_ST_FD2    : case(ri_axi_s_keep)
                        4'b1100 : begin ro_gt_tx_data    <= {8'hFD, w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};
                            ro_gt_tx_charisk <= 4'b1000; end 
                        4'b1000 : begin ro_gt_tx_data    <= {w_lfsr_value[31:24], 8'hFD, w_fifo_dout[31:24], r_fifo_dout[7:0]};
                            ro_gt_tx_charisk <= 4'b0100; end
                        default : begin ro_gt_tx_data    <= {w_lfsr_value[31:24], 8'hFD, w_fifo_dout[31:24], r_fifo_dout[7:0]};
                            ro_gt_tx_charisk <= 4'b0100; end
        endcase
        // begin ro_gt_tx_data    <= {w_lfsr_value[31:8], 8'hFD};
        //                     ro_gt_tx_charisk <= 4'b0001; end
        // P_ST_FD3    : begin ro_gt_tx_data    <= {8'hFD, w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};
        //                     ro_gt_tx_charisk <= 4'b1000; end
        // P_ST_FD4    : begin ro_gt_tx_data    <= {w_lfsr_value[31:24], 8'hFD, w_fifo_dout[31:24], r_fifo_dout[7:0]};
        //                     ro_gt_tx_charisk <= 4'b0100; end
        P_ST_COMA   : begin ro_gt_tx_data    <= 32'h50bc50bc;
                            ro_gt_tx_charisk <= 4'b0101; end
        default     : begin ro_gt_tx_data <= w_lfsr_value;
                            ro_gt_tx_charisk <= 'd0; end
    endcase
end

always@(posedge i_clk or posedge r_rst)
begin
    if (r_rst)
        r_ready <= 'd1;
    else if (i_axi_s_last)
        r_ready <= 'd0;
    else if (r_st_current == P_ST_IDLE && r_st_next == P_ST_IDLE)
        r_ready <= 'd1;
    else
        r_ready <= r_ready;
end


endmodule

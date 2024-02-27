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

    /*
        BC50BC50 FB D0 D1 D2 D3 ... FD LFSR
    */

    localparam              P_COMMA_CYCLE = 500     ;

    reg [31:0]              ro_gt_tx_data           ;
    reg [3:0]               ro_gt_tx_charisk        ;
    // reg                     ro_axi_s_ready          ;
    reg                     r_axi_s_ready           ;
    assign                  o_gt_tx_data    = ro_gt_tx_data   ;
    assign                  o_gt_tx_charisk = ro_gt_tx_charisk;
    assign                  o_axi_s_ready = r_axi_s_ready & i_gt_tx_done;


    wire [31:0]             w_fifo_dout             ;
    reg [31:0]              r_fifo_dout             ;
    reg                     r_fifo_rden             ;
    wire                    w_fifo_full             ;
    wire                    w_fifo_empty            ;

    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst)
            r_fifo_dout <= 'd0;
        else
            r_fifo_dout <= w_fifo_dout;
    end

    reg [3:0]               ri_axi_s_keep           ;
    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst)
            ri_axi_s_keep <= 'd0;
        else if (i_axi_s_last)
            ri_axi_s_keep <= i_axi_s_keep;
        else
            ri_axi_s_keep <= ri_axi_s_keep;
    end

    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst)
            r_fifo_rden <= 'd0;
        else if (r_st_current == P_ST_IDLE && r_st_next == P_ST_PRE)
            r_fifo_rden <= 'd1;
        else if (w_fifo_empty)  
            r_fifo_rden <= 'd0;
        else
            r_fifo_rden <= r_fifo_rden;
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

    wire [31:0]             w_lfsr_value            ;

    LFSR_Gen#(
        .P_LFSR_INIT        (16'hA076       )  
    )
    LFSR_Gen_u
    (
        .i_clk              (clk            ),
        .i_rst              (rst            ),
        .o_lfsr_value       (w_lfsr_value   )
    );

    reg [7:0]               r_st_current            ;
    reg [7:0]               r_st_next               ;

    localparam              P_ST_INIT = 0           ,
                            P_ST_IDLE = 1           ,
                            P_ST_PRE  = 2           ,
                            P_ST_SOF  = 3           ,
                            P_ST_DATA = 4           ,
                            P_ST_EOF  = 5           ,
                            P_ST_EOF2 = 6           ,
                            P_ST_DATA2= 7           ,
                            P_ST_COMMA= 8           ;

    reg [15:0]              r_comma_cnt             ;
    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst)
            r_comma_cnt <= 'd0;
        else if (r_comma_cnt == P_COMMA_CYCLE)
            r_comma_cnt <= 'd0;
        else if (r_st_current == P_ST_IDLE)
            r_comma_cnt <= r_comma_cnt + 1;
        else
            r_comma_cnt <= r_comma_cnt;
    end

    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst)
            r_st_current <= P_ST_INIT;
        else
            r_st_current <= r_st_next;
    end

    always@(*)
    begin
        case(r_st_current)
            P_ST_INIT   : r_st_next <= i_gt_tx_done     ? P_ST_IDLE     : P_ST_INIT;
            P_ST_IDLE   : r_st_next <= ri_axi_s_valid   ? P_ST_PRE      :
                                        r_comma_cnt == P_COMMA_CYCLE    ? P_ST_COMMA    : P_ST_IDLE;
            P_ST_PRE    : r_st_next <= P_ST_SOF     ;
            P_ST_SOF    : r_st_next <= r_cnt == 'd2 && ri_axi_s_keep >= 4'b1110 ? P_ST_DATA2    : 
                                       r_cnt >= 3 ? P_ST_DATA : P_ST_EOF;
            P_ST_DATA   : r_st_next <= !i_axi_s_valid && r_st_cnt == r_cnt - 3  ? P_ST_EOF  : P_ST_DATA;
            P_ST_EOF    : r_st_next <= ri_axi_s_keep >= 4'b1110 ? P_ST_EOF2 : P_ST_IDLE;
            P_ST_EOF2   : r_st_next <= P_ST_IDLE;
            P_ST_DATA2  : r_st_next <= P_ST_EOF2;
            P_ST_COMMA  : r_st_next <= ri_axi_s_valid   ? P_ST_PRE  :
                                        r_st_cnt == 1   ? P_ST_IDLE : P_ST_COMMA;
            default     : r_st_next <= P_ST_INIT;
        endcase
    end

    reg                     ri_axi_s_valid          ;
    reg                     ri_axi_s_valid_1d       ;
    wire                    w_valid_pos             ;
    assign                  w_valid_pos = !ri_axi_s_valid & i_axi_s_valid;
    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst) begin
            ri_axi_s_valid <= 'd0;
            ri_axi_s_valid_1d <= 'd0;
        end else begin
            ri_axi_s_valid <= i_axi_s_valid;
            ri_axi_s_valid_1d <= ri_axi_s_valid;
        end
    end

    reg [15:0]              r_cnt                   ;
    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst)
            r_cnt <= 'd0;
        else if (w_valid_pos)
            r_cnt <= 'd1;
        else if (i_axi_s_valid)
            r_cnt <= r_cnt + 1;
        else
            r_cnt <= r_cnt;
    end

    reg [15:0]              r_st_cnt                ;
    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst)
        r_st_cnt <= 'd0; 
        else if (r_st_current != r_st_next)
            r_st_cnt <= 'd0;
        else
            r_st_cnt <= r_st_cnt + 1;
    end     

    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst) begin
            ro_gt_tx_data    <= 'd0;
            ro_gt_tx_charisk <= 'd0;
        end else if (r_st_current == P_ST_PRE) begin
            ro_gt_tx_data    <= 32'h50bc50bc;
            ro_gt_tx_charisk <= 4'b0101;
        end else if (r_st_current == P_ST_SOF) begin
            ro_gt_tx_data    <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], 8'hFB};
            ro_gt_tx_charisk <= 4'b0001;
        end else if (r_st_current == P_ST_DATA) begin
            ro_gt_tx_data    <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};
            ro_gt_tx_charisk <= 4'b0000;
        end else if (r_st_current == P_ST_EOF && ri_axi_s_keep == 4'b1000) begin
            ro_gt_tx_data    <= {w_lfsr_value[31:24], 8'hFD, w_fifo_dout[31:24], r_fifo_dout[7:0]};        // Need LFSR
            ro_gt_tx_charisk <= 4'b0100;
        end else if (r_st_current == P_ST_EOF && ri_axi_s_keep == 4'b1100) begin
            ro_gt_tx_data    <= {8'hFD, w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};
            ro_gt_tx_charisk <= 4'b1000;
        end else if (r_st_current == P_ST_EOF && ri_axi_s_keep == 4'b1110) begin
            ro_gt_tx_data    <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};
            ro_gt_tx_charisk <= 4'b0000;
        end else if (r_st_current == P_ST_EOF && ri_axi_s_keep == 4'b1111) begin
            ro_gt_tx_data    <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};
            ro_gt_tx_charisk <= 4'b0000;
        end else if (r_st_current == P_ST_EOF2 && ri_axi_s_keep == 4'b1110) begin
            ro_gt_tx_data    <= {w_lfsr_value[31:8], 8'hFD};             // Need LFSR
            ro_gt_tx_charisk <= 4'b0001;
        end else if (r_st_current == P_ST_EOF2 && ri_axi_s_keep == 4'b1111) begin
            ro_gt_tx_data <= {w_lfsr_value[31:16], 8'hfd, r_fifo_dout[7:0]};      // Need LFSR
            ro_gt_tx_charisk <= 4'b0010;
        end else if (r_st_current == P_ST_DATA2 && ri_axi_s_keep == 4'b1110) begin
            ro_gt_tx_data <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};      // Need LFSR
            ro_gt_tx_charisk <= 4'b0000;
        end else if (r_st_current == P_ST_DATA2 && ri_axi_s_keep == 4'b1111) begin
            ro_gt_tx_data <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], r_fifo_dout[7:0]};      // Need LFSR
            ro_gt_tx_charisk <= 4'b0000;
        end else if (r_st_current == P_ST_COMMA) begin
            ro_gt_tx_data    <= 32'h50bc50bc;
            ro_gt_tx_charisk <= 4'b0101;
        end else begin
            ro_gt_tx_data <= w_lfsr_value;
            ro_gt_tx_charisk <= 'd0;
        end
    end

    always@(posedge i_clk or posedge i_rst)
    begin
        if (i_rst)
            r_axi_s_ready <= 'd1;
        else if (i_axi_s_last)          
            r_axi_s_ready <= 'd0;
        else if (r_st_current == P_ST_IDLE && r_st_next == P_ST_IDLE)
            r_axi_s_ready <= 'd1;
        else
            r_axi_s_ready <= r_axi_s_ready;
    end


    endmodule

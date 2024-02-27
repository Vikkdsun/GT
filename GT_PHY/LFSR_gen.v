`timescale 1ns/1ps

module LFSR_gen#(
    parameter           P_LFSR_INIT = 16'hA076
)(
    input               i_clk                   ,
    input               i_rst                   ,
    output [31:0]       o_lfsr                  
);

reg [15:0]              r_lfsr                  ;
reg [31:0]              ro_lfsr                 ;
wire [47:0]             w_lfsr                  ;
assign                  w_lfsr[47:32] = r_lfsr  ;
assign                  o_lfsr = ro_lfsr        ;

genvar i;
generate
    for (i=0; i<32; i=i+1)
    begin
        assign  w_lfsr[31 - i] = w_lfsr[47 - i] ^ w_lfsr[46 - i] ^ w_lfsr[45 - i] ^ w_lfsr[33 - i];
    end
endgenerate

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_lfsr <= P_LFSR_INIT;
    else
        r_lfsr <= w_lfsr[15:0];
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_lfsr <= 'd0;
    else
        ro_lfsr <= w_lfsr[31:0];
end


endmodule

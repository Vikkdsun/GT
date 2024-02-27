`timescale 1ns/1ps

module rst_gen#(
    parameter           P_CYCLE = 10
)(
    input               i_clk               ,
    output              o_rst               
);

reg [15:0]              r_cnt = 'd0         ;
reg                     ro_rst = 'd1        ;
assign                  o_rst = ro_rst      ;

always@(posedge i_clk)
begin
    if (r_cnt == P_CYCLE)
        r_cnt <= r_cnt;
    else
        r_cnt <= r_cnt + 1;
end

always@(posedge i_clk)
begin
    if (r_cnt == P_CYCLE)
        ro_rst <= 'd0;
    else
        ro_rst <= ro_rst;
end


endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2023 02:13:41 PM
// Design Name: 
// Module Name: sdr_sig_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sdr_sig_tb();
    reg sys_CLK;
    reg sys_RESET;
    reg [22:0] sys_A;
    reg [3:0] iState;
    reg [3:0] cState;
    wire sdr_CKE;
    wire sdr_CSn;
    wire sdr_RASn;
    wire sdr_CASn;
    wire sdr_WEn;
    wire [1:0] sdr_BA;
    wire [11:0] sdr_A;

    parameter INHIBIT            = 4'b1111;
    parameter NOP                = 4'b0111;
    parameter ACTIVE             = 4'b0011;
    parameter READ               = 4'b0101;
    parameter WRITE              = 4'b0100;
    parameter BURST_TERMINATE    = 4'b0110;
    parameter PRECHARGE          = 4'b0010;
    parameter AUTO_REFRESH       = 4'b0001;
    parameter LOAD_MODE_REGISTER = 4'b0000;

    parameter i_NOP = 4'b0000;
    parameter i_PRE = 4'b0001;
    parameter i_AR  = 4'b0010;
    parameter i_MRS = 4'b0011;
    parameter i_ready = 4'b0100;

    parameter c_idle = 4'b0000;
    parameter c_ACTIVE = 4'b0001;
    parameter c_WRITEA = 4'b0010;
    parameter c_wdata = 4'b0011;
    parameter c_READA = 4'b0100;
    parameter c_cl = 4'b0101;
    parameter c_rdata = 4'b0110;
    parameter c_AR = 4'b0111;
    //defining clock cycle
    parameter read_cycle = 4;
    parameter write_cycle = 4;
    parameter refresh_cycle = 2;
    parameter precharge_cycle = 2;
    parameter MRS_cycle = 2;
    
    `define read_done clkCNT == read_cycle - 1
    `define write_done clkCNT == write_cycle
    `define refresh_done clkCNT == refresh_cycle
    `define precharge_done clkCNT == precharge_cycle
    `define MRS_done clkCNT == MRS_cycle
    `define cas_latency_done clkCNT == cas_latency

    sdr_sig uut(
        .sys_CLK(sys_CLK),
        .sys_RESET(sys_RESET),
        .sys_A(sys_A),
        .iState(iState),
        .cState(cState),
        .sdr_CKE(sdr_CKE),
        .sdr_CSn(sdr_CSn),
        .sdr_RASn(sdr_RASn),
        .sdr_CASn(sdr_CASn),
        .sdr_WEn(sdr_WEn),
        .sdr_BA(sdr_BA),
        .sdr_A(sdr_A)
    );  
    initial begin
        sys_CLK  = 0;
        sys_RESET = 0;
        sys_A = 11;
        iState = i_NOP;
        cState = c_idle;
    end

    initial begin
        forever begin
            #10 sys_CLK = ~sys_CLK;
        end
    end

   always @(posedge sys_CLK) begin
        if(iState == i_ready) begin
           if(cState == c_AR) begin cState = c_idle; iState = i_NOP; sys_A <= sys_A + 1; end
           else cState = cState + 1;
        end
        else begin
            cState = c_idle;
            iState = iState + 1;
        end
   end
endmodule

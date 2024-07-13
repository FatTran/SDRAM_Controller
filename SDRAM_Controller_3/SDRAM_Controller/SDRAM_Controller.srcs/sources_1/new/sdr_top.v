`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2023 05:26:22 PM
// Design Name: 
// Module Name: sdr_top
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


module sdr_top(
    input sys_R_Wn,
    input sys_ADSn,
    input sys_DLY_100us,
    input sys_CLK,
    input sys_RESET,
    input sys_REF_REQ,
    output sys_REF_ACK,
    input [22:0] sys_A,
    inout [15:0] sys_D,
    output sys_D_VALID,
    output sys_CYC_END,
    output sys_INIT_DONE,

    inout [3:0] sdr_DQ,
    output [11:0] sdr_A,
    output [1:0] sdr_BA,
    output sdr_CKE,
    output sdr_CSn,
    output sdr_RASn,
    output sdr_CASn,
    output sdr_WEn,
    output sdr_DQM
    );
    
    wire [3:0] iState;
    wire [3:0] cState;
    wire [3:0] clkCNT;

    assign sdr_DQM = 0;
    
    sdr_data U3 (
    .sys_CLK(sys_CLK),
    .sys_RESET(sys_RESET),
    .sys_D(sys_D),
    .sys_D_VALID(sys_D_VALID),
    .cState(cState),
    .clkCNT(clkCNT),
    .sdr_DQ(sdr_DQ)
    );

    sdr_ctrl U1 (
    .sys_CLK(sys_CLK),
    .sys_RESET(sys_RESET),
    .sys_R_Wn(sys_R_Wn),
    .sys_ADSn(sys_ADSn),
    .sys_DLY_100us(sys_DLY_100us),
    .sys_REF_REQ(sys_REF_REQ),
    .sys_REF_ACK(sys_REF_ACK),
    .sys_CYC_END(sys_CYC_END),
    .sys_INIT_DONE(sys_INIT_DONE),
    .iState(iState),
    .cState(cState),
    .clkCNT(clkCNT)
    );

    sdr_sig U2 (
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

    
endmodule

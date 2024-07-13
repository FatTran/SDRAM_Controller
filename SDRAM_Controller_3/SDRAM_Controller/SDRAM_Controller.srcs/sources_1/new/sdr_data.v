`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2023 05:26:22 PM
// Design Name: 
// Module Name: sdr_data
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


module sdr_data(
    input sys_CLK,
    input sys_RESET,
    inout [15:0] sys_D,
    input [3:0] cState,
    input [3:0] clkCNT,
    inout [3:0] sdr_DQ,
    output sys_D_VALID
    );
    `include "sdr_par.vh"

    //Read cycle
    
    reg [15: 0] regSdrDQ;
    reg enableSysD;

    wire [3:0] cnt0_sdrDQ;
    wire [3:0] cnt1_sdrDQ;
    wire [3:0] cnt2_sdrDQ;
    wire [3:0] cnt3_sdrDQ;
    //sys_D_VALID
    assign sys_D_VALID = enableSysD;
    
    //Read cycle datapath
    assign sys_D = (enableSysD) ? regSdrDQ : 16'hzzzz;
    
    assign cnt0_sdrDQ = ((cState == c_rdata) && (clkCNT == 0)) ? sdr_DQ : regSdrDQ[3:0];
    assign cnt1_sdrDQ = ((cState == c_rdata) && (clkCNT == 1)) ? sdr_DQ : regSdrDQ[7:4];
    assign cnt2_sdrDQ = ((cState == c_rdata) && (clkCNT == 2)) ? sdr_DQ : regSdrDQ[11:8];
    assign cnt3_sdrDQ = ((cState == c_rdata) && (clkCNT == 3)) ? sdr_DQ : regSdrDQ[15:12];

    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) begin
            regSdrDQ <= 16'h0000;
        end
        else
            regSdrDQ <= {cnt3_sdrDQ, cnt2_sdrDQ, cnt1_sdrDQ, cnt0_sdrDQ};
    end

    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) 
            enableSysD <= 0;
        else if ((cState == c_rdata) && (clkCNT == NUM_CLK_READ - 1))
            enableSysD <= 1;
        else enableSysD <= 0;
    end
    //Write cycle
    reg [15:0] regSysD;
    reg [3:0] regSysDWrite;
    reg enableSdrDQ;

    assign sdr_DQ = (enableSdrDQ) ? regSysDWrite : 4'bzzzz;

    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET)
            regSysD <= 16'h0000;
        else  
            regSysD <= sys_D; 
    end

    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET)
            regSysDWrite <= 16'h0000;
        else if((cState == c_WRITEA))
            regSysDWrite <= regSysD[3:0];
        else if((cState == c_wdata) && (clkCNT == 1))
            regSysDWrite <= regSysD[7:4];
        else if((cState == c_wdata) && (clkCNT == 2))
            regSysDWrite <= regSysD[11:8];
        else if((cState == c_wdata) && (clkCNT == 3))
            regSysDWrite <= regSysD[15:12];
    end
    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET)
            enableSdrDQ <= 0;
        else if((cState == c_WRITEA) && (clkCNT == 0))
            enableSdrDQ <= 1;
        else if ((cState == c_wdata) && (clkCNT == NUM_CLK_WRITE))
            enableSdrDQ <= 0;
    end
endmodule

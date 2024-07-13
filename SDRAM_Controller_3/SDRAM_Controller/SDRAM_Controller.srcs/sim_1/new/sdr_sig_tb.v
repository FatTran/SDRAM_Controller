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

    `include "sdr_par.vh"

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
        sys_A = 0;
        iState = i_NOP;
        cState = c_idle;
    end

    initial begin
        forever begin
            #(tCK/2) sys_CLK = ~sys_CLK;
        end
    end

   always @(posedge sys_CLK) begin
        if(iState == i_ready) begin
           if(cState == c_AR) begin cState = c_idle; iState = i_NOP; sys_A = sys_A + 512; end
           else cState = cState + 1;
        end
        else begin
            cState = c_idle;
            iState = iState + 1;
        end
   end
endmodule

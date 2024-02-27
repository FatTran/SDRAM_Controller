`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2023 02:13:41 PM
// Design Name: 
// Module Name: sdr_ctrl_tb
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


module sdr_ctrl_tb();
    reg sys_REF_REQ;
    reg sys_CLK;
    reg sys_RESET;
    reg sys_START;
    reg sys_R_Wn;
    reg sys_ADSn;
    wire sys_INIT_DONE;
    wire sys_REF_ACK;
    wire sys_CYC_END;
    wire [3:0] iState;
    wire [3:0] cState;
    wire [3:0] clkCNT;
    sdr_ctrl uut(   .sys_REF_REQ(sys_REF_REQ),
                    .sys_CLK(sys_CLK),
                    .sys_RESET(sys_RESET),
                    .sys_START(sys_START),
                    .sys_R_Wn(sys_R_Wn),
                    .sys_ADSn(sys_ADSn),
                    .sys_INIT_DONE(sys_INIT_DONE),
                    .sys_REF_ACK(sys_REF_ACK),
                    .sys_CYC_END(sys_CYC_END),
                    .iState(iState),
                    .cState(cState),
                    .clkCNT(clkCNT)                 );    
    initial begin
        sys_REF_REQ  = 0;
        sys_CLK      = 0;
        sys_RESET    = 0;
        sys_START    = 1;
        sys_R_Wn     = 0;
        sys_ADSn     = 0;
    end
    initial begin
        forever begin
            #10 sys_CLK = ~sys_CLK;
        end
    end

    initial begin
        forever begin
            #200 sys_R_Wn = ~sys_R_Wn;
        end
    end

    initial begin
        forever begin
            #30 sys_ADSn = ~sys_ADSn;
        end
    end

    initial begin
        #150 sys_START = 0;
    end
    initial begin
        #460 sys_REF_REQ = 1;
        #50 sys_REF_REQ = 0;
    end

    
endmodule

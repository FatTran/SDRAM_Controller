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
    reg sys_DLY_100us;
    reg sys_R_Wn;
    reg sys_ADSn;
    wire sys_INIT_DONE;
    wire sys_REF_ACK;
    wire sys_CYC_END;
    wire [3:0] iState;
    wire [3:0] cState;
    wire [3:0] clkCNT;
    `include "sdr_par.vh"
    sdr_ctrl uut(   .sys_REF_REQ(sys_REF_REQ),
                    .sys_CLK(sys_CLK),
                    .sys_RESET(sys_RESET),
                    .sys_DLY_100us(sys_DLY_100us),
                    .sys_R_Wn(sys_R_Wn),
                    .sys_ADSn(sys_ADSn),
                    .sys_INIT_DONE(sys_INIT_DONE),
                    .sys_REF_ACK(sys_REF_ACK),
                    .sys_CYC_END(sys_CYC_END),
                    .iState(iState),
                    .cState(cState),
                    .clkCNT(clkCNT)                 );    
    task Read;
        begin
        @(negedge sys_CLK);
        sys_RESET = 0;
        sys_REF_REQ = 0;
        sys_R_Wn = 1;
        sys_ADSn = 0;
        #tCK;
        sys_ADSn = 1;
        #tCK;
//        $stop;
        end
    endtask
    task Write;
        begin
        @(posedge sys_CYC_END);
        @(negedge sys_CLK);
        sys_RESET = 0;
        sys_REF_REQ = 0;
        sys_R_Wn = 0;
        sys_ADSn = 0;
        #tCK;
        sys_ADSn = 1;
        #tCK;
        end
    endtask
    task Refresh;
        begin
        @(posedge sys_CYC_END);
        @(negedge sys_CLK);
        sys_RESET = 0;
        sys_REF_REQ = 1;
        sys_R_Wn = 1;
        sys_ADSn = 0;
        #tCK;
        sys_ADSn = 1;
        #tCK; 
        end
    endtask
    initial begin
        sys_REF_REQ  = 0;
        sys_CLK      = 0;
        sys_RESET    = 0;
        sys_DLY_100us = 0;
        sys_R_Wn     = 0;
        sys_ADSn     = 1;
        #101;
        sys_DLY_100us = 1'b1;
        @(posedge sys_INIT_DONE);
        Read();
        Write();
        Refresh();
        //$stop;
    end
    initial begin
        forever begin
            #(tCK/2) sys_CLK = ~sys_CLK;
        end
    end



    
endmodule

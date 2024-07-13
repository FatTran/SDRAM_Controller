`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2023 02:13:41 PM
// Design Name: 
// Module Name: sdr_data_tb
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


module sdr_data_tb();
    reg sys_CLK;
    reg sys_RESET;
    wire [15:0] sys_D;
    reg [3:0] cState;
    reg [3:0] clkCNT;
    wire [3:0] sdr_DQ;
    wire sys_D_VALID;
    
    reg enable_R_Wn;
    reg [3 : 0] sdr_DQ_tb;
    reg [15 : 0] sys_D_tb;
    
    `include "sdr_par.vh"
    sdr_data uut(
        .sys_CLK(sys_CLK),
        .sys_RESET(sys_RESET),
        .sys_D(sys_D),
        .cState(cState),
        .clkCNT(clkCNT),
        .sdr_DQ(sdr_DQ),
        .sys_D_VALID(sys_D_VALID)
    );
    
    initial begin
        enable_R_Wn = 0;
        sys_CLK = 0;
        sys_RESET = 0;
        cState = c_idle;
        clkCNT = 0;
        sdr_DQ_tb = 4'b0100;
        sys_D_tb = 16'h1234;
    end
    initial begin
        forever begin
            #10 sys_CLK = ~sys_CLK;
 
        end
    end
    initial begin
        forever begin
            #(500 + tCK * (NUM_CLK_READ))  enable_R_Wn = ~enable_R_Wn;
        end
    end
    assign sdr_DQ = (enable_R_Wn) ? sdr_DQ_tb : 4'bzzzz;
    assign sys_D = (enable_R_Wn) ? 16'hzzzz : sys_D_tb;
//    initial begin
//       if(cState == c_rdata) begin
//        sys_D = 0;
//        sdr_DQ = 4'b1;
//       end
//       if(cState == c_wdata) begin
//        sys_D = 4'b1011;
//        sdr_DQ = 0;
//       end
//    end
    always @(posedge sys_CLK) begin
            case(cState)
                    c_idle: begin
                        clkCNT <= 0;
                        cState <= c_ACTIVE;
                    end
                    c_ACTIVE: begin
                        clkCNT <= 0;
                        if(enable_R_Wn) 
                            cState <= (NUM_CLK_tRCD == 0) ? c_tRCD : c_READA; 
                        else cState <= (NUM_CLK_tRCD == 0) ? c_tRCD : c_WRITEA;
                    end
                    c_tRCD: begin
                        if(`endof_tRCD) begin
                            clkCNT <= 0;
                            cState <= (enable_R_Wn == 0) ? c_WRITEA : c_READA; 
                        end
                        else clkCNT <= 0;
                    end
                    c_READA: begin
                        clkCNT <= 0;
                        cState <= c_cl;
                    end
                    c_WRITEA: begin
                        clkCNT <= 0;
                        cState <= c_wdata;
                    end
                    c_AR: begin
                        clkCNT <= 0;
                        cState <= (NUM_CLK_tRFC == 0) ? c_idle : c_tRFC;
                    end
                    c_tRFC:
                        if(`endof_tRFC) begin
                            clkCNT <= 0;
                            cState <= c_idle;
                        end
                        else clkCNT <= clkCNT + 1;
                    c_rdata:
                        if(`endof_READ_burst) begin 
                        clkCNT <= 0;
                        cState <= c_idle;
                        end
                        else clkCNT <= clkCNT + 1;
                    c_wdata:
                        if(`endof_WRITE_burst) begin 
                            clkCNT <= 0;
                            cState <= c_tDAL;
                        end
                        else clkCNT <= clkCNT + 1;
                    c_tDAL:
                        if(`endof_tDAL) begin
                            clkCNT <= 0;
                            cState <= c_idle;
                        end
                        else clkCNT <= clkCNT + 1;
                    c_cl:
                        if(`endof_CAS_latency) begin 
                        clkCNT <= 0;
                        cState <= cState + 1;
                        end
                        else clkCNT <= clkCNT + 1;
                    default: 
                        cState <= c_idle;
                endcase
        end  
endmodule

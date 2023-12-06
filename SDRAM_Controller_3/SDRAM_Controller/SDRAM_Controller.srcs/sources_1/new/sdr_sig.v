`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2023 05:26:22 PM
// Design Name: 
// Module Name: sdr_sig
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


module sdr_sig(
    input sys_CLK,
    input sys_RESET,
    input [22:0] sys_A,
    input [3:0] iState,
    input [3:0] cState,
    output reg sdr_CKE,
    output reg sdr_CSn,
    output reg sdr_RASn,
    output reg sdr_CASn,
    output reg sdr_WEn,
    output reg [1:0] sdr_BA,
    output reg [11:0] sdr_A
    );  
    
    // SDRAM commands (sdr_CSn, sdr_RASn, sdr_CASn, sdr_WEn)
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
    parameter c_rdata = 4'b0001;
    parameter c_wdata = 4'b0010;
    parameter c_ACTIVE = 4'b0011;
    parameter c_READA = 4'b0100;
    parameter c_WRITEA = 4'b0101;
    parameter c_AR = 4'b0110;
    parameter c_cl = 4'b0111;
    //defining clock cycle
    parameter read_cycle = 4;
    parameter write_cycle = 4;
    parameter refresh_cycle = 2;
    parameter precharge_cycle = 2;
    parameter MRS_cycle = 2;
    
      
    `define read_done clkCNT == read_cycle
    `define write_done clkCNT == write_cycle
    `define refresh_done clkCNT == refresh_cycle
    `define precharge_done clkCNT == precharge_cycle
    `define MRS_done clkCNT == MRS_cycle
    
    `define sdr_COMMAND {sdr_CSn, sdr_RASn, sdr_CASn, sdr_WEn}

    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) begin
            `sdr_COMMAND <= INHIBIT; 
            sdr_CKE <= 0;
            sdr_BA <= 2'b11;
            sdr_A <= 12'b1;           
        end
        else
            case(iState)
                i_NOP: begin
                    `sdr_COMMAND <= NOP;
                    sdr_CKE <= 1'b1;
                    sdr_BA <= 2'b11;
                    sdr_A <= 12'b1;
                end
                i_PRE: begin
                    `sdr_COMMAND <= PRECHARGE;
                    sdr_CKE <= 1'b1;
                    sdr_BA <= 2'b11;
                    sdr_A <= 12'b1;
                end
                i_AR: begin
                    `sdr_COMMAND <= AUTO_REFRESH;
                    sdr_CKE <= 1'b1;
                    sdr_BA <= 2'b1;
                    sdr_A <= 12'b1;
                end
                i_MRS: begin
                    `sdr_COMMAND <= LOAD_MODE_REGISTER;
                    sdr_CKE <= 1'b1;
                    sdr_BA <= 2'b0;
                    sdr_A <= {2'b00, 1'b0, 2'b00, 3'b011, 1'b0, 3'b010};
                end
                i_ready: begin
                    case(cState)
                        c_idle, c_cl, c_rdata, c_wdata: begin
                            `sdr_COMMAND <= NOP;
                            sdr_BA <= 2'b1;
                            sdr_A <= 12'b1;
                        end 
                        c_ACTIVE: begin
                            `sdr_COMMAND <= ACTIVE;
                            sdr_CKE <= 1'b1;
                            sdr_BA <= sys_A[10:9];
                            sdr_A <= sys_A[22:11];
                        end
                        c_READA: begin
                            `sdr_COMMAND <= READ;
                            sdr_CKE <= 1'b1;
                            sdr_BA <= sys_A [10:9];
                            sdr_A <= {sys_A[8], 1'b1, sys_A[7:0], 2'b00};
                        end
                        c_WRITEA: begin
                            `sdr_COMMAND <= WRITE;
                            sdr_CKE <= 1'b1;
                            sdr_BA <= sys_A [10:9];
                            sdr_A <= {sys_A[8], 1'b1, sys_A[7:0], 2'b00};
                        end
                        c_AR: begin
                            `sdr_COMMAND <= AUTO_REFRESH;
                            sdr_CKE <= 1'b1;
                            sdr_BA <= 2'b1;
                            sdr_A <= 12'b1;
                        end
                        default: begin
                            `sdr_COMMAND <= NOP;
                            sdr_CKE <= 1'b1;
                            sdr_BA <= 2'b1;
                            sdr_A <= 12'b1;
                        end
                    endcase 
                end
                default: begin
                        `sdr_COMMAND <= NOP;
                        sdr_CKE <= 1'b1;
                        sdr_BA  <= 2'b1;
                        sdr_A   <= 12'b1;
                    end
            endcase
    end
endmodule

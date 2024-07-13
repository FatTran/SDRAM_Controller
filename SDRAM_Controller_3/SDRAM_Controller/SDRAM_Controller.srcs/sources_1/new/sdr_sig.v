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
`define sdr_COMMAND {sdr_CSn, sdr_RASn, sdr_CASn, sdr_WEn}
module sdr_sig(
    input sys_CLK,
    input sys_RESET,
    input [22:0] sys_A,
    input [3:0] iState,
    input [3:0] cState,
    output reg sdr_CKE,
    output reg sdr_CSn, //chip select
    output reg sdr_RASn, //row address strobe
    output reg sdr_CASn, //collumn address strobe
    output reg sdr_WEn, //write enable 
    output reg [1:0] sdr_BA, //Bank address (4 banks)
    output reg [11:0] sdr_A //sdram address
    );  
    `include "sdr_par.vh"
    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) begin
            `sdr_COMMAND <= INHIBIT; 
            sdr_CKE <= 0;
            sdr_BA <= {SDR_BA_width{1'b1}};
            sdr_A <= {SDR_A_width{1'b1}};           
        end
        else
            case(iState)
                i_NOP, i_tRP, i_tRFC1, i_tRFC2, i_tMRD: 
                begin
                    `sdr_COMMAND <= NOP;
                    sdr_CKE <= 1'b1;
                    sdr_BA <= {SDR_BA_width{1'b1}};
                    sdr_A <= {SDR_A_width{1'b1}};
                end
                i_PRE: begin
                    `sdr_COMMAND <= PRECHARGE;
                    sdr_CKE <= 1'b1;
                    sdr_BA <= {SDR_BA_width{1'b1}};
                    sdr_A <= {SDR_A_width{1'b1}};
                end
                i_AR1, i_AR2: begin
                    `sdr_COMMAND <= AUTO_REFRESH;
                    sdr_CKE <= 1'b1;
                    sdr_BA <= {SDR_BA_width{1'b1}};
                    sdr_A <= {SDR_A_width{1'b1}};
                end
                i_MRS: begin
                    `sdr_COMMAND <= LOAD_MODE_REGISTER;
                    sdr_CKE <= 1'b1;
                    sdr_BA <= {SDR_BA_width{1'b0}}; 
                    sdr_A <= {  2'b00,  //reserved    
                                MR_Write_Burst_Mode, // MR_Write_Burst_Mode programmed length
                                MR_Operation_Mode, //MR_Operation_Mode standard
                                MR_CAS_Latency, //MR_CAS_Latency latency 3
                                MR_Burst_Type, //MR_Burst_Type sequential
                                MR_Burst_Length};//MR_Burst_Length length 4
                end
                i_ready: begin
                    case(cState)
                        c_idle, c_cl, c_tRCD, c_tRFC, c_rdata, c_wdata: begin
                            `sdr_COMMAND <= NOP;
                            sdr_CKE <= 1'b1;
                            sdr_BA <= {SDR_BA_width{1'b1}};
                            sdr_A <= {SDR_A_width{1'b1}};
                        end 
                        c_ACTIVE: begin
                            `sdr_COMMAND <= ACTIVE; //open row
                            sdr_CKE <= 1'b1;
                            sdr_BA <= sys_A[BA_MSB:BA_LSB];
                            sdr_A <= sys_A[RA_MSB:RA_LSB];
                        end
                        c_READA: begin
                            `sdr_COMMAND <= READ; //open collumn
                            sdr_CKE <= 1'b1;
                            sdr_BA <= sys_A [BA_MSB:BA_LSB];
                            sdr_A <= {  sys_A[CA_MSB], //collumn
                                        1'b1, // enable auto precharge
                                        sys_A[CA_MSB - 1 : CA_LSB], //collumn
                                        2'b00}; // burst length 4
                        end
                        c_WRITEA: begin
                            `sdr_COMMAND <= WRITE;
                            sdr_CKE <= 1'b1;
                            sdr_BA <= sys_A [BA_MSB:BA_LSB];
                            sdr_A <= {  sys_A[CA_MSB], //collumn
                                        1'b1, // enable auto precharge
                                        sys_A[CA_MSB - 1 : CA_LSB], //collumn
                                        2'b00}; // burst length 4
                        end
                        c_AR: begin
                            `sdr_COMMAND <= AUTO_REFRESH; // auto refresh
                            sdr_CKE <= 1'b1;
                            sdr_BA <= {SDR_BA_width{1'b1}};
                            sdr_A <= {SDR_A_width{1'b1}};
                        end
                        default: begin
                            `sdr_COMMAND <= NOP;
                            sdr_CKE <= 1'b1;
                            sdr_BA <= {SDR_BA_width{1'b1}};
                            sdr_A <= {SDR_A_width{1'b1}};
                        end
                    endcase 
                end
                default: begin
                        `sdr_COMMAND <= NOP;
                        sdr_CKE <= 1'b1;
                        sdr_BA  <= {SDR_BA_width{1'b1}};
                        sdr_A   <= {SDR_A_width{1'b1}};
                    end
            endcase
    end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2023 05:26:22 PM
// Design Name: 
// Module Name: sdr_ctrl
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


module sdr_ctrl(
    input sys_REF_REQ,
    input sys_CLK,
    input sys_RESET,
    input sys_START,
    input sys_R_Wn,
    input sys_ADSn,
    output reg sys_INIT_DONE,
    output reg sys_REF_ACK,
    output reg sys_CYC_END,
    output reg [3:0] iState,
    output reg [3:0] cState,
    output reg [3:0] clkCNT
    ); 
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
    parameter cas_latency = 3;
    
      //burst length = 4
    `define read_done clkCNT == read_cycle - 1
    `define write_done clkCNT == write_cycle
    `define refresh_done clkCNT == refresh_cycle
    `define precharge_done clkCNT == precharge_cycle
    `define MRS_done clkCNT == MRS_cycle
    `define cas_latency_done clkCNT == cas_latency

    reg reset_CLK;
    //INIT_FSM
    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) begin
            iState <= i_NOP;
        end
        else begin
            case(iState)
                i_NOP: 
                    if(sys_START) iState <= i_PRE;
                    else iState <= i_NOP;
                i_PRE: 
                    if(`precharge_done) iState <= i_AR;
                    else iState <= i_PRE;
                i_AR: 
                    if(`refresh_done) iState <= i_MRS;
                    else iState <= i_AR;
                i_MRS: 
                    if(`MRS_done) iState <= i_ready;
                    else iState <= i_MRS;
                i_ready: iState <= i_ready;
                default: iState <= i_NOP;
            endcase
        end
    end

    //CMD_FSM
    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) begin
            cState <= c_idle;
        end
        else begin
            case(cState)
                c_idle: 
                    if(sys_REF_REQ && sys_INIT_DONE) cState <= c_AR;
                    else if(!sys_ADSn && sys_INIT_DONE) cState <= c_ACTIVE;
                c_ACTIVE:
                    if(sys_R_Wn) cState <= c_READA;
                    else cState <= c_WRITEA;
                c_READA:
                    cState <= c_cl;
                c_WRITEA:
                    cState <= c_wdata;
                c_rdata:
                    if(`read_done) cState <= c_idle;
                    else cState <= c_rdata;
                c_wdata:
                    if(`write_done) cState <= c_idle;
                    else cState <= c_wdata;
                c_AR:
                    if(`refresh_done) cState <= c_idle;
                    else cState <= c_AR;
                c_cl:
                    if(`cas_latency_done) cState <= c_rdata;
                    else cState <= c_cl;
                default:
                    cState <= c_idle;
            endcase
        end
    end

    ///sys_CYC_END

    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) begin
            sys_CYC_END <= 1;
        end
        else begin
           case(cState)
            c_idle:
                if(sys_REF_REQ && sys_INIT_DONE) sys_CYC_END <= 1;
                else if(!sys_ADSn && sys_INIT_DONE) sys_CYC_END <= 0;
                else sys_CYC_END <= 1;
            c_ACTIVE, c_READA, c_WRITEA, c_cl:
                sys_CYC_END <= 0;
            c_rdata: 
                if(`read_done) sys_CYC_END <= 1;
                else sys_CYC_END <= 0;
            c_wdata:
                if(`write_done) sys_CYC_END <= 1;
                else sys_CYC_END <= 0;
            default: 
                sys_CYC_END <= 1;
           endcase 
        end
    end

    //sys_REF_ACK

    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) begin
            sys_REF_ACK <= 0;
        end
        else
        begin
            case(cState)
                c_idle:
                    if(sys_REF_REQ && sys_INIT_DONE) sys_REF_ACK <= 1;
                    else sys_REF_ACK <= 0;
                c_AR:
                    if(`refresh_done) sys_REF_ACK <= 0;
                    else sys_REF_ACK <= 1;
                default:   
                    sys_REF_ACK <= 0;
            endcase
        end
    end

    //sys_INIT_DONE

    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) sys_INIT_DONE <= 0;
        else begin
            case(iState)
                i_ready: sys_INIT_DONE <= 1;
                default: sys_INIT_DONE <= 0;
            endcase
        end
    end

    //clkCNT

    always @(posedge sys_CLK) begin
        if(reset_CLK) clkCNT <= 0;
        else clkCNT <= clkCNT + 1;
    end

    //resetCLKCNT
    
    always @(iState or cState or clkCNT) begin
        case(iState)
            i_NOP: 
                reset_CLK = 1;
            i_PRE:
                if(`precharge_done) reset_CLK = 1;
                else reset_CLK = 0;
            i_AR:
                if(`refresh_done) reset_CLK = 1;
                else reset_CLK = 0;
            i_MRS:
                if(`MRS_done) reset_CLK = 1;
                else reset_CLK = 0;
            i_ready:
                case(cState)
                    c_idle: 
                        reset_CLK <= 1;
                    c_AR:
                        if(`refresh_done) reset_CLK <= 1;
                        else reset_CLK <= 0;
                    c_rdata:
                        if(`read_done) reset_CLK <= 1;
                        else reset_CLK <= 0;
                    c_wdata:
                        if(`write_done) reset_CLK <= 1;
                        else reset_CLK <= 0;
                    c_cl:
                        if(`cas_latency_done) reset_CLK <= 1;
                        else reset_CLK <= 0;
                    default: reset_CLK <= 1;
                endcase
             default: reset_CLK <= 0;
        endcase
    end
endmodule

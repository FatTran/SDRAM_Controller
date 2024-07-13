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
    input sys_DLY_100us,
    input sys_R_Wn,
    input sys_ADSn,
    output reg sys_INIT_DONE,
    output reg sys_REF_ACK,
    output reg sys_CYC_END,
    output reg [3:0] iState,
    output reg [3:0] cState,
    output reg [3:0] clkCNT
    ); 
    `include "sdr_par.vh"
    reg reset_CLK;
    //INIT_FSM
    always @(posedge sys_CLK or posedge sys_RESET) begin
        if(sys_RESET) begin
            iState <= i_NOP;
        end
        else begin
            case(iState)
                i_NOP: 
                    if(sys_DLY_100us) iState <= i_PRE;
                i_PRE: 
                    iState <= (NUM_CLK_tRP == 0) ? i_AR1 : i_tRP;
                i_tRP:
                    if(`endof_tRP) iState <= i_AR1;
                i_AR1: 
                    iState <= (NUM_CLK_tRFC == 0) ? i_AR2 : i_tRFC1;
                i_tRFC1:
                    if(`endof_tRFC) iState <= i_AR2;
                i_AR2:
                    iState <= (NUM_CLK_tRFC == 0) ? i_MRS : i_tRFC2;
                i_tRFC2:
                    if(`endof_tRFC) iState <= i_MRS;
                i_MRS: 
                    iState <= (NUM_CLK_tMRD == 0) ? i_ready : i_tMRD;
                i_tMRD:
                    if(`endof_tMRD) iState <= i_ready;
                i_ready: 
                    iState <= i_ready;
                default: 
                    iState <= i_NOP;
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
                    if(NUM_CLK_tRCD == 0 ) 
                        cState <= (sys_R_Wn) ? c_READA : c_WRITEA;
                    else cState <= c_tRCD;
                c_tRCD:
                    if(`endof_tRCD) 
                        cState <= (sys_R_Wn) ? c_READA : c_WRITEA;
                c_READA:
                    cState <= c_cl;
                c_rdata:
                    if(`endof_READ_burst) cState <= c_idle;
                c_cl:
                    if(`endof_CAS_latency) cState <= c_rdata;
                c_WRITEA:
                    cState <= c_wdata;
                c_wdata:
                    if(`endof_WRITE_burst) cState <= c_tDAL;
                c_tDAL:
                    if(`endof_tDAL) cState <= c_idle;
                c_AR:
                    cState <= (NUM_CLK_tRFC == 0) ? c_idle : c_tRFC;
                c_tRFC:
                    if(`endof_tRFC) cState <= c_idle;
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
            c_ACTIVE, c_READA, c_WRITEA, c_cl, c_wdata, c_tRCD:
                sys_CYC_END <= 0;
            c_rdata: 
                sys_CYC_END <= (`endof_READ_burst) ? 1 : 0;
            c_tDAL:
                sys_CYC_END <= (`endof_tDAL) ? 1 : 0;
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
                    if(NUM_CLK_tRFC == 0) sys_REF_ACK <= 0;
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
                reset_CLK <= 1;
            i_PRE:
                reset_CLK <= (NUM_CLK_tRP == 0) ? 1 : 0;
            i_AR1, i_AR2:
                reset_CLK <= (NUM_CLK_tRFC == 0) ? 1 : 0;
            i_tRP:
                reset_CLK <= (`endof_tRP) ? 1 : 0;
            i_tRFC1, i_tRFC2:
                reset_CLK <= (`endof_tRFC) ? 1 : 0;
            i_tMRD:
                reset_CLK <= (`endof_tMRD) ? 1 : 0;
            i_ready:
                case(cState)
                    c_idle:
                        reset_CLK <= 1;
                    c_ACTIVE:
                        reset_CLK <= (NUM_CLK_tRCD == 0) ? 1 : 0;
                    c_cl:
                        reset_CLK <= (`endof_CAS_latency) ? 1 : 0;
                    c_rdata:
                        reset_CLK <= (clkCNT == NUM_CLK_READ) ? 1 : 0;
                    c_wdata:
                        reset_CLK <= (`endof_WRITE_burst) ? 1 : 0;
//                    c_tDAL:
//                        reset_CLK <= (`endof_tDAL) ? 1 : 0;
                    c_tRCD:
                        reset_CLK <= (`endof_tRCD) ? 1 : 0;
                    c_tRFC:
                        reset_CLK <= (`endof_tRFC) ? 1 : 0;                    
                    default: 
                        reset_CLK <= 0;
                endcase
             default: 
             reset_CLK <= 0;
        endcase
    end
endmodule

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
        parameter c_idle = 4'b0000;
        parameter c_ACTIVE = 4'b0001;
        parameter c_WRITEA = 4'b0010;
        parameter c_wdata = 4'b0011;
        parameter c_READA = 4'b0100;
        parameter c_cl = 4'b0101;
        parameter c_rdata = 4'b0110;
        parameter c_AR = 4'b0111;

        parameter read_cycle = 4;
        parameter write_cycle = 4;
        parameter refresh_cycle = 2;
        parameter precharge_cycle = 2;
        parameter MRS_cycle = 2;
        parameter cas_latency = 3;
    sdr_data uut(
        .sys_CLK(sys_CLK),
        .sys_RESET(sys_RESET),
        .sys_D(sys_D),
        .cState(cState),
        .clkCNT(clkCNT),
        .sdr_DQ(sdr_DQ),
        .sys_D_VALID(sys_D_VALID)
    );
    
    assign sdr_DQ = 4'b0100;
    initial begin
        sys_CLK = 0;
        sys_RESET = 0;
        cState = c_idle;
        clkCNT = 0;
    end

    initial begin
        forever begin
            #10 sys_CLK = ~sys_CLK;
        end
    end
    
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
            if(cState == c_AR) cState <= c_idle;
            case(cState)
                    c_idle: begin
                        clkCNT <= 0;
                        cState <= cState + 1;
                    end
                    c_AR:
                        if(`refresh_done) begin 
                        clkCNT <= 0;
                        cState <= cState + 1;
                        end
                        else clkCNT <= clkCNT + 1;
                    c_rdata:
                        if(`read_done) begin 
                        clkCNT <= 0;
                        cState <= cState + 1;
                        end
                        else clkCNT <= clkCNT + 1;
                    c_wdata:
                        if(`write_done) begin 
                        clkCNT <= 0;
                        cState <= cState + 1;
                        end
                        else clkCNT <= clkCNT + 1;
                    c_cl:
                        if(`cas_latency_done) begin 
                        clkCNT <= 0;
                        cState <= cState + 1;
                        end
                        else clkCNT <= clkCNT + 1;
                    default: 
                        cState <= cState + 1;
                endcase
        end  
endmodule

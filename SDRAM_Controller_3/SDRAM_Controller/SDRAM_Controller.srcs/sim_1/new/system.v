`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2024 08:12:27 PM
// Design Name: 
// Module Name: system
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


module system(
  sys_CLK,
  sys_RESET,
  sys_A,
  sys_ADSn,
  sys_R_Wn,
  sys_D,
  sys_DLY_100us,
  sys_REF_REQ,
  sys_CYC_END,
  sys_INIT_DONE
);

//`include "../../../Source/Verilog/sdr_par.v"
`include "sdr_par.vh"
//---------------------------------------------------------------------
// outputs & registers
//
output        sys_CLK;
output        sys_RESET;
output [23:1] sys_A;
output        sys_ADSn;
output        sys_R_Wn;
output [15:0] sys_D;
output        sys_DLY_100us;
output        sys_REF_REQ;

input         sys_CYC_END;
input         sys_INIT_DONE;

wire           sys_CLK;
reg           sys_CLK_int;
reg           sys_CLK_en;
reg           sys_RESET;
reg [23:1]    sys_A;
reg           sys_ADSn;
reg           sys_R_Wn;
reg [15:0]    sys_D;
reg           sys_DLY_100us;
reg           sys_REF_REQ;

wire          sys_CYC_END;

//---------------------------------------------------------------------
// parameters -- change to whatever you like
//
parameter clock_time = 100;
parameter reset_time = 1000;

parameter sys_CLK_period = tCK;

//---------------------------------------------------------------------
// tasks
//
task write;
    input [23:1] addr;
    input [15:0] data;
  begin
    sys_A = addr;
    sys_ADSn = 0;
    sys_R_Wn = 0;
    #sys_CLK_period;
    sys_ADSn = 1;
    sys_D = data;
    #(sys_CLK_period * (NUM_CLK_WRITE + NUM_CLK_WAIT + 4));
    sys_D = 16'hzzzz;
    sys_R_Wn = 1;
    sys_A = 24'hzzzzzz;
  end
endtask

task read;
    input [23:1] addr;
  begin
    sys_A = addr;
    sys_ADSn = 0;
    sys_R_Wn = 1;
    #sys_CLK_period;
    sys_ADSn = 1;
    #(sys_CLK_period * (NUM_CLK_CL + NUM_CLK_READ + 3));
    sys_R_Wn = 1;
    sys_A = 24'hzzzzzz;
  end
endtask

//---------------------------------------------------------------------
// code
//
initial begin
    
    sys_R_Wn    <=  1'b1;
    sys_ADSn    <=  1'b1;
    sys_DLY_100us   <=  1'b0;
    sys_REF_REQ <=  1'b0;
    sys_CLK_int <=  1'b0;
    sys_RESET   <=  1'b1;
    sys_A       <=  24'hFFFFFF;
    sys_D       <=  16'hzzzz;
    sys_CLK_en  <=  1'b0;
    #clock_time;
    sys_CLK_en  <=  1'b1;
    #reset_time;
    @(posedge sys_CLK);
    $display($time,"ns : Coming Out Of Reset");
    sys_RESET    <=  1'b0;
    #100001;
    sys_DLY_100us    <=  1'b1;
    @(posedge sys_INIT_DONE);
    #500;
    @(negedge sys_CLK);
    write(23'h000000, 16'h1234);
    write(23'h000200, 16'h5678);
    write(23'h000400, 16'h9ABC);
    write(23'h000600, 16'hDEF0);
    read(23'h000000);
    read(23'h000200);
    read(23'h000400);
    read(23'h000600);
   // $stop;
end

always
    #(sys_CLK_period/2) sys_CLK_int <= ~sys_CLK_int;

assign sys_CLK = sys_CLK_en & sys_CLK_int;

endmodule

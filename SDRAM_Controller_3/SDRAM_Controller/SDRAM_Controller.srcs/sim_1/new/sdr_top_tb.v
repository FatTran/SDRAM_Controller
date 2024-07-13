`timescale 1ns / 1ps

module sdr_tb;

wire sys_R_Wn;      // read/write#
wire sys_ADSn;      // address strobe
wire sys_DLY_100us; // sdr power and clock stable for 100 us
wire sys_CLK;       // sdr clock
wire sys_RESET;     // reset signal
wire sys_REF_REQ;   // sdr auto-refresh request
wire sys_REF_ACK;   // sdr auto-refresh acknowledge
wire [22:0] sys_A;  // address bus
wire [15:0] sys_D;  // data bus
wire sys_D_VALID;   // data valid
wire sys_CYC_END;   // end of current cycle
wire sys_INIT_DONE; // initialization completed, ready for normal operation

wire [3:0] sdr_DQ;  // sdr data
wire [11:0] sdr_A;  // sdr address
wire [1:0] sdr_BA;  // sdr bank address
wire sdr_CKE;       // sdr clock enable
wire sdr_CSn;       // sdr chip select
wire sdr_RASn;      // sdr row address
wire sdr_CASn;      // sdr column select
wire sdr_WEn;       // sdr write enable
wire sdr_DQM;       // sdr write data mask

//---------------------------------------------------------------------
// modules

sdr_top UUT(
  .sys_R_Wn(sys_R_Wn),      // read/write#
  .sys_ADSn(sys_ADSn),      // address strobe
  .sys_DLY_100us(sys_DLY_100us), // sdr power and clock stable for 100 us
  .sys_CLK(sys_CLK),       // sdr clock
  .sys_RESET(sys_RESET),     // reset signal
  .sys_REF_REQ(sys_REF_REQ),   // sdr auto-refresh request
  .sys_REF_ACK(sys_REF_ACK),   // sdr auto-refresh acknowledge
  .sys_A(sys_A),         // address bus
  .sys_D(sys_D),         // data bus
  .sys_D_VALID(sys_D_VALID),   // data valid
  .sys_CYC_END(sys_CYC_END),   // end of current cycle
  .sys_INIT_DONE(sys_INIT_DONE), // initialization completed, ready for normal operation

  .sdr_DQ(sdr_DQ),        // sdr data
  .sdr_A(sdr_A),         // sdr address
  .sdr_BA(sdr_BA),        // sdr bank address
  .sdr_CKE(sdr_CKE),       // sdr clock enable
  .sdr_CSn(sdr_CSn),       // sdr chip select
  .sdr_RASn(sdr_RASn),      // sdr row address
  .sdr_CASn(sdr_CASn),      // sdr column select
  .sdr_WEn(sdr_WEn),       // sdr write enable
  .sdr_DQM(sdr_DQM)        // sdr write data mask
);

system STIMULUS(
  .sys_CLK(sys_CLK),
  .sys_RESET(sys_RESET),
  .sys_A(sys_A),
  .sys_ADSn(sys_ADSn),
  .sys_R_Wn(sys_R_Wn),
  .sys_D(sys_D),
  .sys_DLY_100us(sys_DLY_100us),
  .sys_REF_REQ(sys_REF_REQ),
  .sys_CYC_END(sys_CYC_END),
  .sys_INIT_DONE(sys_INIT_DONE)
);

// Module "mt48lc32m4a2" can be downloaded from Micro's web site.

//mt48lc32m4a2 SDR_SDRAM(
sdr SDR_SDRAM(
  sdr_DQ,
  sdr_A,
  sdr_BA,
  sys_CLK,
  sdr_CKE,
  sdr_CSn,
  sdr_RASn,
  sdr_CASn,
  sdr_WEn,
  sdr_DQM
);
endmodule








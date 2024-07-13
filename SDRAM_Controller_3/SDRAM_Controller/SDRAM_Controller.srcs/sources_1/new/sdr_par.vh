//Delay time before power up
parameter tDLY = 2; //Delay for simulation

//Defining operation mode
//Burst length
parameter length_1 = 3'b000;
parameter length_2 = 3'b001;
parameter length_4 = 3'b010;
parameter length_8 = 3'b011;

//Normal operation mode
parameter Standard = 2'b00;

//Write burst mode
parameter Programmed_Length = 1'b0;
parameter Single_Access = 1'b1;

//CAS latency
parameter latency_2 = 3'b010;
parameter latency_3 = 3'b011;

//Burst type
parameter Sequential = 1'b0;
parameter Interleave = 1'b1;

//System address line setting
parameter RA_MSB = 22;
parameter RA_LSB = 11;

parameter CA_MSB = 8;
parameter CA_LSB = 0;

parameter BA_MSB = 10;
parameter BA_LSB = 9;

//Address width
parameter SDR_BA_width = 2;
parameter SDR_A_width = 12;

//defining timing constraints
parameter tCK = 20;
parameter tMRD = 2 * tCK;
parameter tRP = 20;
parameter tRFC = 66;
parameter tRCD = 15;
parameter tWR = tCK + 7;
parameter tDAL = tWR + tRP;



//Mode register setting
parameter MR_Burst_Length = length_4;
parameter MR_Operation_Mode = Standard;
parameter MR_CAS_Latency = latency_3;
parameter MR_Burst_Type = Sequential;
parameter MR_Write_Burst_Mode = Programmed_Length;

//Defining clock cycles
parameter NUM_CLK_tMRD = tMRD / tCK;
parameter NUM_CLK_tRP = tRP / tCK;
parameter NUM_CLK_tRFC = tRFC / tCK;
parameter NUM_CLK_tWR = tWR / tCK;
parameter NUM_CLK_tDAL = tDAL / tCK;
parameter NUM_CLK_tRCD = tRCD / tCK;

parameter NUM_CLK_WAIT = 0;

parameter NUM_CLK_CL = 3;
parameter NUM_CLK_READ = 4;
parameter NUM_CLK_WRITE = 4;
//Defining clock cycle
parameter read_cycle = 4;
parameter write_cycle = 4;
parameter refresh_cycle = 2;
parameter precharge_cycle = 2;
parameter MRS_cycle = 2;
parameter cas_latency = 3;

`define endof_tRP clkCNT == NUM_CLK_tRP
`define endof_tMRD clkCNT == NUM_CLK_tMRD
`define endof_tRFC clkCNT == NUM_CLK_tRFC
`define endof_tRCD clkCNT == NUM_CLK_tRCD
`define endof_tDAL clkCNT == NUM_CLK_WAIT
`define endof_tWR clkCNT == NUM_CLK_tWR
`define endof_CAS_latency clkCNT == NUM_CLK_CL
`define endof_READ_burst clkCNT == (NUM_CLK_READ - 1)
`define endof_WRITE_burst clkCNT == NUM_CLK_WRITE
  //burst length = 4

parameter INHIBIT            = 4'b1111;
parameter NOP                = 4'b0111;
parameter ACTIVE             = 4'b0011;
parameter READ               = 4'b0101;
parameter WRITE              = 4'b0100;
parameter BURST_TERMINATE    = 4'b0110;
parameter PRECHARGE          = 4'b0010;
parameter AUTO_REFRESH       = 4'b0001;
parameter LOAD_MODE_REGISTER = 4'b0000;

parameter i_NOP   = 4'b0000;
parameter i_PRE   = 4'b0001;
parameter i_tRP   = 4'b0010;
parameter i_AR1   = 4'b0011;
parameter i_tRFC1 = 4'b0100;
parameter i_AR2   = 4'b0101;
parameter i_tRFC2 = 4'b0110;
parameter i_MRS   = 4'b0111;
parameter i_tMRD  = 4'b1000;
parameter i_ready = 4'b1001;

parameter c_idle   = 4'b0000;
parameter c_tRCD   = 4'b0001;
parameter c_cl     = 4'b0010;
parameter c_rdata  = 4'b0011;
parameter c_wdata  = 4'b0100;
parameter c_tRFC   = 4'b0101;
parameter c_tDAL   = 4'b0110;
parameter c_ACTIVE = 4'b0111;
parameter c_READA  = 4'b1000;
parameter c_WRITEA = 4'b1001;
parameter c_AR     = 4'b1010;
`timescale 1ns / 1ps

module sdr_top_tb();
    reg sys_R_Wn;
    reg sys_ADSn;
    reg sys_START;
    reg sys_CLK;
    reg sys_RESET;
    reg sys_REF_REQ;
    reg [22:0] sys_A;
    wire sys_REF_ACK;
    wire [15:0] sys_D;
    wire sys_D_VALID;
    wire sys_CYC_END;
    wire sys_INIT_DONE;
    wire [3:0] sdr_DQ;
    wire [11:0] sdr_A;
    wire [1:0] sdr_BA;
    wire sdr_CKE;
    wire sdr_CSn;
    wire sdr_RASn;
    wire sdr_CASn;
    wire sdr_WEn;
    wire sdr_DQM;
    sdr_top uut(
                .sys_R_Wn(sys_R_Wn),
                .sys_ADSn(sys_ADSn),
                .sys_START(sys_START),
                .sys_CLK(sys_CLK),
                .sys_RESET(sys_RESET),
                .sys_REF_REQ(sys_REF_REQ),
                .sys_A(sys_A),
                .sys_REF_ACK(sys_REF_ACK),
                .sys_D(sys_D),
                .sys_D_VALID(sys_D_VALID),
                .sys_CYC_END(sys_CYC_END),
                .sys_INIT_DONE(sys_INIT_DONE),
                .sdr_DQ(sdr_DQ),
                .sdr_A(sdr_A),
                .sdr_BA(sdr_BA),
                .sdr_CKE(sdr_CKE),
                .sdr_CSn(sdr_CSn),
                .sdr_RASn(sdr_RASn),
                .sdr_CASn(sdr_CASn),
                .sdr_WEn(sdr_WEn),
                .sdr_DQM(sdr_DQM)
    );
    assign sys_D = (sys_R_Wn) ? 16'hzzzz: 16'h0fce;
    assign sdr_DQ = (sys_R_Wn) ? 4'b0110 : 4'bzzzz;
    initial begin
        sys_R_Wn = 1;
        sys_ADSn = 0;
        sys_START = 1;
        sys_CLK = 0;
        sys_RESET = 0;
        sys_REF_REQ = 0;
        sys_A = 11;
    end

    initial begin
        forever begin
            #10 sys_CLK = ~sys_CLK; 
        end
    end

//    initial begin
//        #100 sys_REF_REQ = 1;
//        #20 sys_REF_REQ = 0;
//    end
    
   initial begin
       forever begin
       #500 sys_R_Wn = ~sys_R_Wn;
       end
  end
endmodule
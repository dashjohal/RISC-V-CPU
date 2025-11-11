module top #(
    parameter ADDRESS_WIDTH = 32,  
    parameter DATA_WIDTH = 32
) (
    //General
    input   logic clk,
    input   logic rst,
    input logic trigger,

    output logic [DATA_WIDTH-1:0] a0, t4, t1, t2, hitcount, misscount


);
// Fetch Stage      
    logic[DATA_WIDTH-1:0] jump_branchPc;
    logic[DATA_WIDTH-1:0] branch_PC;
    logic [DATA_WIDTH-1:0] f_instr;   //fetch stage instruction
    logic [ADDRESS_WIDTH-1:0] f_pc;   //new program counter
    logic [DATA_WIDTH-1:0] f_pcplus4; // Signal to hold next PC value



    //Decode Stage
    logic [DATA_WIDTH-1:0] d_instr;   
    logic [ADDRESS_WIDTH-1:0] d_pc;   
    logic [ADDRESS_WIDTH-1:0] d_pcplus4;    
    logic [DATA_WIDTH-1:0] d_rd1;   //decode stage Register 1 data output
    logic [DATA_WIDTH-1:0] d_rd2;   //Register 2 data output 
    logic [DATA_WIDTH-1:0] d_ImmExt; 
    logic d_regwrite, d_memwrite;
    logic [1:0] d_resultsrc;
    logic d_jump;
    logic [3:0]d_branch;
    logic [3:0] d_alucontrol;
    logic d_alusrc, d_jalr;
    logic [2:0] immsrc;


    //Execute Stage
    logic [DATA_WIDTH-1:0] aluop1;
    logic [DATA_WIDTH-1:0] aluop2;

    logic [DATA_WIDTH-1:0] e_rd1;    // Execute Stage RD1 data 
    logic [DATA_WIDTH-1:0] e_rd2;   
    logic [ADDRESS_WIDTH-1:0] e_pc;
    logic [4:0] e_rs1, e_rs2, e_rd;
    logic [DATA_WIDTH-1:0] e_ImmExt;
    logic [ADDRESS_WIDTH-1:0] e_pcplus4;
    logic e_regwrite, e_memwrite;
    logic [1:0] e_resultsrc;
    logic e_jump;
    logic [3:0] e_branch;
    logic [3:0] e_alucontrol;
    logic e_alusrc, e_jalr;   
    logic e_pcsrc;
    logic [DATA_WIDTH-1:0] e_aluresult;   //execute stage ALU Result
    //logic e_sflag, e_cflag, e_zero;
    //logic [DATA_WIDTH-1:0] e_wdata;   //e_stage write data
    
    
    //Memory Stage
    logic [DATA_WIDTH-1:0] m_aluresult;   
    logic [DATA_WIDTH-1:0] m_wdata;   
    logic [4:0] m_rd;       
    logic [ADDRESS_WIDTH-1:0] m_pcplus4; 
    logic m_regwrite, m_memwrite;
    logic [1:0] m_resultsrc;   
    logic [DATA_WIDTH-1:0] m_readdata;   //memory write read data output
    logic [2:0] m_funct3;

    
    //WB Stage
    logic [DATA_WIDTH-1:0] w_aluresult;   
    logic [DATA_WIDTH-1:0] w_readdata;   
    logic [4:0] w_rd;       
    logic [ADDRESS_WIDTH-1:0] w_pcplus4; 
    logic w_regwrite;
    logic [1:0]w_resultsrc;
    logic [DATA_WIDTH-1:0] w_result;



    assign branch_PC =  e_pc + e_ImmExt; // Calculate Branch address



    //Hazard Units
    logic f_stall, d_stall;      //Data control stall signals
    logic d_flush, e_flush;      //Flush signals
    logic [1:0] e_forwardA, e_forwardB;   //Forwarding Signals

pc programcounter(
    .clk (clk),
    .rst (rst),
    .en (~(f_stall)),
    .PCsrc (e_pcsrc),
    .programcount(f_pc),
    .trigger(trigger),
    .pcplus4(f_pcplus4), //connect to the next PC for JTA
    .jump_branchPc(jump_branchPc)

);

instruction_memory im(
    .A (f_pc),
    .instr (f_instr)
);

pipeline_d pipeline_d(
    .clk(clk),
    .en(~(d_stall)),
    .rst(d_flush),
    .f_instr(f_instr),
    .f_pc(f_pc),
    .f_pcplus4(f_pcplus4),
    .d_instr(d_instr),
    .d_pc(d_pc),
    .d_pcplus4(d_pcplus4)
);

cu cu(
    .opcode (d_instr[6:0]),
    .funct3 (d_instr[14:12]),
    .funct7 (d_instr[31:25]),
    .resultSrc (d_resultsrc),
    .memWrite (d_memwrite),
    .aluSrc (d_alusrc),
    .regWrite (d_regwrite),
    .ImmSrc (immsrc),
    .ALUControl (d_alucontrol),
    .jalr(d_jalr),
    .branch(d_branch),
    .jump(d_jump)
);

// Register File Instantiation
RegisterFile regfile (
    .clk(clk),
    .AD1(d_instr[19:15]),
    .AD2(d_instr[24:20]),
    .AD3(w_rd),
    .WE3(w_regwrite),
    .WD3(w_result),
    .RD1(d_rd1),
    .RD2(d_rd2),
    .a0(a0),
    .t1(t1),
    .t2(t2),
    .t4(t4)
);

imm_ext immediate_exend(
    .instr(d_instr),
    .ImmSrc (immsrc),
    .imm_ext_out (d_ImmExt)
);

pipeline_e pipeline_e(
    .clk(clk),
    .rst(e_flush),
    .d_rd1(d_rd1),
    .d_rd2(d_rd2),
    .d_pc(d_pc),
    .d_ra1(d_instr[19:15]),
    .d_ra2(d_instr[24:20]),
    .d_rd(d_instr[11:7]),
    .d_ImmExt(d_ImmExt),
    .d_pcplus4(d_pcplus4),
    .d_regwrite(d_regwrite),
    .d_memwrite(d_memwrite),
    .d_resultsrc(d_resultsrc),
    .d_jump(d_jump),
    .d_branch(d_branch),
    .d_alucontrol(d_alucontrol),
    .d_alusrc(d_alusrc),
    .d_jalr(d_jalr),
    .e_rd1(e_rd1),
    .e_rd2(e_rd2),
    .e_pc(e_pc),
    .e_ra1(e_rs1),
    .e_ra2(e_rs2),
    .e_rd(e_rd),
    .e_ImmExt(e_ImmExt),
    .e_pcplus4(e_pcplus4),
    .e_regwrite(e_regwrite),
    .e_memwrite(e_memwrite),
    .e_resultsrc(e_resultsrc),
    .e_jump(e_jump),
    .e_branch(e_branch),
    .e_alucontrol(e_alucontrol),
    .e_alusrc(e_alusrc),
    .e_jalr(e_jalr)
);

mux3 ALUop1(
    .in0(e_rd1),
    .in1(w_result),
    .in2(m_aluresult),
    .sel(e_forwardA),
    .out(aluop1)
);

mux3 ALUop2_in0(
    .in0(e_rd2),
    .in1(w_result),
    .in2(m_aluresult),
    .sel(e_forwardB),
    .out(aluop2)    
);

alutop alu(
    .ImmOp (e_ImmExt),
    .ALUsrc (e_alusrc),
    .ALUctrl (e_alucontrol),
    .ALUout (e_aluresult), 
    .ALUop1(aluop1),
    .ALUop2_in0(aluop2),
    .e_branch(e_branch),
    .e_jump(e_jump),
    .e_pcsrc(e_pcsrc)

);

mux mux_jal(
    .in0(branch_PC),
    .in1(e_aluresult),
    .sel(e_jalr),
    .out(jump_branchPc)
);

pipeline_m pipeline_m(
    .clk(clk),
    .e_aluresult(e_aluresult),
    .e_wdata(aluop2),
    .e_rd(e_rd),
    .e_pcplus4(e_pcplus4),
    .e_regwrite(e_regwrite),
    .e_memwrite(e_memwrite),
    .e_resultsrc(e_resultsrc),
    .e_funct3(e_branch[2:0]),
    .m_aluresult(m_aluresult),
    .m_wdata(m_wdata),
    .m_rd(m_rd),
    .m_pcplus4(m_pcplus4),
    .m_regwrite(m_regwrite),
    .m_memwrite(m_memwrite),
    .m_resultsrc(m_resultsrc),
    .m_funct3(m_funct3)
);

datamemory datamemory(
    .clk (clk),
    .funct3(m_funct3),
    .WE (m_memwrite),
    .A (m_aluresult),
    .WD (m_wdata),
    .ResultSrcE (e_resultsrc),
    .hitcount (hitcount),
    .misscount (misscount),
    .ReadData (m_readdata)
);

pipeline_w pipeline_w(
    .clk(clk),
    .m_aluresult(m_aluresult),
    .m_readdata(m_readdata),
    .m_rd(m_rd),
    .m_pcplus4(m_pcplus4),
    .m_regwrite(m_regwrite),
    .m_resultsrc(m_resultsrc),
    .w_aluresult(w_aluresult),
    .w_readdata(w_readdata),
    .w_rd(w_rd),
    .w_pcplus4(w_pcplus4),
    .w_regwrite(w_regwrite),
    .w_resultsrc(w_resultsrc)
);
 
mux3 lastMUX(
    .in0 (w_aluresult),
    .in1 (w_readdata),
    .in2(w_pcplus4),
    .sel (w_resultsrc),
    .out (w_result)
);

hazardunit hazardunit(
    .d_ra1(d_instr[19:15]),
    .d_ra2(d_instr[24:20]),
    .e_ra1(e_rs1),
    .e_ra2(e_rs2),
    .e_rd(e_rd),
    .e_pcsrc(e_pcsrc),
    .e_resultsrc(e_resultsrc[0]),
    .m_rd(m_rd),
    .w_rd(w_rd),
    .m_regwrite(m_regwrite),
    .w_regwrite(w_regwrite),
    .f_stall(f_stall),
    .d_stall(d_stall),
    .d_flush(d_flush),
    .e_flush(e_flush),
    .e_forwardA(e_forwardA),
    .e_forwardB(e_forwardB)
);



endmodule


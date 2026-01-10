`timescale 1ns/1ps

module cpu_pipeline #(
    parameter DEBUG_PRED = 1
)(
    input wire clock,
    input wire reset
);

   
    wire [31:0] pc_f, pc_plus_4_f;
    wire [31:0] instruction_f;
    wire [31:0] next_pc;

    wire pc_write;
    wire ifid_write;
    wire idex_flush;

    assign pc_plus_4_f = pc_f + 32'd4;


    reg [1:0]  bht [0:31];
    reg [31:0] btb_target [0:31];
    reg [24:0] btb_tag [0:31];
    reg        btb_valid [0:31];

    wire [4:0] pred_index;
    wire       btb_hit;
    wire       pred_taken;
    wire [31:0] pred_target;
    wire [31:0] pred_next_pc;

    assign pred_index  = pc_f[6:2];
    assign btb_hit     = btb_valid[pred_index] && (btb_tag[pred_index] == pc_f[31:7]);
    assign pred_taken  = bht[pred_index][1];
    assign pred_target = btb_target[pred_index];
    assign pred_next_pc = (btb_hit && pred_taken) ? pred_target : pc_plus_4_f;

 
    integer total_branches;
    integer mispredicts;

  
    programcounter PC_UUT (
        .clock(clock),
        .reset(reset),
        .next_pc(next_pc),
        .pc_en(pc_write),
        .pc(pc_f)
    );

    InstructionMemory IM_UUT (
        .pc(pc_f),
        .instruction(instruction_f)
    );


    reg  [31:0] pc_id;
    reg  [31:0] pc_plus_4_id;
    reg  [31:0] instruction_id;

  
    reg         pred_taken_id;
    reg  [31:0] pred_pc_id;
    reg  [31:0] pred_target_id;

    // flush control
    wire ifid_flush;
    wire idex_flush_control;

  
    wire [4:0]  rs1_id, rs2_id, rd_id;
    wire [6:0]  opcode_id, funct7_id;
    wire [2:0]  funct3_id;
    wire [31:0] read_data1_id, read_data2_id;

    wire [31:0] imm_i_id, imm_s_id, imm_sb_id, imm_u_id, imm_uj_id;
    wire [31:0] imm_select_id;

    wire        RegWrite_id, MemRead_id, MemWrite_id, MemtoReg_id, ALUSrc_id;
    wire        Branch_id, Jump_id;
    wire [1:0]  ALUOp_id;

 
    reg  [31:0] pc_exe;
    reg  [31:0] pc_plus_4_exe;
    reg  [31:0] read_data1_exe, read_data2_exe;
    reg  [31:0] imm_exe;
    reg  [31:0] imm_branch_exe;
    reg  [31:0] imm_jump_exe;

    reg  [4:0]  wa_exe;
    reg  [4:0]  rs1_exe, rs2_exe;
    reg  [6:0]  opcode_exe;
    reg  [6:0]  funct7_exe;
    reg  [2:0]  funct3_exe;

    reg         RegWrite_exe, MemRead_exe, MemWrite_exe, MemtoReg_exe, ALUSrc_exe;
    reg         Branch_exe, Jump_exe;
    reg  [1:0]  ALUOp_exe;


    reg         pred_taken_exe;
    reg  [31:0] pred_pc_exe;
    reg  [31:0] pred_target_exe;


    wire [3:0]  alu_ctrl_exe;
    wire [31:0] alu_result_exe;
    wire        alu_zero_exe;

    wire [31:0] branch_target_exe;
    wire [31:0] jal_target_exe;
    wire [31:0] jalr_target_exe;

    wire        branch_taken_exe;
    wire        branch_cond_exe;


    reg  [31:0] alu_result_mem;
    reg  [31:0] write_data_mem;
    reg  [31:0] pc_plus_4_mem;
    reg  [4:0]  wa_mem;
    reg         RegWrite_mem, MemRead_mem, MemWrite_mem, MemtoReg_mem;
    reg         Jump_mem;
    reg  [6:0]  opcode_mem;
    reg  [2:0]  funct3_mem;

    wire [31:0] mem_read_data_mem;


    reg  [31:0] mem_read_data_wb;
    reg  [31:0] alu_result_wb;
    reg  [31:0] pc_plus_4_wb;
    reg  [4:0]  wa_wb;
    reg         RegWrite_wb, MemtoReg_wb;
    reg         Jump_wb;
    reg  [6:0]  opcode_wb;

    wire [31:0] write_data_wb;

    wire [1:0]  forward_a, forward_b;
    wire [31:0] fwd_a_data, fwd_b_data;
    wire [31:0] alu_in1, alu_in2_pre;
    wire [31:0] alu_operand2_exe;
    wire [31:0] store_data_exe;

   
    wire is_branch_exe;
    wire mispredict_exe;
    wire [31:0] correct_pc_exe;

    assign is_branch_exe = (opcode_exe == 7'b1100011);
    assign mispredict_exe = is_branch_exe && (branch_taken_exe != pred_taken_exe);
    assign correct_pc_exe = branch_taken_exe ? branch_target_exe : pc_plus_4_exe;

    assign ifid_flush         = mispredict_exe || Jump_exe;
    assign idex_flush_control = mispredict_exe || Jump_exe;


    assign next_pc =
        (opcode_exe == 7'b1100111 && Jump_exe) ? jalr_target_exe :
        (opcode_exe == 7'b1101111 && Jump_exe) ? jal_target_exe :
        (mispredict_exe) ? correct_pc_exe :
        pred_next_pc;

    
    always @(posedge clock) begin
        if (reset) begin
            pc_id <= 0;
            pc_plus_4_id <= 0;
            instruction_id <= 32'h00000013;
            pred_taken_id <= 0;
            pred_pc_id <= 0;
            pred_target_id <= 0;
        end
        else if (ifid_flush) begin
            pc_id <= 0;
            pc_plus_4_id <= 0;
            instruction_id <= 32'h00000013;
            pred_taken_id <= 0;
            pred_pc_id <= 0;
            pred_target_id <= 0;
        end
        else if (ifid_write) begin
            pc_id <= pc_f;
            pc_plus_4_id <= pc_plus_4_f;
            instruction_id <= instruction_f;
            pred_taken_id <= (btb_hit && pred_taken);
            pred_pc_id <= pc_f;
            pred_target_id <= pred_target;
        end
    end

    assign opcode_id = instruction_id[6:0];
    assign rs1_id    = instruction_id[19:15];
    assign rs2_id    = instruction_id[24:20];
    assign rd_id     = instruction_id[11:7];
    assign funct3_id = instruction_id[14:12];
    assign funct7_id = instruction_id[31:25];

    control_unit CU_UUT (
        .Opcode(opcode_id),
        .funct3(funct3_id),
        .funct7(funct7_id),
        .RegWrite(RegWrite_id),
        .MemRead(MemRead_id),
        .MemWrite(MemWrite_id),
        .MemtoReg(MemtoReg_id),
        .ALUSrc(ALUSrc_id),
        .Branch(Branch_id),
        .Jump(Jump_id),
        .ALUOp(ALUOp_id)
    );

    imm_gen IMM_UUT (
        .instr(instruction_id),
        .imm_i(imm_i_id),
        .imm_s(imm_s_id),
        .imm_sb(imm_sb_id),
        .imm_u(imm_u_id),
        .imm_uj(imm_uj_id)
    );

    assign imm_select_id =
        (opcode_id == 7'b0010011 || opcode_id == 7'b0000011 || opcode_id == 7'b1100111) ? imm_i_id :
        (opcode_id == 7'b0100011) ? imm_s_id :
        (opcode_id == 7'b1100011) ? imm_sb_id :
        (opcode_id == 7'b0110111) ? imm_u_id :
        (opcode_id == 7'b1101111) ? imm_uj_id :
        32'b0;


    regfile RF_UUT (
        .clk(clock),
        .we(RegWrite_wb),
        .ra1(rs1_id),
        .ra2(rs2_id),
        .wa(wa_wb),
        .wd(write_data_wb),
        .rd1(read_data1_id),
        .rd2(read_data2_id)
    );

   
    hazard_detection_unit HDU (
        .idex_memread(MemRead_exe),
        .idex_rd(wa_exe),
        .ifid_rs1(rs1_id),
        .ifid_rs2(rs2_id),
        .pc_write(pc_write),
        .ifid_write(ifid_write),
        .idex_flush(idex_flush)
    );

    always @(posedge clock) begin
        if (reset) begin
            RegWrite_exe <= 0; MemRead_exe <= 0; MemWrite_exe <= 0; MemtoReg_exe <= 0; ALUSrc_exe <= 0;
            Branch_exe <= 0; Jump_exe <= 0; ALUOp_exe <= 0;

            pc_exe <= 0; pc_plus_4_exe <= 0;
            read_data1_exe <= 0; read_data2_exe <= 0;
            imm_exe <= 0; imm_branch_exe <= 0; imm_jump_exe <= 0;

            wa_exe <= 0; rs1_exe <= 0; rs2_exe <= 0;
            opcode_exe <= 0; funct7_exe <= 0; funct3_exe <= 0;

            pred_taken_exe <= 0;
            pred_pc_exe <= 0;
            pred_target_exe <= 0;
        end
        else if (idex_flush || idex_flush_control) begin
            RegWrite_exe <= 0; MemRead_exe <= 0; MemWrite_exe <= 0; MemtoReg_exe <= 0; ALUSrc_exe <= 0;
            Branch_exe <= 0; Jump_exe <= 0; ALUOp_exe <= 0;

            pc_exe <= 0; pc_plus_4_exe <= 0;
            read_data1_exe <= 0; read_data2_exe <= 0;
            imm_exe <= 0; imm_branch_exe <= 0; imm_jump_exe <= 0;

            wa_exe <= 0; rs1_exe <= 0; rs2_exe <= 0;
            opcode_exe <= 0; funct7_exe <= 0; funct3_exe <= 0;

            pred_taken_exe <= 0;
            pred_pc_exe <= 0;
            pred_target_exe <= 0;
        end
        else begin
            RegWrite_exe <= RegWrite_id;
            MemRead_exe <= MemRead_id;
            MemWrite_exe <= MemWrite_id;
            MemtoReg_exe <= MemtoReg_id;
            ALUSrc_exe <= ALUSrc_id;
            Branch_exe <= Branch_id;
            Jump_exe <= Jump_id;
            ALUOp_exe <= ALUOp_id;

            pc_exe <= pc_id;
            pc_plus_4_exe <= pc_plus_4_id;
            read_data1_exe <= read_data1_id;
            read_data2_exe <= read_data2_id;

            imm_exe <= imm_select_id;
            imm_branch_exe <= imm_sb_id;
            imm_jump_exe <= imm_uj_id;

            wa_exe <= rd_id;
            rs1_exe <= rs1_id;
            rs2_exe <= rs2_id;

            opcode_exe <= opcode_id;
            funct7_exe <= funct7_id;
            funct3_exe <= funct3_id;

            pred_taken_exe <= pred_taken_id;
            pred_pc_exe <= pred_pc_id;
            pred_target_exe <= pred_target_id;
        end
    end

   
    alu_control ALU_CTRL_UUT (
        .ALUOp(ALUOp_exe),
        .funct3(funct3_exe),
        .funct7(funct7_exe),
        .alu_ctrl(alu_ctrl_exe)
    );

    forwarding_unit FU (
        .exmem_regwrite(RegWrite_mem),
        .exmem_rd(wa_mem),
        .memwb_regwrite(RegWrite_wb),
        .memwb_rd(wa_wb),
        .idex_rs1(rs1_exe),
        .idex_rs2(rs2_exe),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    assign fwd_a_data =
        (forward_a == 2'b10) ? alu_result_mem :
        (forward_a == 2'b01) ? write_data_wb :
        read_data1_exe;

    assign fwd_b_data =
        (forward_b == 2'b10) ? alu_result_mem :
        (forward_b == 2'b01) ? write_data_wb :
        read_data2_exe;

    assign alu_in1 = (opcode_exe == 7'b0110111) ? 32'b0 : fwd_a_data;
    assign alu_in2_pre = fwd_b_data;
    assign alu_operand2_exe = ALUSrc_exe ? imm_exe : alu_in2_pre;

    alu ALU_UUT (
        .a(alu_in1),
        .b(alu_operand2_exe),
        .alu_ctrl(alu_ctrl_exe),
        .result(alu_result_exe),
        .zero(alu_zero_exe)
    );

    assign store_data_exe = fwd_b_data;

    
    assign branch_target_exe = pc_exe + imm_branch_exe;
    assign jal_target_exe    = pc_exe + imm_jump_exe;
    assign jalr_target_exe   = (fwd_a_data + imm_exe) & 32'hFFFFFFFE;

    assign branch_cond_exe =
        (funct3_exe == 3'b000) ? alu_zero_exe :
        (funct3_exe == 3'b001) ? ~alu_zero_exe :
        1'b0;

    assign branch_taken_exe = Branch_exe & branch_cond_exe;

    wire [4:0] update_index;
    assign update_index = pred_pc_exe[6:2];

    integer k;

    initial begin
        for (k=0; k<32; k=k+1) begin
            bht[k] = 2'b01;
            btb_target[k] = 0;
            btb_tag[k] = 0;
            btb_valid[k] = 0;
        end
        total_branches = 0;
        mispredicts = 0;
    end

    always @(posedge clock) begin
        if (reset) begin
            for (k=0; k<32; k=k+1) begin
                bht[k] <= 2'b01;
                btb_valid[k] <= 0;
                btb_target[k] <= 0;
                btb_tag[k] <= 0;
            end
            total_branches <= 0;
            mispredicts <= 0;
        end
        else if (is_branch_exe) begin
            total_branches <= total_branches + 1;
            if (mispredict_exe)
                mispredicts <= mispredicts + 1;

            case ({branch_taken_exe, bht[update_index]})
                3'b1_00: bht[update_index] <= 2'b01;
                3'b1_01: bht[update_index] <= 2'b10;
                3'b1_10: bht[update_index] <= 2'b11;
                3'b1_11: bht[update_index] <= 2'b11;

                3'b0_00: bht[update_index] <= 2'b00;
                3'b0_01: bht[update_index] <= 2'b00;
                3'b0_10: bht[update_index] <= 2'b01;
                3'b0_11: bht[update_index] <= 2'b10;
            endcase

            if (branch_taken_exe) begin
                btb_valid[update_index]  <= 1'b1;
                btb_target[update_index] <= branch_target_exe;
                btb_tag[update_index]    <= pred_pc_exe[31:7];
            end

            if (DEBUG_PRED) begin
                $display("BR: pc=%h pred=%b actual=%b mis=%b BHT=%b BTBhit=%b tgt=%h time=%0t",
                    pred_pc_exe, pred_taken_exe, branch_taken_exe, mispredict_exe,
                    bht[update_index], btb_hit, branch_target_exe, $time);
            end
        end
    end

    always @(posedge clock) begin
        if (reset) begin
            RegWrite_mem <= 0; MemRead_mem <= 0; MemWrite_mem <= 0; MemtoReg_mem <= 0;
            alu_result_mem <= 0; write_data_mem <= 0;
            wa_mem <= 0; funct3_mem <= 0;
            pc_plus_4_mem <= 0; Jump_mem <= 0; opcode_mem <= 0;
        end
        else begin
            RegWrite_mem <= RegWrite_exe;
            MemRead_mem <= MemRead_exe;
            MemWrite_mem <= MemWrite_exe;
            MemtoReg_mem <= MemtoReg_exe;
            alu_result_mem <= alu_result_exe;
            write_data_mem <= store_data_exe;
            wa_mem <= wa_exe;
            funct3_mem <= funct3_exe;
            pc_plus_4_mem <= pc_plus_4_exe;
            Jump_mem <= Jump_exe;
            opcode_mem <= opcode_exe;
        end
    end

    data_memory DM_UUT (
        .clk(clock),
        .mem_write(MemWrite_mem),
        .mem_read(MemRead_mem && !MemWrite_mem),
        .funct3(funct3_mem),
        .addr(alu_result_mem),
        .write_data(write_data_mem),
        .read_data(mem_read_data_mem)
    );

    
    always @(posedge clock) begin
        if (reset) begin
            RegWrite_wb <= 0; MemtoReg_wb <= 0;
            mem_read_data_wb <= 0; alu_result_wb <= 0;
            wa_wb <= 0; pc_plus_4_wb <= 0;
            Jump_wb <= 0; opcode_wb <= 0;
        end
        else begin
            RegWrite_wb <= RegWrite_mem;
            MemtoReg_wb <= MemtoReg_mem;
            mem_read_data_wb <= mem_read_data_mem;
            alu_result_wb <= alu_result_mem;
            wa_wb <= wa_mem;
            pc_plus_4_wb <= pc_plus_4_mem;
            Jump_wb <= Jump_mem;
            opcode_wb <= opcode_mem;
        end
    end

    assign write_data_wb =
        (Jump_wb && (opcode_wb == 7'b1101111 || opcode_wb == 7'b1100111)) ? pc_plus_4_wb :
        (MemtoReg_wb ? mem_read_data_wb : alu_result_wb);

    always @(posedge clock) begin
        if (!reset && RegWrite_wb) begin
            $display("WB: opcode=%b wa=%0d wd=%h MemtoReg=%b Jump=%b time=%0t",
                     opcode_wb, wa_wb, write_data_wb, MemtoReg_wb, Jump_wb, $time);
        end
    end

endmodule
`timescale 1ns/1ps
module cpu_pipeline_tb;

    reg clock;
    reg reset;


    real acc;

    cpu_pipeline #(.DEBUG_PRED(1)) UUT (
        .clock(clock),
        .reset(reset)
    );

    always #5 clock = ~clock;

    initial begin
       
        $dumpfile("cpu_pipeline_tb.vcd");
        $dumpvars(0, cpu_pipeline_tb);

     
        clock = 0;
        reset = 1;

        #20;
        reset = 0;
        #3000;
        $display("FINAL REGISTER VALUES:");
        $display("x1  = %h", UUT.RF_UUT.rf[1]);
        $display("x2  = %h", UUT.RF_UUT.rf[2]);
        $display("x3  = %h", UUT.RF_UUT.rf[3]);
        $display("x4  = %h", UUT.RF_UUT.rf[4]);
        $display("BRANCH PREDICTOR STATS:");
        $display("Total branches     = %0d", UUT.total_branches);
        $display("Mispredictions     = %0d", UUT.mispredicts);

        if (UUT.total_branches > 0) begin
            acc = 100.0 * (UUT.total_branches - UUT.mispredicts) / UUT.total_branches;
            $display("Prediction accuracy = %0f%%", acc);
        end

        $finish;
    end

endmodule

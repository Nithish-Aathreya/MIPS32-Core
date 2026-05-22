class c_ref_model;
    bit[31:0] reg_bank_ref[31:0];
    bit[7:0]  mem_d_ref[4096];
    txn tx;
    function void init();
    foreach(common::init_reg_bank[i])
        reg_bank_ref[i] = common::init_reg_bank[i];
    foreach(common::init_mem_d[i])
        mem_d_ref[i] = common::init_mem_d[i]; 
    endfunction
    
    task run();
        forever begin
          common::g2r.get(tx);
            predict(tx);
          common::r2s.put(tx);

        end
    endtask




    task predict(txn tx);
        case(tx.opcode)
            6'b000000: exec_rtype(tx);  // R-type
            6'b001000: exec_addi(tx);   // ADDI
            6'b000100: exec_beqz(tx);   // BEQZ
            6'b000101: exec_bneqz(tx);  // BNEQZ
            6'b100011: exec_lw(tx);     // LW
            6'b101011: exec_sw(tx);     // SW
        endcase
        //reg_bank_ref[0] = 32'b0; // r0 always zero
    endtask

task exec_rtype(txn tx);
    case(tx.funct)
        6'b100000: begin 
        reg_bank_ref[tx.rd] = reg_bank_ref[tx.rs] + reg_bank_ref[tx.rt];  // ADD
        tx.reg_bank_ref[tx.rd] = reg_bank_ref[tx.rd];
    end
    6'b100010: begin 
    reg_bank_ref[tx.rd] = reg_bank_ref[tx.rs] - reg_bank_ref[tx.rt];  // SUB
        tx.reg_bank_ref[tx.rd] = reg_bank_ref[tx.rd];
    end
    6'b100100: begin
        reg_bank_ref[tx.rd] = reg_bank_ref[tx.rs] & reg_bank_ref[tx.rt];  // AND
        tx.reg_bank_ref[tx.rd] = reg_bank_ref[tx.rd];
    end
    6'b100101: begin 
    reg_bank_ref[tx.rd] = reg_bank_ref[tx.rs] | reg_bank_ref[tx.rt];  // OR
        tx.reg_bank_ref[tx.rd] = reg_bank_ref[tx.rd];
    end
    6'b000010:begin
        reg_bank_ref[tx.rd] = reg_bank_ref[tx.rs] * reg_bank_ref[tx.rt];  // MUL
        tx.reg_bank_ref[tx.rd] = reg_bank_ref[tx.rd];
    end
    endcase
endtask

task exec_addi(txn tx);
    reg_bank_ref[tx.rt] = reg_bank_ref[tx.rs] + {{16{tx.imm[15]}}, tx.imm}; // sign extend
    tx.reg_bank_ref[tx.rt] = reg_bank_ref[tx.rt];
endtask

task exec_lw(txn tx);
    bit[31:0] addr;
    addr = reg_bank_ref[tx.rs] + {{16{tx.imm[15]}}, tx.imm};
    reg_bank_ref[tx.rt] = {mem_d_ref[addr], mem_d_ref[addr+1], mem_d_ref[addr+2], mem_d_ref[addr+3]};
    tx.reg_bank_ref[tx.rt] = reg_bank_ref[tx.rt];
endtask

task exec_sw(txn tx);
    bit[31:0] addr;
    addr = reg_bank_ref[tx.rs] + {{16{tx.imm[15]}}, tx.imm};
    mem_d_ref[addr]   = reg_bank_ref[tx.rt][31:24];
    mem_d_ref[addr+1] = reg_bank_ref[tx.rt][23:16];
    mem_d_ref[addr+2] = reg_bank_ref[tx.rt][15:8];
    mem_d_ref[addr+3] = reg_bank_ref[tx.rt][7:0];
endtask

task exec_beqz(txn tx);
    // reference model just checks condition
    // branch target tracking handled separately
    if(reg_bank_ref[tx.rs] == 32'b0)
        $display("\t==============BEQZ taken=================");
    else
        $display("\t==============BEQZ not taken===============");
endtask

task exec_bneqz(txn tx);
    if(reg_bank_ref[tx.rs] != 32'b0)
        $display("\t===========BNEQZ taken===================");
    else
        $display("\t===========BNEQZ not taken===============");
endtask
endclass

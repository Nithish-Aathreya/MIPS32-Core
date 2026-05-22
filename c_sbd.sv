class c_sbd;
    txn      exp_tx;  // from generator
    mon_txn  act_tx;  // from monitor
    
    int pass_count;
    int fail_count;
    
parameter ADD=6'b000000, ADDI=6'b001000, BEQZ=6'b000100, BNEQZ=6'b000101,LW=6'b100011,SW=6'b101011,HLT=6'b000000,SUB=6'b000000, AND=6'b000000, OR=6'b000000, MUL=6'b000000;
    
    task run();
        forever begin
            common::r2s.get(exp_tx); // get expected
            common::m2s.get(act_tx); // get observed
        //$display("EXP: opcode=%0d rd=%0d val=%0h", exp_tx.opcode, exp_tx.rd, exp_tx.reg_bank_ref[exp_tx.rd]);
            compare();               // compare
            if(pass_count==common::num_txns)
            report();
        end
    endtask

task compare();
    case(exp_tx.opcode)
    
        ADD, SUB, AND, OR,MUL: begin  // R-type
            // only destination register changes
            if(exp_tx.reg_bank_ref[exp_tx.rd] !== act_tx.reg_bank[exp_tx.rd]) begin
                $display("FAIL: reg[%0d] expected=%0h observed=%0h",
                          exp_tx.rd, exp_tx.reg_bank_ref[exp_tx.rd], act_tx.reg_bank[exp_tx.rd]);
                fail_count++;
            end else begin
                $display("PASS: reg[%0d] = %0h", exp_tx.rd, act_tx.reg_bank[exp_tx.rd]);
                pass_count++;
            end
        end

        ADDI: begin  // I-type
            // only rt changes
            if(exp_tx.reg_bank_ref[exp_tx.rt] !== act_tx.reg_bank[exp_tx.rt]) begin
                $display("FAIL: reg[%0d] expected=%0h observed=%0h",
                          exp_tx.rt, exp_tx.reg_bank_ref[exp_tx.rt], act_tx.reg_bank[exp_tx.rt]);
                fail_count++;
            end else begin
                $display("PASS: reg[%0d] expected=%0h observed=%0h",
                          exp_tx.rt, exp_tx.reg_bank_ref[exp_tx.rt], act_tx.reg_bank[exp_tx.rt]);
                pass_count++;
            end
        end

        LW: begin  // only rt (destination) changes
            if(exp_tx.reg_bank_ref[exp_tx.rt] !== act_tx.reg_bank[exp_tx.rt]) begin
                $display("FAIL: reg[%0d] expected=%0h observed=%0h",
                          exp_tx.rt, exp_tx.reg_bank_ref[exp_tx.rt], act_tx.reg_bank[exp_tx.rt]);
                fail_count++;
            end else
                pass_count++;
        end
//
//        SW: begin  // only memory changes, not registers
//            if(refe.mem_d[refe.mem_addr] !== act_tx.mem_d[refe.mem_addr]) begin
//                $display("FAIL: mem[%0d] expected=%0h observed=%0h",
//                          refe.mem_addr, refe.mem_d[refe.mem_addr], act_tx.mem_d[refe.mem_addr]);
//                fail_count++;
//            end else
//                pass_count++;
//        end
//
//        BEQZ: begin  // only PC changes
//            if(refe.pc !== act_tx.pc) begin
//                $display("FAIL: PC expected=%0h observed=%0h", refe.pc, act_tx.pc);
//                fail_count++;
//            end else
//                pass_count++;
//        end

    endcase
endtask

    function void report();
        $display("PASS: %0d FAIL: %0d", pass_count, fail_count);
    endfunction

endclass


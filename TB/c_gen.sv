class c_gen;
    txn tx,prev_tx;
    txn q[$];

parameter ADD=6'b000000, ADDI=6'b001000, BEQZ=6'b000100, BNEQZ=6'b000101,LW=6'b100011,SW=6'b101011,HLT=6'b000000,SUB=6'b000000, AND=6'b000000, OR=6'b000000, MUL=6'b000000;


    task run();
        case(common::mode)
            "RANDOM_MODE": begin //add,sub,and,or,mul,addi
                repeat(common::num_txns) begin
                tx=new();
                assert(tx.randomize()with {
                    !(tx.opcode inside {BEQZ,BNEQZ,LW,SW});});
                //q.push_back(tx);
                common::g2b.put(tx);
                common::g2r.put(tx);
            end
            end
            "DATA_HAZARD_MODE": begin //enforcing data hazard
                prev_tx=new();
                assert(prev_tx.randomize() with {prev_tx.opcode inside {ADD};}); 
                //q.push_back(prev_tx);
                common::g2b.put(prev_tx);
                common::g2r.put(prev_tx);

                repeat(common::num_txns) begin
                tx=new();
                //assert(tx.randomize() with {
                //    tx.rs==prev_tx.rd;
                //    !(tx.opcode inside {BEQZ,BNEQZ,LW,SW,ADDI});});
                
                assert(tx.randomize() with {
                    tx.rs==prev_tx.rd;
                    !(tx.opcode inside {BEQZ,BNEQZ,LW,SW,ADDI});});
                //q.push_back(tx);
                common::g2b.put(tx);
                common::g2r.put(tx);
                prev_tx = tx;

            end
            end
            "LOAD_USE_HAZARD": begin
                prev_tx=new();
                assert(prev_tx.randomize() with {prev_tx.opcode==LW;});
                //q.push_back(prev_tx);
                common::g2b.put(prev_tx);
                common::g2r.put(prev_tx);

                repeat(common::num_txns) begin
                tx=new();
                assert(tx.randomize() with {tx.rs==prev_tx.rt;
                !(tx.opcode inside {BEQZ,BNEQZ,SW});});
                //q.push_back(tx);
                common::g2b.put(tx);
                common::g2r.put(tx);
                prev_tx = tx;
            end
            end

            "DIRECTED_MODE": begin 
            //to use for some corner cases like testing branching,flushing & NOP
                $readmemb("asm.bin", top.dut.mem_i);
                //$readmemb("data.bin", top.dut.mem_d);

                end
        endcase
    endtask
    endclass


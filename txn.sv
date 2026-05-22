class txn;
    rand bit[5:0] opcode;
    rand bit[5:0] funct;
    rand bit[4:0]rs;
    rand bit[4:0]rt;
    rand bit[4:0]rd;
    rand bit[15:0]imm;
         bit[31:0] reg_bank_ref[31:0];
         bit[31:0]instr_bits; 

constraint imm_c{
    imm inside {[0:4095] };}
         
constraint opcode_c{
   opcode inside {
                6'b000000, 6'b001000, 6'b000100, 6'b000101,6'b100011,
                6'b101011 }; 
                    }

    constraint funct_c{
        (opcode==6'b000000)->
        funct inside { 
                        6'b100000, 6'b100010, 6'b100100, 6'b100101, 6'b000010
                        };
        }
        function void post_randomize();
            if(opcode==6'b000000) begin
                instr_bits={opcode,rs,rt,rd,5'b0,funct};
                print_r();
            end
            else begin
                instr_bits={opcode,rs,rt,imm};
                print_2();
            end
        endfunction

        function void print_r();
            $display("opcode=%0b",instr_bits[31:26]);
            $display("rs=%0b",instr_bits[25:21]);
            $display("rt=%0b",instr_bits[20:16]);
            $display("rd=%0b",instr_bits[15:11]);
            $display("shamt=%0b",instr_bits[10:6]);
            $display("funct=%0b",instr_bits[5:0]);
            $display("instr=%0h\n",instr_bits);
        endfunction


        function void print_2();
            $display("opcode=%b",instr_bits[31:26]);
            $display("rs=%b",instr_bits[25:21]);
            $display("rt=%b",instr_bits[20:16]);
            $display("imm=%b",instr_bits[15:0]);
            $display("instr=%h\n",instr_bits);
        endfunction
    endclass

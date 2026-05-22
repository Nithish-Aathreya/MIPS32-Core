class c_cov;

    mon_txn tx;

    covergroup random_cg;
        OPCODE: coverpoint tx.instr[31:26] {
        bins r_type     = {6'b000000};
        bins I_type     = {6'b001000};
        }
        
       FUNCT:coverpoint tx.instr[5:0] iff (tx.instr[31:26]==6'b000000) {
               bins add_f = {6'b100000};
               bins sub_f = {6'b100010};
               bins and_f = {6'b100100};
               bins or_f =  {6'b100101};
               bins mul_f = {6'b000010};
               option.at_least=1;
               }

       OPERAND_A_MEM:coverpoint tx.fwd_A_from_MEM{
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                       }

       OPERAND_B_MEM:coverpoint tx.fwd_B_from_MEM{
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }  
//in random mode;
//forwarding happens only from mem stage not from wb stage. 
//because, i am generating opcodes only for add and addi which doesn't involve data memory.
//so, coverpoints for wb stage is pulling down the overall percentage. 
       OPERAND_A_WEB :coverpoint tx.fwd_A_from_WB   {
                   ignore_bins forwarded     = {1'b1};
                   ignore_bins no_forward  = {1'b0};

                        }
      OPERAND_B_WEB  :coverpoint tx.fwd_B_from_WB   {
                   ignore_bins forwarded     = {1'b1};
                   ignore_bins no_forward  = {1'b0};

                        }
    endgroup
    
    covergroup data_hazard_Cg;

        OPCODE: coverpoint tx.instr[31:26] {
        bins r_type     = {6'b000000};
        }

       FUNCT:coverpoint tx.instr[5:0] iff (tx.instr[31:26]==6'b000000) {
               bins add_f = {6'b100000};
               bins sub_f = {6'b100010};
               bins and_f = {6'b100100};
               bins or_f =  {6'b100101};
               bins mul_f = {6'b000010};
               option.at_least=1;
               }

       OPERAND_A_MEM:coverpoint tx.fwd_A_from_MEM{
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                       }

       OPERAND_B_MEM:coverpoint tx.fwd_B_from_MEM{
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }  

       OPERAND_A_WEB :coverpoint tx.fwd_A_from_WB   {
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }
      OPERAND_B_WEB  :coverpoint tx.fwd_B_from_WB   {
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }



    endgroup

    covergroup load_use_cg;
        OPCODE: coverpoint tx.instr[31:26] {
        bins lw_type    = {6'b100011}; 
        }

       OPERAND_A_MEM:coverpoint tx.fwd_A_from_MEM{
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                       }

       OPERAND_B_MEM:coverpoint tx.fwd_B_from_MEM{
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }  

       OPERAND_A_WEB :coverpoint tx.fwd_A_from_WB   {
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }
      OPERAND_B_WEB  :coverpoint tx.fwd_B_from_WB   {
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }

    endgroup

    covergroup directed_cg;

        OPCODE: coverpoint tx.instr[31:26] {
        bins r_type     = {6'b000000};
        bins I_type     = {6'b001000};
        bins beqz_type  = {6'b000100}; 
        bins bneqz_type = {6'b000101}; 
        bins lw_type    = {6'b100011}; 
        bins sw_type    = {6'b101011}; 
        }
        
       FUNCT:coverpoint tx.instr[5:0] iff (tx.instr[31:26]==6'b000000) {
               bins add_f = {6'b100000};
               bins sub_f = {6'b100010};
               bins and_f = {6'b100100};
               bins or_f =  {6'b100101};
               bins mul_f = {6'b000010};
               option.at_least=1;
               }

       BRANCH_TAKING_AND_FLUSHING:coverpoint tx.taken_branch{

                   bins taken     = {1'b1};
                   bins not_taken = {1'b0};
                   }

       NOP_INSERTING:coverpoint tx.stall_detected{

                   bins inserted     = {1'b1};
                   bins no_insert  = {1'b0};
                   }
       OPERAND_A_MEM:coverpoint tx.fwd_A_from_MEM{
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                       }

       OPERAND_B_MEM:coverpoint tx.fwd_B_from_MEM{
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }  

       OPERAND_A_WEB :coverpoint tx.fwd_A_from_WB   {
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }
      OPERAND_B_WEB  :coverpoint tx.fwd_B_from_WB   {
                   bins forwarded     = {1'b1};
                   bins no_forward  = {1'b0};

                        }
    endgroup

    function new();
        case(common::mode)
            "RANDOM_MODE":      random_cg = new();
            "DATA_HAZARD_MODE": data_hazard_Cg = new(); 
            "LOAD_USE_HAZARD":  load_use_cg = new(); 
            "DIRECTED_MODE":    directed_cg = new();
        endcase

    endfunction

    task run();
        forever begin
        common::m2c.get(tx);
        case(common::mode)
            "RANDOM_MODE":random_cg.sample();
            "DATA_HAZARD_MODE":data_hazard_Cg.sample();
            "LOAD_USE_HAZARD":load_use_cg.sample();
            "DIRECTED_MODE":directed_cg.sample();
        endcase

    end
    endtask

endclass





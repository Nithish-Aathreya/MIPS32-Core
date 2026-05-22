class mon_txn;
    bit[31:0] reg_bank[31:0];  // observed register file state
    bit[31:0] mem_d[4095:0];       // observed data memory state
    bit       taken_branch;  // branch flush observed
    bit       stall_detected;// NOP in id_ex_ir
    bit[31:0] instr;         // instruction being observed
//    bit[31:0] wb_instr;         
bit fwd_A_from_MEM;
bit fwd_B_from_MEM;
bit fwd_A_from_WB;
bit fwd_B_from_WB;
endclass

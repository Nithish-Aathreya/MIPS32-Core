class c_mon;
    mon_txn tx;

    virtual intf vif;

    function new();
        vif=top.pintf;
    endfunction

    task run();
        forever begin
            @(posedge vif.clk2);
            tx = new();
            capture(tx);
             if(top.dut.mem_wb_ir !== 32'b0)  
                common::m2s.put(tx);
                common::m2c.put(tx);
        end
    endtask
    task capture(mon_txn mtx);
    // register file state
        foreach(top.dut.reg_bank[i])
            mtx.reg_bank[i] = top.dut.reg_bank[i];
        
        // data memory state (for SW)
       foreach(top.dut.mem_d[i])
        mtx.mem_d[i] = top.dut.mem_d[i];
        
        // pipeline observability
        if(top.dut.taken_branch)
        mtx.taken_branch   = 1;
        if(top.dut.id_ex_ir==32'b0)
        mtx.stall_detected = 1;
        //mtx.instr          = top.dut.if_id_ir;
        mtx.instr = top.dut.mem_wb_ir; 
mtx.fwd_A_from_MEM = top.dut.fwd_A_from_MEM;
mtx.fwd_B_from_MEM = top.dut.fwd_B_from_MEM;
mtx.fwd_A_from_WB  = top.dut.fwd_A_from_WB;
mtx.fwd_B_from_WB  = top.dut.fwd_B_from_WB;

    endtask
endclass

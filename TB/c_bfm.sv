class c_bfm;
        txn tx;
        bit [11:0]addr;
    
    virtual intf vif; 

    function new();
        vif=top.pintf;
    endfunction

    task run();
        forever begin
        common::g2b.get(tx);
        drive(tx);
    end
endtask

task drive(txn tx );
    byte temp[4];
    temp = {>>{tx.instr_bits}}; //streams MSB first (similar to big endian)
    top.dut.mem_i[addr] = temp[0];
    top.dut.mem_i[addr+1] = temp[1];
    top.dut.mem_i[addr+2] = temp[2];
    top.dut.mem_i[addr+3] = temp[3];
    addr+=4;


endtask
endclass


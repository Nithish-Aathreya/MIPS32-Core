module top;

reg clk1,clk2;
common cmn = new();
initial begin
    clk1=0;
    forever #5 clk1 = ~clk1;
end
initial begin
    clk2=1;
    forever #5 clk2 = ~clk2;
end
intf pintf(clk1,clk2);
mips dut(.clk1(pintf.clk1),.clk2(pintf.clk2));
c_env env=new();
initial begin
    dut.hlt=1;
    cmn.initialize();
    env.refe.init();
    #2 reset_load();
    #6;
    dut.hlt=0;
    env.run();
    #200;
    $finish;
end

task reset_load();
    dut.pc         = 0;
    dut.if_id_ir   = 0;
    dut.if_id_npc  = 0;
    dut.id_ex_ir   = 0;
    //dut.id_ex_type = 3'b110;
    dut.ex_mem_ir  = 0;
    //dut.ex_mem_type= 3'b110;
    dut.ex_mem_aluout= 0;
    dut.mem_wb_ir  = 0;
    //dut.mem_wb_type= 3'b110;
    dut.taken_branch= 0;
    //dut.reg_bank[8] = 32'd0;  // $t0
    //dut.reg_bank[9] = 32'd0;  // $t1
    //dut.reg_bank[10] = 32'd3;  // $t2
    //dut.reg_bank[11] = 32'd20;  // $t3
    //dut.reg_bank[12] = 32'd0;  // $t4
    //dut.reg_bank[13] = 32'd5;  // $t5
    //dut.reg_bank[14] = 32'd0;  // $t6
    //dut.reg_bank[15] = 32'd3;  // $t7
foreach(common::init_reg_bank[i])
    dut.reg_bank[i] = common::init_reg_bank[i];
foreach(common::init_mem_d[i])
    dut.mem_d[i] = common::init_mem_d[i];

endtask
endmodule

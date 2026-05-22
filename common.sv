class common;
    static string mode = "DIRECTED_MODE";
    static int num_txns = 12;
    static mailbox g2b = new();
    static mailbox g2r = new();

    static mailbox r2s = new();

    static mailbox m2s = new();
    static mailbox m2c = new();

    static bit[31:0] init_reg_bank [31:0];
    static bit [7:0]init_mem_d[4095:0];

    task initialize();
        foreach(init_reg_bank[i])
            init_reg_bank[i]=i;
       foreach(init_mem_d[i])
           init_mem_d[i] = i+1;
    endtask


endclass

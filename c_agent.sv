class c_agent;
    c_gen gen = new();
    c_bfm bfm = new();
    c_mon mon = new();
    c_cov cov = new();

    task run();
        fork 
            gen.run();
            bfm.run();
            mon.run();
            cov.run();
        join_none
    endtask
endclass

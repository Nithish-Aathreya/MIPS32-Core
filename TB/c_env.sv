class c_env;
    c_agent agent = new();
    c_sbd sbd = new();
    c_ref_model refe = new();  // reference model instance


    task run();
        fork
            agent.run();
            refe.run();
            sbd.run();
        join_none
    endtask
endclass

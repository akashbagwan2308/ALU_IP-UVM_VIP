//base test

class base_test extends uvm_test;
    // Use the standard macro so UVM registers the string name!
    `uvm_component_utils(base_test)
    
    // Define WIDTH locally so it can be passed down to the environment
    localparam WIDTH = 8;
    
    alu_env    #(WIDTH) env;
    env_config #(WIDTH) cfg;
    
    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        cfg = env_config#(WIDTH)::type_id::create("cfg");
        cfg.apb_cfg = apb_agent_config#(WIDTH)::type_id::create("apb_cfg");
        
        if (!uvm_config_db#(virtual apb_inft #(WIDTH))::get(this, "", "vif", cfg.apb_cfg.vif))
            `uvm_fatal("TEST_VIF", "Virtual interface not found in config_db!")
            
        uvm_config_db#(env_config #(WIDTH))::set(this, "env", "env_cfg", cfg);
        
        env = alu_env#(WIDTH)::type_id::create("env", this);
    endfunction
    
    // Objections for the test duration
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        #100ns; // Minimum test time
        phase.drop_objection(this);
    endtask
    
endclass
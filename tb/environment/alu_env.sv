//env

class alu_env #(parameter WIDTH = 8) extends uvm_env;
    
    `uvm_component_param_utils(alu_env #(WIDTH))
    
    env_config        #(WIDTH) cfg;
    apb_agent         #(WIDTH) apb_agt;
    virtual_sequencer #(WIDTH) v_sqr;
    alu_scoreboard    #(WIDTH) scbd;
    alu_coverage      #(WIDTH) cov;
    
    function new(string name = "alu_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(env_config #(WIDTH))::get(this, "", "env_cfg", cfg))
            `uvm_fatal("ENV_CFG_ERR", "env_config not found!")
            
        // Push agent config down
        uvm_config_db#(apb_agent_config #(WIDTH))::set(this, "apb_agt*", "cfg", cfg.apb_cfg);
        
        apb_agt = apb_agent#(WIDTH)::type_id::create("apb_agt", this);
        v_sqr   = virtual_sequencer#(WIDTH)::type_id::create("v_sqr", this);
        
        if (cfg.has_scoreboard) scbd = alu_scoreboard#(WIDTH)::type_id::create("scbd", this);
        if (cfg.has_coverage)   cov  = alu_coverage#(WIDTH)::type_id::create("cov", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        v_sqr.apb_seqr = apb_agt.sequencer;
        
        if (cfg.has_scoreboard) apb_agt.ap.connect(scbd.item_collected_export);
        if (cfg.has_coverage)   apb_agt.ap.connect(cov.analysis_export);
    endfunction
    
endclass
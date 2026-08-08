//base env
/*
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
*/

class alu_env #(parameter WIDTH = 8) extends uvm_env;
    `uvm_component_param_utils(alu_env #(WIDTH))
    
    // Standard UVM components
    env_config        #(WIDTH) cfg;
    apb_agent         #(WIDTH) apb_agt;
    virtual_sequencer #(WIDTH) v_sqr;
    alu_scoreboard    #(WIDTH) scbd;
    alu_coverage      #(WIDTH) cov;
    
    // -------------------------------------------------
    // RAL Components added here
    // -------------------------------------------------
    alu_reg_block              regmodel;
    alu_reg_adapter #(WIDTH)   reg_adapter;
    alu_predictor   #(WIDTH)   reg_predictor;
    
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
        
        // -------------------------------------------------
        // Instantiate RAL Components
        // -------------------------------------------------
        regmodel = alu_reg_block::type_id::create("regmodel");
        regmodel.build(); // Must call build manually on the reg block!
        regmodel.lock_model();
        
        reg_adapter = alu_reg_adapter#(WIDTH)::type_id::create("reg_adapter");
        reg_predictor = alu_predictor#(WIDTH)::type_id::create("reg_predictor", this);
        
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        v_sqr.apb_seqr = apb_agt.sequencer;
        
        if (cfg.has_scoreboard) apb_agt.ap.connect(scbd.item_collected_export);
        if (cfg.has_coverage)   apb_agt.ap.connect(cov.analysis_export);
        
        // -------------------------------------------------
        // Connect RAL Components
        // -------------------------------------------------
        if (regmodel.default_map != null) begin
            // 1. Connect sequencer and adapter to the memory map for Front-door access
            regmodel.default_map.set_sequencer(v_sqr.apb_seqr, reg_adapter);
            
            // 2. Disable auto-prediction since we are using an explicit predictor
            regmodel.default_map.set_auto_predict(0);
            
            // 3. Connect the Predictor to the map and adapter
            reg_predictor.map = regmodel.default_map;
            reg_predictor.adapter = reg_adapter;
            
            // 4. Connect the Predictor to the Agent's Monitor Analysis Port
            // This allows the predictor to observe all APB traffic and update the mirror passively
            apb_agt.ap.connect(reg_predictor.bus_in);
        end else begin
            `uvm_fatal("RAL_ERR", "default_map is null in regmodel!")
        end
        
    endfunction
    
endclass
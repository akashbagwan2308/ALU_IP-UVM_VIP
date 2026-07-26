//agent

class apb_agent #(parameter WIDTH = 8) extends uvm_agent;
    
    `uvm_component_param_utils(apb_agent #(WIDTH))
    
    // Sub-components
    apb_driver    #(WIDTH) driver;
    apb_sequencer #(WIDTH) sequencer;
    apb_monitor   #(WIDTH) monitor;
    
    // Configuration Object
    apb_agent_config #(WIDTH) cfg;
    
    // Analysis port to broadcast transactions to the environment (Scoreboard/Coverage)
    uvm_analysis_port #(transaction #(WIDTH)) ap;
    
    // Constructor
    function new(string name = "apb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // --------------------------------------------------------
    // Build Phase
    // --------------------------------------------------------
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // 1. Get the configuration object from the config DB
        if (!uvm_config_db#(apb_agent_config #(WIDTH))::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("AGENT_CFG", "apb_agent_config not found in config_db!")
        end
        
        // 2. Pass the virtual interface down to the monitor and driver
        uvm_config_db#(virtual apb_inft #(WIDTH))::set(this, "monitor", "vif", cfg.vif);
        if (cfg.is_active == UVM_ACTIVE) begin
            uvm_config_db#(virtual apb_inft #(WIDTH))::set(this, "driver", "vif", cfg.vif);
        end
        
        // 3. Build the Monitor (always built)
        monitor = apb_monitor#(WIDTH)::type_id::create("monitor", this);
        ap = new("ap", this);
        
        // 4. Build Driver and Sequencer only if active
        if (cfg.is_active == UVM_ACTIVE) begin
            driver    = apb_driver#(WIDTH)::type_id::create("driver", this);
            sequencer = apb_sequencer#(WIDTH)::type_id::create("sequencer", this);
        end
    endfunction
    
    // --------------------------------------------------------
    // Connect Phase
    // --------------------------------------------------------
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect the monitor's analysis port to the agent's analysis port
        monitor.item_collected_port.connect(this.ap);
        
        // Connect the driver and sequencer if active
        if (cfg.is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
    
endclass
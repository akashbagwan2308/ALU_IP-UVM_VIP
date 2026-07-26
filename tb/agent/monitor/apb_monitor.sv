//monitor

class apb_monitor #(parameter WIDTH = 8) extends uvm_monitor;

    `uvm_component_param_utils(apb_monitor #(WIDTH))
    
    virtual apb_inft #(WIDTH) vif;
    
    // Analysis port to broadcast observed transactions
    uvm_analysis_port #(transaction #(WIDTH)) item_collected_port;
    

    function new(string name = "apb_monitor", uvm_component parent = null);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_inft #(WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("MON_VIF_ERR", "Virtual interface 'vif' not found in config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        transaction #(WIDTH) trans;
        
        // Wait for reset to be released before monitoring
        wait (vif.PRESET_n === 1'b1);
        
        forever begin
            // Wait for the clock edge defined by the monitor's clocking block
            @(vif.mon_cb);
            
            // A valid APB transaction completes on the clock edge where 
            // PSEL, PENABLE, and PREADY are all asserted HIGH simultaneously.
            if (vif.mon_cb.PSEL === 1'b1 && vif.mon_cb.PENABLE === 1'b1 && vif.mon_cb.PREADY === 1'b1) begin
                
                // Create a new transaction object to hold the observed data
                trans = transaction#(WIDTH)::type_id::create("trans");
                
                // Capture the common signals
                trans.pwrite = vif.mon_cb.PWRITE;
                trans.paddr  = vif.mon_cb.PADDR;
                trans.pready = vif.mon_cb.PREADY;
                
                // Capture data based on the transaction type (Read vs Write)
                if (trans.pwrite) begin
                    trans.pwdata = vif.mon_cb.PWDATA;
                    trans.prdata = '0; // Default for writes
                    `uvm_info("APB_MON", $sformatf("Observed WRITE: ADDR=0x%0h DATA=0x%0h", trans.paddr, trans.pwdata), UVM_HIGH)
                end else begin
                    trans.pwdata = '0; // Default for reads
                    trans.prdata = vif.mon_cb.PRDATA;
                    `uvm_info("APB_MON", $sformatf("Observed READ: ADDR=0x%0h DATA=0x%0h", trans.paddr, trans.prdata), UVM_HIGH)
                end
                
                // Broadcast the cloned transaction out through the analysis port
                item_collected_port.write(trans);
            end
        end
    endtask
    
endclass
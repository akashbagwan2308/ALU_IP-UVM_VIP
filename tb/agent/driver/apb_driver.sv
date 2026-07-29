//driver

class apb_driver #(parameter WIDTH = 8) extends uvm_driver #(transaction #(WIDTH));
    
    // Register the driver in the UVM Factory
    `uvm_component_param_utils(apb_driver #(WIDTH))
    
    // Virtual interface handle to access the APB signals
    virtual apb_inft #(WIDTH) vif;
    
    // Standard UVM Component Constructor
    function new(string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_inft #(WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV_VIF_ERR", "Virtual interface 'vif' not found in config_db")
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        // 1. Initialize Default APB Idle State
        vif.drv_cb.PSEL    <= 1'b0;
        vif.drv_cb.PENABLE <= 1'b0;
        vif.drv_cb.PWRITE  <= 1'b0;
        vif.drv_cb.PADDR   <= '0;
        vif.drv_cb.PWDATA  <= '0;
        
        // 2. Wait for reset to be released
        wait (vif.PRESET_n === 1'b1);
        @(vif.drv_cb); // Align to the next clock edge
        
        // 3. Main Transaction Loop
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    

    virtual task drive_transaction(transaction #(WIDTH) req);
        // ==============================================
        // SETUP PHASE
        @(vif.drv_cb); 
        vif.drv_cb.PSEL    <= 1'b1;
        vif.drv_cb.PENABLE <= 1'b0;
        vif.drv_cb.PWRITE  <= req.pwrite;
        vif.drv_cb.PADDR   <= req.paddr;
        
        if (req.pwrite) begin
            vif.drv_cb.PWDATA <= req.pwdata;
            `uvm_info("APB_DRV", $sformatf("Writing ADDR=0x%0h DATA=0x%0h", req.paddr, req.pwdata), UVM_HIGH)
        end else begin
            `uvm_info("APB_DRV", $sformatf("Reading ADDR=0x%0h", req.paddr), UVM_HIGH)
        end
        
        // ==============================================
        // ACCESS PHASE
        @(vif.drv_cb); 
        vif.drv_cb.PENABLE <= 1'b1;
        
        // Wait for the next clock edge, then check PREADY
        do begin
            @(vif.drv_cb);
        end while (vif.drv_cb.PREADY !== 1'b1);
        
        // Capture read data if this was a read transaction
        if (!req.pwrite) begin
            req.prdata = vif.drv_cb.PRDATA;
            `uvm_info("APB_DRV", $sformatf("Read DATA=0x%0h", req.prdata), UVM_HIGH)
        end
        
        // ==============================================
        // CLEANUP (Back to IDLE)
        // @(vif.drv_cb);
        vif.drv_cb.PSEL    <= 1'b0;
        vif.drv_cb.PENABLE <= 1'b0;
        vif.drv_cb.PWRITE  <= 1'b0;
    endtask
    
endclass
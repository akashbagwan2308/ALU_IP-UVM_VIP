//reset test
class alu_reset_test extends base_test;
    
    `uvm_component_utils(alu_reset_test)
    
    function new(string name = "alu_reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_add_sequence #(WIDTH)   add_seq;
        apb_read_sequence  #(WIDTH) rd_seq;
        
        phase.raise_objection(this);
        
        add_seq = alu_add_sequence#(WIDTH)::type_id::create("add_seq");
        rd_seq  = apb_read_sequence#(WIDTH)::type_id::create("rd_seq");
        
        `uvm_info("RST_TEST", "--- STARTING ON-THE-FLY RESET TEST ---", UVM_LOW)
        
        // 1. Run a normal operation to dirty the registers
        if (!add_seq.randomize() with { operand_a == 100; operand_b == 50; }) 
            `uvm_fatal("RST_TEST", "Randomization failed")
        add_seq.start(env.v_sqr.apb_seqr);
        
        // 2. Assert Hardware Reset directly via Virtual Interface
        `uvm_info("RST_TEST", "Asserting PRESET_n (Hardware Reset)...", UVM_LOW)
        cfg.apb_cfg.vif.PRESET_n <= 1'b0;
        #25ns;
        cfg.apb_cfg.vif.PRESET_n <= 1'b1;
        `uvm_info("RST_TEST", "De-asserting PRESET_n...", UVM_LOW)
        
        // 3. Allow some clock cycles to settle
        #20ns;
        
        // 4. Verify registers cleared
        rd_seq.addr = 8'h14; // RESULT register
        rd_seq.start(env.v_sqr.apb_seqr);
        if (rd_seq.read_data !== 8'h00)
            `uvm_error("RST_TEST", $sformatf("RESULT register did not clear on reset! Read: 0x%0h", rd_seq.read_data))
        else
            `uvm_info("RST_TEST", "RESULT register successfully cleared to 0x00", UVM_LOW)
            
        rd_seq.addr = 8'h10; // STATUS register
        rd_seq.start(env.v_sqr.apb_seqr);
        if (rd_seq.read_data !== 8'h00)
            `uvm_error("RST_TEST", $sformatf("STATUS register did not clear on reset! Read: 0x%0h", rd_seq.read_data))
        else
            `uvm_info("RST_TEST", "STATUS register successfully cleared to 0x00", UVM_LOW)
            
        `uvm_info("RST_TEST", "--- ON-THE-FLY RESET TEST COMPLETE ---", UVM_LOW)
        
        #50ns;
        phase.drop_objection(this);
    endtask
    
endclass
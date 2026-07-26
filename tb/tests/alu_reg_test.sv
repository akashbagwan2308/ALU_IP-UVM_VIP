//reg test
class alu_reg_test extends base_test;
    // Now this exact string is registered in the factory!
    `uvm_component_utils(alu_reg_test)
    
    function new(string name = "alu_reg_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        apb_write_sequence #(WIDTH) wr_seq;
        apb_read_sequence  #(WIDTH) rd_seq;
        
        // Test patterns to catch stuck-at faults (Walking 1s/0s or Alternating)
        bit [WIDTH-1:0] patterns[4] = '{8'hAA, 8'h55, 8'hFF, 8'h00};
        
        phase.raise_objection(this);
        
        wr_seq = apb_write_sequence#(WIDTH)::type_id::create("wr_seq");
        rd_seq = apb_read_sequence#(WIDTH)::type_id::create("rd_seq");
        
        `uvm_info("REG_TEST", "--- STARTING REGISTER INTEGRITY TEST ---", UVM_LOW)
        
        foreach (patterns[i]) begin
            // 1. Write to OPERAND_A
            wr_seq.addr = 8'h04; 
            wr_seq.data = patterns[i];
            wr_seq.start(env.v_sqr.apb_seqr);
            
            // 2. Read back OPERAND_A
            rd_seq.addr = 8'h04;
            rd_seq.start(env.v_sqr.apb_seqr);
            
            if (rd_seq.read_data !== patterns[i])
                `uvm_error("REG_TEST", $sformatf("Mismatch on OPERAND_A! Wrote: 0x%0h, Read: 0x%0h", patterns[i], rd_seq.read_data))
            else
                `uvm_info("REG_TEST", $sformatf("OPERAND_A matched pattern 0x%0h", patterns[i]), UVM_LOW)
                
            // 3. Write to OPERAND_B
            wr_seq.addr = 8'h08; 
            wr_seq.data = patterns[i];
            wr_seq.start(env.v_sqr.apb_seqr);
            
            // 4. Read back OPERAND_B
            rd_seq.addr = 8'h08;
            rd_seq.start(env.v_sqr.apb_seqr);
            
            if (rd_seq.read_data !== patterns[i])
                `uvm_error("REG_TEST", $sformatf("Mismatch on OPERAND_B! Wrote: 0x%0h, Read: 0x%0h", patterns[i], rd_seq.read_data))
            else
                `uvm_info("REG_TEST", $sformatf("OPERAND_B matched pattern 0x%0h", patterns[i]), UVM_LOW)
        end
        
        `uvm_info("REG_TEST", "--- REGISTER INTEGRITY TEST COMPLETE ---", UVM_LOW)
        
        #50ns;
        phase.drop_objection(this);
    endtask
    
endclass
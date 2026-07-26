//stress test
class alu_stress_test extends base_test;
    
    `uvm_component_utils(alu_stress_test)
    
    // High volume for stress testing
    int num_transactions = 2000; 
    
    function new(string name = "alu_stress_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_random_sequence #(WIDTH) rand_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("STRESS_TEST", $sformatf("--- STARTING ALU STRESS TEST (%0d iterations) ---", num_transactions), UVM_LOW)
        
        // Fire randomized operations back-to-back with zero delay between them
        for (int i = 0; i < num_transactions; i++) begin
            rand_seq = alu_random_sequence#(WIDTH)::type_id::create("rand_seq");
            
            if (!rand_seq.randomize()) begin
                `uvm_fatal("STRESS_TEST", "Randomization failed")
            end
            
            // Periodically print progress so the simulation log doesn't look dead
            if (i % 250 == 0 && i > 0) begin
                `uvm_info("STRESS_TEST", $sformatf("Completed %0d / %0d operations...", i, num_transactions), UVM_LOW)
            end
            
            rand_seq.start(env.v_sqr.apb_seqr);
        end
        
        `uvm_info("STRESS_TEST", "--- ALU STRESS TEST COMPLETE ---", UVM_LOW)
        
        #100ns;
        phase.drop_objection(this);
    endtask
    
endclass
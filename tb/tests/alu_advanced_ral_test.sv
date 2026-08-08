
class alu_advanced_ral_test extends base_test;
    `uvm_component_utils(alu_advanced_ral_test)

    function new(string name = "alu_advanced_ral_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        alu_advanced_ral_seq adv_ral_seq;
        
        phase.raise_objection(this);
        
        // 1. Create the advanced RAL sequence
        adv_ral_seq = alu_advanced_ral_seq::type_id::create("adv_ral_seq");
        
        // 2. Connect the sequence to the environment's Register Model
        // This is critical; otherwise, the sequence will throw a null handle error
        if (env.regmodel == null) begin
            `uvm_fatal("RAL_TEST", "Environment regmodel is null! Cannot pass to sequence.")
        end
        adv_ral_seq.regmodel = env.regmodel;
        
        `uvm_info("RAL_TEST", "--- Executing Advanced RAL Sequence ---", UVM_LOW)
        
        // 3. Start the sequence
        // We can pass 'null' for the sequencer because the RAL model itself 
        // already knows which sequencer to use (configured in env.connect_phase)
        adv_ral_seq.start(null); 
        
        // Allow time for any final bus transactions to complete
        #100ns;
        
        `uvm_info("RAL_TEST", "--- Advanced RAL Sequence Completed ---", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
endclass
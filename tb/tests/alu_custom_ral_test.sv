
class alu_custom_ral_test extends base_test;
    `uvm_component_utils(alu_custom_ral_test)

    function new(string name = "alu_custom_ral_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        alu_ral_sanity_seq sanity_seq;
        alu_ral_random_seq random_seq;
        
        phase.raise_objection(this);
        
        // Instantiate and start the Sanity Sequence
        sanity_seq = alu_ral_sanity_seq::type_id::create("sanity_seq");
        sanity_seq.regmodel = env.regmodel;
        `uvm_info("RAL_TEST", "--- Running Sanity RAL Sequence ---", UVM_LOW)
        sanity_seq.start(null); 
        
        // Instantiate and start the Random Sequence
        random_seq = alu_ral_random_seq::type_id::create("random_seq");
        random_seq.regmodel = env.regmodel;
        `uvm_info("RAL_TEST", "--- Running Random RAL Sequence ---", UVM_LOW)
        random_seq.start(null);
        
        #100ns;
        phase.drop_objection(this);
    endtask
endclass
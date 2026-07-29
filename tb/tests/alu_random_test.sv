//

class alu_random_test extends base_test;
    
    `uvm_component_utils(alu_random_test)
    
    function new(string name = "alu_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_random_sequence #(WIDTH) rand_seq;
        
        phase.raise_objection(this);
        
        // Fire 50 randomized operations
        repeat(50) begin
            rand_seq = alu_random_sequence#(WIDTH)::type_id::create("rand_seq");
            if (!rand_seq.randomize()) `uvm_error("TEST", "Randomization failed")
            rand_seq.start(env.v_sqr.apb_seqr);
        end
        
        #100ns;
        phase.drop_objection(this);
    endtask
    
endclass
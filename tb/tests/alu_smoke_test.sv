//
class alu_smoke_test extends base_test;
    
    `uvm_component_param_utils(alu_smoke_test)
    
    function new(string name = "alu_smoke_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_add_sequence #(WIDTH) add_seq;
        
        phase.raise_objection(this);
        
        add_seq = alu_add_sequence#(WIDTH)::type_id::create("add_seq");
        if (!add_seq.randomize() with { operand_a == 20; operand_b == 10; }) 
            `uvm_error("TEST", "Randomization failed")
            
        add_seq.start(env.v_sqr.apb_seqr);
        
        #100ns;
        phase.drop_objection(this);
    endtask
    
endclass
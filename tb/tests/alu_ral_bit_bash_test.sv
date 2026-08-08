
class alu_ral_bit_bash_test extends base_test;
    `uvm_component_utils(alu_ral_bit_bash_test)

    function new(string name = "alu_ral_bit_bash_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        uvm_reg_bit_bash_seq ral_bit_bash_seq;
        
        phase.raise_objection(this);
        
        ral_bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("ral_bit_bash_seq");
        ral_bit_bash_seq.model = env.regmodel;
        
        `uvm_info("RAL_TEST", "Starting Built-in Bit Bash Sequence...", UVM_LOW)
        ral_bit_bash_seq.start(null);
        
        #50ns;
        phase.drop_objection(this);
    endtask
endclass

class alu_ral_access_test extends base_test;
    `uvm_component_utils(alu_ral_access_test)

    function new(string name = "alu_ral_access_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        uvm_reg_access_seq ral_access_seq;
        
        phase.raise_objection(this);
        
        ral_access_seq = uvm_reg_access_seq::type_id::create("ral_access_seq");
        ral_access_seq.model = env.regmodel;
        
        `uvm_info("RAL_TEST", "Starting Built-in Register Access Sequence...", UVM_LOW)
        ral_access_seq.start(null);
        
        #50ns;
        phase.drop_objection(this);
    endtask
endclass

class alu_ral_hw_reset_test extends base_test;
    `uvm_component_utils(alu_ral_hw_reset_test)

    function new(string name = "alu_ral_hw_reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        uvm_reg_hw_reset_seq ral_reset_seq;
        
        phase.raise_objection(this);
        
        // Assert system reset here via virtual interface before running sequence
        // env.apb_agt.vif.presetn = 0; #20ns; env.apb_agt.vif.presetn = 1; #20ns;

        ral_reset_seq = uvm_reg_hw_reset_seq::type_id::create("ral_reset_seq");
        ral_reset_seq.model = env.regmodel;
        
        `uvm_info("RAL_TEST", "Starting Built-in HW Reset Sequence...", UVM_LOW)
        ral_reset_seq.start(null);
        
        #50ns;
        phase.drop_objection(this);
    endtask
endclass
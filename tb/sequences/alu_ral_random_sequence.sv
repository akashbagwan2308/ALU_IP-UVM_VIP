
class alu_ral_random_seq extends uvm_sequence;
    `uvm_object_utils(alu_ral_random_seq)
    
    alu_reg_block regmodel;

    function new(string name = "alu_ral_random_seq");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;

        if (regmodel == null) `uvm_fatal("RAL_SEQ", "Register model handle is null!")

        repeat(10) begin
            // Randomize all RW registers in the block
            if (!regmodel.randomize()) begin
                `uvm_error("RAL_SEQ", "Failed to randomize register model")
            end
            
            // Ensure soft_reset is not accidentally toggled during normal randomized operation
            regmodel.ctrl.soft_reset.set(1'b0);

            // .update() will iterate through all registers and issue APB writes 
            // for any register where the desired value != mirrored value.
            `uvm_info("RAL_SEQ", "Updating register model with randomized values...", UVM_HIGH)
            regmodel.update(status);
            
            if (status != UVM_IS_OK) begin
                `uvm_error("RAL_SEQ", "Register update failed!")
            end
        end
    endtask
endclass
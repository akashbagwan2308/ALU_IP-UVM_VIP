
class alu_ral_sanity_seq extends uvm_sequence;
    `uvm_object_utils(alu_ral_sanity_seq)
    
    alu_reg_block regmodel;

    function new(string name = "alu_ral_sanity_seq");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e   status;
        uvm_reg_data_t rdata;

        if (regmodel == null) `uvm_fatal("RAL_SEQ", "Register model handle is null!")

        // 1. Write and Read OPERAND_A
        regmodel.operand_a.write(status, 8'h5A, UVM_FRONTDOOR);
        regmodel.operand_a.read(status, rdata, UVM_FRONTDOOR);
        if (rdata !== 8'h5A) `uvm_error("RAL_SEQ", $sformatf("OPERAND_A mismatch! Expected: 5A, Actual: %0h", rdata))

        // 2. Write and Read OPERAND_B
        regmodel.operand_b.write(status, 8'hA5, UVM_FRONTDOOR);
        regmodel.operand_b.read(status, rdata, UVM_FRONTDOOR);
        if (rdata !== 8'hA5) `uvm_error("RAL_SEQ", $sformatf("OPERAND_B mismatch! Expected: A5, Actual: %0h", rdata))

        // 3. Write OPCODE (e.g., ADD = 4'b0000)
        regmodel.opcode.write(status, 4'h0, UVM_FRONTDOOR);

        // 4. Assert START bit in CTRL register
        regmodel.ctrl.start.set(1'b1);
        regmodel.ctrl.update(status); // .update() writes only if the desired value differs from mirrored value
    endtask
endclass
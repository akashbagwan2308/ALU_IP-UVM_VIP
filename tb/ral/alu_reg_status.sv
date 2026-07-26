//status
class alu_reg_status extends uvm_reg;
    `uvm_object_utils(alu_reg_status)

    uvm_reg_field valid;
    uvm_reg_field done;
    uvm_reg_field busy;
    uvm_reg_field carry;
    uvm_reg_field negative;
    uvm_reg_field overflow;
    uvm_reg_field zero;
    uvm_reg_field gt;
    uvm_reg_field eq;

    function new(string name = "alu_reg_status");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        valid    = uvm_reg_field::type_id::create("valid");
        done     = uvm_reg_field::type_id::create("done");
        busy     = uvm_reg_field::type_id::create("busy");
        carry    = uvm_reg_field::type_id::create("carry");
        negative = uvm_reg_field::type_id::create("negative");
        overflow = uvm_reg_field::type_id::create("overflow");
        zero     = uvm_reg_field::type_id::create("zero");
        gt       = uvm_reg_field::type_id::create("gt");
        eq       = uvm_reg_field::type_id::create("eq");

        // configured as "RO" (Read-Only) and Volatile (can change outside of APB transactions)
        valid.configure   (this, 1, 0, "RO", 1, 1'b0, 1, 0, 0);
        done.configure    (this, 1, 1, "RO", 1, 1'b0, 1, 0, 0);
        busy.configure    (this, 1, 2, "RO", 1, 1'b0, 1, 0, 0);
        carry.configure   (this, 1, 3, "RO", 1, 1'b0, 1, 0, 0);
        negative.configure(this, 1, 4, "RO", 1, 1'b0, 1, 0, 0);
        overflow.configure(this, 1, 5, "RO", 1, 1'b0, 1, 0, 0);
        zero.configure    (this, 1, 6, "RO", 1, 1'b0, 1, 0, 0);
        gt.configure      (this, 1, 7, "RO", 1, 1'b0, 1, 0, 0);
        eq.configure      (this, 1, 8, "RO", 1, 1'b0, 1, 0, 0);
    endfunction
endclass
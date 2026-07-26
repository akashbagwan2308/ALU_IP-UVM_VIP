//ctrl 
class alu_reg_ctrl extends uvm_reg;
    `uvm_object_utils(alu_reg_ctrl)

    rand uvm_reg_field start;
    rand uvm_reg_field soft_reset;

    function new(string name = "alu_reg_ctrl");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        start = uvm_reg_field::type_id::create("start");
        // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
        start.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);

        soft_reset = uvm_reg_field::type_id::create("soft_reset");
        soft_reset.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
    endfunction
endclass
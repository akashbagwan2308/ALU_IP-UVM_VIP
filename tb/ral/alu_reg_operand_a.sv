//operand a
class alu_reg_operand_a extends uvm_reg;
    `uvm_object_utils(alu_reg_operand_a)

    rand uvm_reg_field val;

    function new(string name = "alu_reg_operand_a");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        val = uvm_reg_field::type_id::create("val");
        val.configure(this, 8, 0, "RW", 0, 8'h00, 1, 1, 0);
    endfunction
endclass
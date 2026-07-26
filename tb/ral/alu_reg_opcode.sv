//opcode
class alu_reg_opcode extends uvm_reg;
    `uvm_object_utils(alu_reg_opcode)

    rand uvm_reg_field op;

    function new(string name = "alu_reg_opcode");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        op = uvm_reg_field::type_id::create("op");
        op.configure(this, 4, 0, "RW", 0, 4'h0, 1, 1, 0);
    endfunction
endclass
//result
class alu_reg_result extends uvm_reg;
    `uvm_object_utils(alu_reg_result)

    uvm_reg_field res;

    function new(string name = "alu_reg_result");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        res = uvm_reg_field::type_id::create("res");
        res.configure(this, 8, 0, "RO", 1, 8'h00, 1, 0, 0);
    endfunction
endclass
//reg block
class alu_reg_block extends uvm_reg_block;
    `uvm_object_utils(alu_reg_block)

    // Register instances
    rand alu_reg_ctrl      ctrl;
    rand alu_reg_operand_a operand_a;
    rand alu_reg_operand_b operand_b;
    rand alu_reg_opcode    opcode;
         alu_reg_status    status;
         alu_reg_result    result;

    function new(string name = "alu_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        // 1. Create the Default Memory Map
        // name, base_address, bus_width_in_bytes, endianness
        default_map = create_map("default_map", 0, 1, UVM_LITTLE_ENDIAN);

        // 2. Create and configure registers
        ctrl = alu_reg_ctrl::type_id::create("ctrl");
        ctrl.configure(this, null, "");
        ctrl.build();
        default_map.add_reg(ctrl, 8'h00, "RW");

        operand_a = alu_reg_operand_a::type_id::create("operand_a");
        operand_a.configure(this, null, "");
        operand_a.build();
        default_map.add_reg(operand_a, 8'h04, "RW");

        operand_b = alu_reg_operand_b::type_id::create("operand_b");
        operand_b.configure(this, null, "");
        operand_b.build();
        default_map.add_reg(operand_b, 8'h08, "RW");

        opcode = alu_reg_opcode::type_id::create("opcode");
        opcode.configure(this, null, "");
        opcode.build();
        default_map.add_reg(opcode, 8'h0C, "RW");

        status = alu_reg_status::type_id::create("status");
        status.configure(this, null, "");
        status.build();
        default_map.add_reg(status, 8'h10, "RO");

        result = alu_reg_result::type_id::create("result");
        result.configure(this, null, "");
        result.build();
        default_map.add_reg(result, 8'h14, "RO");

        lock_model();
    endfunction
endclass
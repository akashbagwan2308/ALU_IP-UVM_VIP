//transation class
// `ifndef APB_TRANSACTION_SV
// `define APB_TRANSACTION_SV

class transaction #(parameter WIDTH = 8) extends uvm_sequence_item;
    

    rand bit             pwrite;
    rand bit [WIDTH-1:0] paddr;
    rand bit [WIDTH-1:0] pwdata;

         bit [WIDTH-1:0] prdata;
         bit             pready;
    rand int unsigned    delay;

    constraint c_delay { delay inside {[0:5]};}

    constraint c_addr
    {  paddr inside
        {
            8'h00,   // CTRL
            8'h04,   // OPERAND_A
            8'h08,   // OPERAND_B
            8'h0C,   // OPCODE
            8'h10,   // STATUS
            8'h14    // RESULT
        };
    }

    `uvm_object_param_utils_begin(transaction #(WIDTH))
        `uvm_field_int(pwrite, UVM_ALL_ON)
        `uvm_field_int(paddr, UVM_ALL_ON)
        `uvm_field_int(pwdata, UVM_ALL_ON)
        `uvm_field_int(prdata, UVM_ALL_ON)
        `uvm_field_int(pready, UVM_ALL_ON)
        `uvm_field_int(delay , UVM_ALL_ON)
    `uvm_object_utils_end

    

    function new(string name = "transaction");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "PWRITE=%0b ADDR=0x%0h WDATA=0x%0h RDATA=0x%0h PREADY=%0b",
             pwrite, paddr, pwdata, prdata, pready
        );
    endfunction

endclass

// `endif
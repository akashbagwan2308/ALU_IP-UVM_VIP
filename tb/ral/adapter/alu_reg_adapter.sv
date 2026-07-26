//adapter
class alu_reg_adapter #(parameter WIDTH = 8) extends uvm_reg_adapter;
    
    `uvm_object_param_utils(alu_reg_adapter #(WIDTH))
    
    function new(string name = "alu_reg_adapter");
        super.new(name);
        supports_byte_enable = 0;
        provides_responses   = 0;
    endfunction
    
    // Converts generic UVM register transaction to your APB transaction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        transaction #(WIDTH) trans = transaction#(WIDTH)::type_id::create("trans");
        
        trans.pwrite = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;
        trans.paddr  = rw.addr;
        trans.pwdata = rw.data;
        
        return trans;
    endfunction
    
    // Converts your APB transaction back into a generic UVM register transaction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        transaction #(WIDTH) trans;
        
        if (!$cast(trans, bus_item)) begin
            `uvm_fatal("ADAPT_ERR", "Provided bus_item is not of type transaction")
        end
        
        rw.kind   = trans.pwrite ? UVM_WRITE : UVM_READ;
        rw.addr   = trans.paddr;
        rw.data   = trans.pwrite ? trans.pwdata : trans.prdata;
        rw.status = UVM_IS_OK;
    endfunction
    
endclass
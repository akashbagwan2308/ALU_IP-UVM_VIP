// write sequence
class apb_write_sequence #(parameter WIDTH = 8) extends base_sequence #(WIDTH);
    
    `uvm_object_param_utils(apb_write_sequence #(WIDTH))
    
    rand bit [WIDTH-1:0] addr;
    rand bit [WIDTH-1:0] data;
    
    function new(string name = "apb_write_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        req = transaction#(WIDTH)::type_id::create("req");
        
        start_item(req);
        if (!req.randomize() with {
            pwrite == 1'b1;
            paddr  == local::addr;
            pwdata == local::data;
        }) `uvm_fatal("SEQ", "Randomization failed for APB Write")
        finish_item(req);
    endtask
    
endclass
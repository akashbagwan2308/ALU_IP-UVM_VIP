// read sequence
class apb_read_sequence #(parameter WIDTH = 8) extends base_sequence #(WIDTH);
    
    `uvm_object_param_utils(apb_read_sequence #(WIDTH))
    
    rand bit [WIDTH-1:0] addr;
    bit      [WIDTH-1:0] read_data;
    
    function new(string name = "apb_read_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        req = transaction#(WIDTH)::type_id::create("req");
        
        start_item(req);
        if (!req.randomize() with {
            pwrite == 1'b0;
            paddr  == local::addr;
        }) `uvm_fatal("SEQ", "Randomization failed for APB Read")
        finish_item(req);
        
        // Capture the read data returned by the monitor/driver
        read_data = req.prdata; 
    endtask
    
endclass
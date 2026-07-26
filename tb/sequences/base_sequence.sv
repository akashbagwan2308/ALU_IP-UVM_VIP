//base sequence
class base_sequence #(parameter WIDTH = 8) extends uvm_sequence #(transaction #(WIDTH));
    
    `uvm_object_param_utils(base_sequence #(WIDTH))
    
    function new(string name = "base_sequence");
        super.new(name);
    endfunction
    
endclass
//sequencer

class apb_sequencer #(parameter WIDTH = 8) extends uvm_sequencer #(transaction #(WIDTH));
    
    // Register the sequencer in the UVM Factory
    `uvm_component_param_utils(apb_sequencer #(WIDTH))
    
    // Standard UVM Component Constructor
    function new(string name = "apb_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass
//virtual sequencer
class virtual_sequencer #(parameter WIDTH = 8) extends uvm_sequencer;
    `uvm_component_param_utils(virtual_sequencer #(WIDTH))
    // Handles to physical sequencers
    apb_sequencer #(WIDTH) apb_seqr;
    
    function new(string name = "virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass
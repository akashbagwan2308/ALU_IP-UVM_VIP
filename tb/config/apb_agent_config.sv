// config agent 
class apb_agent_config #(parameter WIDTH = 8) extends uvm_object;
    
    `uvm_object_param_utils(apb_agent_config #(WIDTH))
    
    // Virtual interface handle for the agent's sub-components
    virtual apb_inft #(WIDTH) vif;
    
    // Determines if the driver/sequencer should be created
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    
    function new(string name = "apb_agent_config");
        super.new(name);
    endfunction
    
endclass
//env config
class env_config #(parameter WIDTH = 8) extends uvm_object;
    
    `uvm_object_param_utils(env_config #(WIDTH))
    
    // Agent configurations
    apb_agent_config #(WIDTH) apb_cfg;
    
    // Environment control knobs
    bit has_scoreboard = 1;
    bit has_coverage   = 1;
    
    function new(string name = "env_config");
        super.new(name);
    endfunction
    
endclass
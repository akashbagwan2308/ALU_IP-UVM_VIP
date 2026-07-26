// The predictor is essentially a typedef of the built-in uvm_reg_predictor,
// parameterized with your specific transaction type.
class alu_predictor #(parameter WIDTH = 8) extends uvm_reg_predictor #(transaction #(WIDTH));
    
    `uvm_component_param_utils(alu_predictor #(WIDTH))
    
    function new(string name = "alu_predictor", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass
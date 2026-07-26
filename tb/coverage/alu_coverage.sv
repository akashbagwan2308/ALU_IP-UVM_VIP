// coverage
class alu_coverage #(parameter WIDTH = 8) extends uvm_subscriber #(transaction #(WIDTH));
    
    `uvm_component_param_utils(alu_coverage #(WIDTH))
    
    // Shadow registers for coverage
    bit [WIDTH-1:0] cov_A;
    bit [WIDTH-1:0] cov_B;
    bit [3:0]       cov_Op;
    
    covergroup alu_cg;
        option.per_instance = 1;
        
        cp_opcode: coverpoint cov_Op {
            bins arith[]    = {[0:3]};
            bins shift[]    = {[4:7]};
            bins logical[]  = {[8:13]};
            bins comp[]     = {[14:15]};
        }
        
        cp_A: coverpoint cov_A {
            bins zero   = {0};
            bins max    = {{WIDTH{1'b1}}};
            bins others = default;
        }
        
        cp_B: coverpoint cov_B {
            bins zero   = {0};
            bins max    = {{WIDTH{1'b1}}};
            bins others = default;
        }
        
        cross_op_a_b: cross cp_opcode, cp_A, cp_B;
    endgroup
    
    function new(string name = "alu_coverage", uvm_component parent = null);
        super.new(name, parent);
        alu_cg = new();
    endfunction
    
    virtual function void write(transaction #(WIDTH) t);
        if (t.pwrite) begin
            if (t.paddr == 'h04) cov_A = t.pwdata;
            if (t.paddr == 'h08) cov_B = t.pwdata;
            if (t.paddr == 'h0C) cov_Op = t.pwdata[3:0];
            
            // Sample when START is triggered
            if (t.paddr == 'h00 && t.pwdata[0] == 1'b1) begin
                alu_cg.sample();
            end
        end
    endfunction
    
endclass
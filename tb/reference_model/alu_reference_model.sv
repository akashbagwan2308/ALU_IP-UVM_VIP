///
class alu_reference_model #(parameter WIDTH = 8) extends uvm_object;
    
    `uvm_object_param_utils(alu_reference_model #(WIDTH))
    
    function new(string name = "alu_reference_model");
        super.new(name);
    endfunction
    
    // Golden mathematical calculation
    virtual function bit [WIDTH-1:0] calc_expected(bit [WIDTH-1:0] a, bit [WIDTH-1:0] b, bit [3:0] op);
        bit [WIDTH-1:0] rot_amt;
        bit [WIDTH-1:0] expected;

        bit [WIDTH-1:0] rol;
        bit [WIDTH-1:0] ror;

        repeat(b)begin rol = {a[WIDTH-2:0],a[WIDTH-1]};end
        repeat(b)begin ror = {a[0],a[WIDTH-1:1]}; end
        // rot_amt = b % WIDTH;
        case(op)
            4'h0: expected = a + b;
            4'h1: expected = a - b;
            4'h2: expected = a * b;
            4'h3: expected = (b == 0) ? {WIDTH{1'b0}} : (a / b);
            4'h4: expected = a << b;
            4'h5: expected = a >> b;
            4'h6: expected = rol;
            4'h7: expected = ror;
            4'h8: expected = a & b;
            4'h9: expected = a | b;
            4'hA: expected = a ^ b;
            4'hB: expected = ~(a ^ b);
            4'hC: expected = ~(a & b);
            4'hD: expected = ~(a | b);
            4'hE: expected = (a > b)  ? {{WIDTH-1{1'b0}}, 1'b1} : {WIDTH{1'b0}};
            4'hF: expected = (a == b) ? {{WIDTH-1{1'b0}}, 1'b1} : {WIDTH{1'b0}};
            default: expected = {WIDTH{1'b0}};
        endcase
        return expected;
    endfunction
    
endclass
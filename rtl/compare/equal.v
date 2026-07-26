//equal
module equal #(parameter WIDTH = 8)
(   input                  eq_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output                 eq
);

wire eq_result;
assign eq_result = (a == b);    
assign eq = (eq_en) ? eq_result : 1'b0;
endmodule
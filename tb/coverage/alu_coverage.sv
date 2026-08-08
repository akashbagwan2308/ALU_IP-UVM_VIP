// coverage
class alu_coverage #(parameter WIDTH = 8) extends uvm_subscriber #(transaction #(WIDTH));
    
    `uvm_component_param_utils(alu_coverage #(WIDTH))
    
    // Shadow registers for coverage
    bit [WIDTH-1:0] cov_A;
    bit [WIDTH-1:0] cov_B;
    bit [3:0]       cov_Op;
    
    covergroup alu_cg;
        option.per_instance = 1;
        option.name = "alu_functional_coverage";
        
        // -------------------------------------------------------------
        // 1. OPCODE COVERAGE
        // -------------------------------------------------------------
        cp_opcode: coverpoint cov_Op {
            // Individual Instruction Bins
            bins op_ADD  = {4'h0};
            bins op_SUB  = {4'h1};
            bins op_MUL  = {4'h2};
            bins op_DIV  = {4'h3};
            bins op_SHL  = {4'h4};
            bins op_SHR  = {4'h5};
            bins op_ROL  = {4'h6};
            bins op_ROR  = {4'h7};
            bins op_AND  = {4'h8};
            bins op_OR   = {4'h9};
            bins op_XOR  = {4'hA};
            bins op_XNOR = {4'hB};
            bins op_NAND = {4'hC};
            bins op_NOR  = {4'hD};
            bins op_GT   = {4'hE};
            bins op_EQ   = {4'hF};

            // Transition Bins (Back-to-back operations)
            bins b2b_add = (4'h0 => 4'h0);
            bins b2b_sub = (4'h1 => 4'h1);
            
            // Group Transitions
            bins arith_to_logic = ([4'h0:4'h3] => [4'h8:4'hB]);
            bins logic_to_arith = ([4'h8:4'hB] => [4'h0:4'h3]);
        }
        
        // -------------------------------------------------------------
        // 2. OPERAND A COVERAGE
        // -------------------------------------------------------------
        cp_A: coverpoint cov_A {
            bins all_zeros   = {0};
            bins all_ones    = { {WIDTH{1'b1}} };               // e.g., 0xFF
            bins alt_1010    = { {WIDTH/2{2'b10}} };            // e.g., 0xAA (Walking patterns)
            bins alt_0101    = { {WIDTH/2{2'b01}} };            // e.g., 0x55 (Walking patterns)
            bins lsb_only    = { 1 };                           // e.g., 0x01
            bins msb_only    = { 1 << (WIDTH-1) };              // e.g., 0x80 (Sign bit triggers)
            bins others      = default;
        }
        
        // -------------------------------------------------------------
        // 3. OPERAND B COVERAGE
        // -------------------------------------------------------------
        cp_B: coverpoint cov_B {
            bins all_zeros   = {0};
            bins all_ones    = { {WIDTH{1'b1}} };               // e.g., 0xFF
            bins alt_1010    = { {WIDTH/2{2'b10}} };            // e.g., 0xAA
            bins alt_0101    = { {WIDTH/2{2'b01}} };            // e.g., 0x55
            bins lsb_only    = { 1 };                           // e.g., 0x01
            bins msb_only    = { 1 << (WIDTH-1) };              // e.g., 0x80
            bins others      = default;
        }
        
        // -------------------------------------------------------------
        // 4. STRATEGIC CROSS COVERAGE
        // -------------------------------------------------------------
        
        // Cross A: Ensure DIV is tested with a 0 denominator (Divide-by-Zero check)
        cross_div_by_zero: cross cp_opcode, cp_B {
            // Only care about DIV operation and B being zero
            ignore_bins non_div = binsof(cp_opcode) intersect {[4'h0:4'h2], [4'h4:4'hF]};
        }

        // Cross B: Arithmetic operations with maximum values (Testing Carry/Overflow flags)
        cross_arith_overflow: cross cp_opcode, cp_A, cp_B {
            // Ignore non-arithmetic operations for this specific cross
            ignore_bins non_arith = binsof(cp_opcode) intersect {[4'h4:4'hF]};
            
            // Focus heavily on all_ones intersecting with all_ones
            ignore_bins non_extreme = binsof(cp_A) intersect {0, 1, (1<<(WIDTH-1))} || 
                                      binsof(cp_B) intersect {0, 1, (1<<(WIDTH-1))};
        }

        // Cross C: Shifts and Rotates with specific bit patterns (Testing edge boundary shifts)
        cross_shift_patterns: cross cp_opcode, cp_A {
            // Only care about Shift/Rotate operations
            ignore_bins non_shift = binsof(cp_opcode) intersect {[4'h0:4'h3], [4'h8:4'hF]};
            // Focus on alternating patterns and single bits
            ignore_bins boring_data = binsof(cp_A) intersect {0, {WIDTH{1'b1}}};
        }
        
    endgroup
    
    function new(string name = "alu_coverage", uvm_component parent = null);
        super.new(name, parent);
        alu_cg = new();
    endfunction
    
    virtual function void write(transaction #(WIDTH) t);
        // Only track APB write operations for input coverage
        if (t.pwrite) begin
            case (t.paddr)
                'h04: cov_A  = t.pwdata;
                'h08: cov_B  = t.pwdata;
                'h0C: cov_Op = t.pwdata[3:0];
                
                // Sample coverage only when the START bit (bit 0 of CTRL reg at 'h00) is written high.
                // This ensures we only sample complete, intended operations.
                'h00: begin
                    if (t.pwdata[0] == 1'b1) begin
                        alu_cg.sample();
                        `uvm_info("COV_SAMPLED", $sformatf("Sampled Op: %0h, A: %0h, B: %0h", cov_Op, cov_A, cov_B), UVM_HIGH)
                    end
                end
            endcase
        end
    endfunction
    
endclass
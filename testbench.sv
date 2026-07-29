`timescale 1ns/1ns

module test;

parameter WIDTH = 8;

// Signals
reg                 CLK;
reg                 RST_N;
reg                 SEL;
reg                 ENABlE;
reg                 WRTIE;
reg  [WIDTH-1:0]    WDATA;
reg  [WIDTH-1:0]    ADDR;
wire [WIDTH-1:0]    RDATA;
wire                READY;
reg  [WIDTH-1:0]    RESULT; 

// Test Counters
integer pass_count = 0;
integer fail_count = 0;

// --------------------------------------------------------
// DUT Instantiation
// --------------------------------------------------------
alu_top #(.WIDTH(WIDTH)) DUT
(
    .CLK(CLK),
    .RST_N(RST_N),
    .SEL(SEL),
    .ENABlE(ENABlE),
    .WRTIE(WRTIE),
    .WDATA(WDATA),
    .ADDR(ADDR),
    .RDATA(RDATA),
    .READY(READY)
);

// --------------------------------------------------------
// Clock Generation
// --------------------------------------------------------
initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
end

// --------------------------------------------------------
// Initialization & Reset
// --------------------------------------------------------
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test);

    SEL     = 0;
    ENABlE  = 0;
    WRTIE   = 0;
    ADDR    = 0;
    WDATA   = 0;

    RST_N = 0;
    repeat(5) @(posedge CLK);
    RST_N = 1;
end

// --------------------------------------------------------
// APB Write Task
// --------------------------------------------------------
task apb_write;
    input [WIDTH-1:0] addr;
    input [WIDTH-1:0] data;
begin
    @(posedge CLK); #2;
    SEL     <= 1;
    ENABlE  <= 0;
    WRTIE   <= 1;
    ADDR    <= addr;
    WDATA   <= data;

    @(posedge CLK); #2;
    ENABlE <= 1;

    while(!READY)
        @(posedge CLK);

    @(posedge CLK);#2;
    $display("[%0t] WRITE ADDR=%h DATA=%h", $time, addr, data);
    SEL     <= 0;
    ENABlE  <= 0;
    WRTIE   <= 0;
    ADDR    <= 0;
    WDATA   <= 0;
end
endtask

// --------------------------------------------------------
// APB Read Task
// --------------------------------------------------------
task apb_read;
    input  [WIDTH-1:0] addr;
    output [WIDTH-1:0] data;
begin
    @(posedge CLK);#2;
    SEL     <= 1;
    ENABlE  <= 0;
    WRTIE   <= 0;
    ADDR    <= addr;

    @(posedge CLK);#2;
    ENABlE <= 1;

    while(!READY)
        @(posedge CLK);

    @(posedge CLK);#2;
    data = RDATA;
    $display("[%0t] READ  ADDR=%h DATA=%h", $time, addr, data);
    SEL     <= 0;
    ENABlE  <= 0;
    ADDR    <= 0;
end
endtask

// --------------------------------------------------------
// GOLDEN REFERENCE MODEL
// Calculates the expected result based on Verilog semantics
// --------------------------------------------------------
function [WIDTH-1:0] golden_model;
    input [WIDTH-1:0] a;
    input [WIDTH-1:0] b;
    input [3:0]       op;
    
    reg [WIDTH-1:0] rot_amt; 
    begin
        rot_amt = b % WIDTH; // Dynamically scale rotation based on WIDTH
        case(op)
            4'h0: golden_model = a + b;
            4'h1: golden_model = a - b;
            4'h2: golden_model = a * b;
            4'h3: golden_model = (b == 0) ? {WIDTH{1'b0}} : (a / b);
            4'h4: golden_model = a << b;
            4'h5: golden_model = a >> b;
            4'h6: golden_model = (a << rot_amt) | (a >> (WIDTH - rot_amt));
            4'h7: golden_model = (a >> rot_amt) | (a << (WIDTH - rot_amt));
            4'h8: golden_model = a & b;
            4'h9: golden_model = a | b;
            4'hA: golden_model = a ^ b;
            4'hB: golden_model = ~(a ^ b);
            4'hC: golden_model = ~(a & b);
            4'hD: golden_model = ~(a | b);
            4'hE: golden_model = (a > b)  ? {{WIDTH-1{1'b0}}, 1'b1} : {WIDTH{1'b0}};
            4'hF: golden_model = (a == b) ? {{WIDTH-1{1'b0}}, 1'b1} : {WIDTH{1'b0}};
            default: golden_model = {WIDTH{1'b0}};
        endcase
    end
endfunction

// --------------------------------------------------------
// ALU Operation Helper Task
// --------------------------------------------------------
task execute_alu_op;
    input [WIDTH-1:0]      a;
    input [WIDTH-1:0]      b;
    input [WIDTH-1:0]      op;
    input [8*10:1]         op_name; // String for readable display
    
    reg [WIDTH-1:0] status;
    reg [WIDTH-1:0] res;
    reg [WIDTH-1:0] expected_res;
begin
    $display("========================================");
    $display("[%0t] Starting %0s : A = %0d (0x%h), B = %0d (0x%h)", $time, op_name, a, a, b, b);
    
    // 1. Program Operands and Opcode
    apb_write('h04, a);     // Write OPERAND_A
    apb_write('h08, b);     // Write OPERAND_B
    apb_write('h0C, op);    // Write OPCODE
    
    // 2. Assert START bit
    apb_write('h00, 'h01);  // Write CTRL

    // 3. Poll STATUS register until DONE bit (bit 1) is set
    status = {WIDTH{1'b0}};
    while (status[1] == 1'b0) begin
        apb_read('h10, status); 
    end

    // 4. Read RESULT
    apb_read('h14, res);
    RESULT = res;
    
    // 5. Compare with Reference Model
    expected_res = golden_model(a, b, op[3:0]);
    
    if (res === expected_res) begin
        $display("[%0t] >>> PASS: %0s RESULT = %0d (0x%h) <<<", $time, op_name, res, res);
        pass_count = pass_count + 1;
    end else begin
        $display("[%0t] >>> FAIL: %0s EXPECTED = %0d (0x%h) | ACTUAL = %0d (0x%h) <<<", $time, op_name, expected_res, expected_res, res, res);
        fail_count = fail_count + 1;
    end
    
    $display("========================================\n");
end
endtask

// --------------------------------------------------------
// Main Stimulus
// --------------------------------------------------------
initial begin
    wait(RST_N);
    repeat(5) @(posedge CLK);

    $display("\n--- BEGINNING ALL 16 ALU OPERATIONS ---\n");

    // ARITHMETIC OPERATIONS
    execute_alu_op('d20,   'd10,  'h00, "ADD");
    execute_alu_op('d50,   'd15,  'h01, "SUB");
    execute_alu_op('d12,   'd4,   'h02, "MUL");
    execute_alu_op('d100,  'd5,   'h03, "DIV");
    
    // SHIFT & ROTATE OPERATIONS
    execute_alu_op('d1,    'd3,   'h04, "SHL"); 
    execute_alu_op('d32,   'd2,   'h05, "SHR"); 
    execute_alu_op('h81,   'd1,   'h06, "ROL"); 
    execute_alu_op('h81,   'd1,   'h07, "ROR"); 

    // LOGICAL OPERATIONS
    execute_alu_op('hFF,   'h0F,  'h08, "AND");
    execute_alu_op('h50,   'h0A,  'h09, "OR");
    execute_alu_op('hFF,   'h55,  'h0A, "XOR");
    execute_alu_op('hFF,   'h55,  'h0B, "XNOR");
    execute_alu_op('hFF,   'h0F,  'h0C, "NAND");
    execute_alu_op('h0F,   'hF0,  'h0D, "NOR");
    
    // COMPARE OPERATIONS
    execute_alu_op('d45,   'd40,  'h0E, "GT");  
    execute_alu_op('d42,   'd42,  'h0F, "EQ");

    #100;
    
    // Final Reporting
    $display("\n----------------------------------------");
    $display("           TEST RESULTS SUMMARY         ");
    $display("----------------------------------------");
    $display("TOTAL PASSED: %0d", pass_count);
    $display("TOTAL FAILED: %0d", fail_count);
    $display("----------------------------------------");
    
    if (fail_count == 0)
        $display("STATUS: SUCCESS! ALL TESTS PASSED.");
    else
        $display("STATUS: FAILURE! CHECK FAIL LOGS.");
    $display("----------------------------------------\n");

    $finish;
end

// --------------------------------------------------------
// Safety Timeout
// --------------------------------------------------------
initial begin 
    #50000;
    $display("\n[ERROR] Simulation timed out!\n");
    $finish;
end

endmodule
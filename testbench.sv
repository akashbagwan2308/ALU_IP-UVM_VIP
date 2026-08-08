`timescale 1ns/1ns

module test;

// --------------------------------------------------------
// Safety Timeout
// --------------------------------------------------------
initial begin 
    $dumpfile("dump.vcd");
    $dumpvars(0,test);
    #50000;
    $display("\n[ERROR] Simulation timed out!\n");
    $finish;
end

endmodule
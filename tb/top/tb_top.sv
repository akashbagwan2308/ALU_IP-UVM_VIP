`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../tb_include.vh"

// If you have all your classes compiled into a package, import it here:
// import alu_tb_pkg::*; 

module tb_top;

    parameter WIDTH = 8;

    // --------------------------------------------------------
    // Clock and Reset Signals
    // --------------------------------------------------------
    logic PCLK;
    logic PRESET_n;

    // Clock Generation (100MHz / 10ns period)
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    // Reset Generation
    initial begin
        PRESET_n = 0;
        repeat(5) @(posedge PCLK);
        PRESET_n = 1;
    end

    // --------------------------------------------------------
    // Interface Instantiation
    // --------------------------------------------------------
    // Instantiate the APB interface and drive its clock/reset
    apb_inft #(.WIDTH(WIDTH)) apb_if();
    
    assign apb_if.PCLK     = PCLK;
    assign apb_if.PRESET_n = PRESET_n;

    // --------------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------------
    // Connect the APB interface signals to your ALU Top
    alu_top #(.WIDTH(WIDTH)) DUT (
        .CLK    (apb_if.PCLK),
        .RST_N  (apb_if.PRESET_n),
        .SEL    (apb_if.PSEL),
        .ENABlE (apb_if.PENABLE),  // Using your exact spelling
        .WRTIE  (apb_if.PWRITE),   // Using your exact spelling
        .WDATA  (apb_if.PWDATA),
        .ADDR   (apb_if.PADDR),
        .RDATA  (apb_if.PRDATA),
        .READY  (apb_if.PREADY)
    );

    // --------------------------------------------------------
    // SVA Binding
    // --------------------------------------------------------
    // This injects the alu_sva module directly into the DUT hierarchy
    bind alu_top alu_sva #(.WIDTH(WIDTH)) sva_inst (
        .clk    (CLK),
        .rst_n  (RST_N),
        .sel    (SEL),
        .enable (ENABlE),
        .write  (WRTIE),
        .addr   (ADDR),
        .wdata  (WDATA),
        .ready  (READY),
        
        // Tapping into internal signals using hierarchical paths
        .ctrl   (ALU_CTRL),
        .busy   (BUSY_REG),
        .done   (DONE_REG)
    );

    // --------------------------------------------------------
    // UVM Setup and Execution
    // -------------------------------------------------------- 

    initial begin
        // 1. Dump waveforms for debugging
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

        // 2. Pass the virtual interface into the UVM Configuration Database
        // This allows your base_test (and ultimately your agent/driver) to grab it.
        uvm_config_db#(virtual apb_inft #(.WIDTH(WIDTH)))::set(null, "*", "vif", apb_if);

        // 3. Start the UVM Test
        // UVM will look at the +UVM_TESTNAME command line argument to decide which test to run.
        // run_test("alu_reg_test");
        // run_test("alu_reset_test");
        // run_test("alu_stress_test");
        // run_test("alu_smoke_test");
        run_test("alu_random_test");
    end
    initial begin
    #1;  // Small delay to ensure proper execution
    $display("*********************Topology******************************");
    uvm_top.print_topology();
  end

endmodule
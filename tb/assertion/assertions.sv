//assertion

module alu_sva #(parameter WIDTH = 8) (
    input logic             clk,
    input logic             rst_n,
    
    // APB Interface Signals
    input logic             sel,
    input logic             enable,
    input logic             write,
    input logic [WIDTH-1:0] addr,
    input logic [WIDTH-1:0] wdata,
    input logic             ready,
    
    // Internal ALU/Register Signals
    input logic [31:0]      ctrl,
    input logic             busy,
    input logic             done
);

    // =========================================================================
    // 1. APB PROTOCOL ASSERTIONS
    // =========================================================================
    
    // A1: Setup Phase must be followed by Access Phase
    // If PSEL is high and PENABLE is low, PENABLE MUST go high the very next cycle.
    property p_apb_setup_to_access;
        @(posedge clk) disable iff (!rst_n)
        (sel && !enable) |=> (sel && enable);
    endproperty
    assert_apb_setup_to_access: assert property(p_apb_setup_to_access) 
        else $error("[SVA] APB Violation: Setup phase not followed by Access phase!");

    // A2: Stable Signals During Access Phase
    // PADDR, PWRITE, and PWDATA (if write) must remain stable between Setup and Access.
    property p_apb_stable_control;
        @(posedge clk) disable iff (!rst_n)
        (sel && !enable) |=> ($stable(addr) && $stable(write));
    endproperty
    assert_apb_stable_control: assert property(p_apb_stable_control)
        else $error("[SVA] APB Violation: ADDR or PWRITE changed during Access phase!");

    property p_apb_stable_wdata;
        @(posedge clk) disable iff (!rst_n)
        (sel && !enable && write) |=> $stable(wdata);
    endproperty
    assert_apb_stable_wdata: assert property(p_apb_stable_wdata)
        else $error("[SVA] APB Violation: PWDATA changed during Access phase!");

    // A3: PENABLE must fall after PREADY is asserted
    // When a transaction completes (PREADY=1 during ACCESS), PENABLE must be de-asserted.
    property p_apb_enable_fall;
        @(posedge clk) disable iff (!rst_n)
        (sel && enable && ready) |=> (!enable);
    endproperty
    assert_apb_enable_fall: assert property(p_apb_enable_fall)
        else $error("[SVA] APB Violation: PENABLE did not drop after PREADY!");

    // =========================================================================
    // 2. ALU CORE & FSM ASSERTIONS
    // =========================================================================

    // B1: Start Trigger Response
    // If the CTRL[0] (start) bit is written to 1, the ALU must assert BUSY next cycle.
    property p_alu_start_triggers_busy;
        @(posedge clk) disable iff (!rst_n)
        ($rose(ctrl[0]) && !busy) |=> busy;
    endproperty
    assert_alu_start_triggers_busy: assert property(p_alu_start_triggers_busy)
        else $error("[SVA] ALU Violation: Start bit asserted, but ALU did not enter BUSY state!");

    // B2: ALU Execution Latency
    // Based on your FSM, the ALU takes exactly 2 cycles to compute.
    // If BUSY rises, it should remain high for exactly 2 cycles, followed by DONE.
    property p_alu_execution_timing;
        @(posedge clk) disable iff (!rst_n)
        $rose(busy) |-> (busy [*4] ##1 done);
    endproperty
    assert_alu_execution_timing: assert property(p_alu_execution_timing)
        else $error("[SVA] ALU Violation: Incorrect execution latency. Expected 4 cycles of BUSY followed by DONE.");

    // B3: DONE Signal is a Single-Cycle Pulse
    // The done signal should never stay high for more than one consecutive clock cycle.
    property p_alu_done_pulse;
        @(posedge clk) disable iff (!rst_n)
        $rose(done) |=> $fell(done);
    endproperty
    assert_alu_done_pulse: assert property(p_alu_done_pulse)
        else $error("[SVA] ALU Violation: DONE signal remained high for more than 1 cycle!");

    // B4: Start Bit Auto-Clears
    // When the ALU completes its operation (done=1), the register file must clear CTRL[0].
    property p_alu_start_autoclear;
        @(posedge clk) disable iff (!rst_n)
        done |=> (!ctrl[0]);
    endproperty
    assert_alu_start_autoclear: assert property(p_alu_start_autoclear)
        else $error("[SVA] REG Violation: CTRL[0] (Start bit) did not self-clear after DONE!");

    // B5: No DONE without BUSY
    // DONE should never assert out of nowhere; it must be preceded by a BUSY state.
    property p_alu_no_spurious_done;
        @(posedge clk) disable iff (!rst_n)
        done |-> $past(busy);
    endproperty
    assert_alu_no_spurious_done: assert property(p_alu_no_spurious_done)
        else $error("[SVA] ALU Violation: DONE asserted without preceding BUSY state!");

endmodule

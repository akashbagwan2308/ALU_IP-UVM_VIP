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
    // MASTER SVA MACRO DEFINITION
    // =========================================================================
    `define TRACK_ASSERTION(NAME, PROP, MSG_PASS, MSG_FAIL) \
        logic [1:0] assert_``NAME``_pass_fail = 0; \
        \
        track_``NAME: assert property (PROP) begin \
            $info(MSG_PASS); \
            assert_``NAME``_pass_fail <= 2'd2; \
        end else begin \
            $error(MSG_FAIL); \
            assert_``NAME``_pass_fail <= 2'd3; \
        end \
        \
        always @(negedge clk) begin \
            assert_``NAME``_pass_fail <= 0; \
        end

    // =========================================================================
    // 1. APB PROTOCOL ASSERTIONS
    // =========================================================================
    
    // A1: Setup Phase must be followed by Access Phase
    property p_apb_setup_to_access;
        @(posedge clk) disable iff (!rst_n)
        (sel && !enable) |=> (sel && enable);
    endproperty
    
    `TRACK_ASSERTION(p_apb_setup_to_access, p_apb_setup_to_access, 
        "[PASS] APB: Setup phase followed by Access phase", 
        "[SVA] APB Violation: Setup phase not followed by Access phase!")


    // A2: Stable Signals During Access Phase
    property p_apb_stable_control;
        @(posedge clk) disable iff (!rst_n)
        (sel && !enable) |=> ($stable(addr) && $stable(write));
    endproperty
    
    `TRACK_ASSERTION(p_apb_stable_control, p_apb_stable_control, 
        "[PASS] APB: ADDR and PWRITE stable during Access", 
        "[SVA] APB Violation: ADDR or PWRITE changed during Access phase!")


    property p_apb_stable_wdata;
        @(posedge clk) disable iff (!rst_n)
        (sel && !enable && write) |=> $stable(wdata);
    endproperty
    
    `TRACK_ASSERTION(p_apb_stable_wdata, p_apb_stable_wdata, 
        "[PASS] APB: PWDATA stable during Access", 
        "[SVA] APB Violation: PWDATA changed during Access phase!")


    // A3: PENABLE must fall after PREADY is asserted
    property p_apb_enable_fall;
        @(posedge clk) disable iff (!rst_n)
        (sel && enable && ready) |=> (!enable);
    endproperty
    
    `TRACK_ASSERTION(p_apb_enable_fall, p_apb_enable_fall, 
        "[PASS] APB: PENABLE dropped after PREADY", 
        "[SVA] APB Violation: PENABLE did not drop after PREADY!")

    // =========================================================================
    // 2. ALU CORE & FSM ASSERTIONS
    // =========================================================================

    // B1: Start Trigger Response
    property p_alu_start_triggers_busy;
        @(posedge clk) disable iff (!rst_n)
        ($rose(ctrl[0]) && !busy) |=> busy;
    endproperty
    
    `TRACK_ASSERTION(p_alu_start_triggers_busy, p_alu_start_triggers_busy, 
        "[PASS] ALU: Entered BUSY state after start bit", 
        "[SVA] ALU Violation: Start bit asserted, but ALU did not enter BUSY state!")


    // B2: ALU Execution Latency
    property p_alu_execution_timing;
        @(posedge clk) disable iff (!rst_n)
        $rose(busy) |-> (busy [*4] ##1 done);
    endproperty
    
    `TRACK_ASSERTION(p_alu_execution_timing, p_alu_execution_timing, 
        "[PASS] ALU: Execution latency exactly 4 cycles", 
        "[SVA] ALU Violation: Incorrect execution latency. Expected 4 cycles of BUSY followed by DONE.")


    // B3: DONE Signal is a Single-Cycle Pulse
    property p_alu_done_pulse;
        @(posedge clk) disable iff (!rst_n)
        $rose(done) |=> $fell(done);
    endproperty
    
    `TRACK_ASSERTION(p_alu_done_pulse, p_alu_done_pulse, 
        "[PASS] ALU: DONE signal generated perfect 1-cycle pulse", 
        "[SVA] ALU Violation: DONE signal remained high for more than 1 cycle!")


    // B4: Start Bit Auto-Clears
    property p_alu_start_autoclear;
        @(posedge clk) disable iff (!rst_n)
        done |=> (!ctrl[0]);
    endproperty
    
    `TRACK_ASSERTION(p_alu_start_autoclear, p_alu_start_autoclear, 
        "[PASS] REG: Start bit auto-cleared correctly", 
        "[SVA] REG Violation: CTRL[0] (Start bit) did not self-clear after DONE!")


    // B5: No DONE without BUSY
    property p_alu_no_spurious_done;
        @(posedge clk) disable iff (!rst_n)
        done |-> $past(busy);
    endproperty
    
    `TRACK_ASSERTION(p_alu_no_spurious_done, p_alu_no_spurious_done, 
        "[PASS] ALU: DONE signal legitimately preceded by BUSY", 
        "[SVA] ALU Violation: DONE asserted without preceding BUSY state!")

endmodule
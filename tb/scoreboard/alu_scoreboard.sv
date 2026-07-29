class alu_scoreboard #(parameter WIDTH = 8) extends uvm_scoreboard;
    
    `uvm_component_param_utils(alu_scoreboard #(WIDTH))
    
    uvm_analysis_imp #(transaction #(WIDTH), alu_scoreboard #(WIDTH)) item_collected_export;
    
    alu_reference_model #(WIDTH) ref_model;
    
    // 1. DECLARE THE VIRTUAL INTERFACE HERE
    virtual apb_inft #(WIDTH) vif;
    
    // Shadow registers
    bit [WIDTH-1:0] shadow_A;
    bit [WIDTH-1:0] shadow_B;
    bit [3:0]       shadow_Op;
    
    // Counters
    int pass_count = 0;
    int fail_count = 0;
    
    function new(string name = "alu_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_collected_export = new("item_collected_export", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ref_model = alu_reference_model#(WIDTH)::type_id::create("ref_model");
        
        // 2. RETRIEVE THE VIRTUAL INTERFACE FROM THE CONFIG DB
        if (!uvm_config_db#(virtual apb_inft #(WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("SCBD_VIF_ERR", "Virtual interface 'vif' not found in config_db")
        end
    endfunction


    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            // Wait specifically for the falling edge of the reset signal
            @(negedge vif.PRESET_n);
            
            `uvm_info("SCBD_RST", "Hardware Reset detected asynchronously! Clearing Shadow Registers.", UVM_NONE)
            shadow_A  = '0;
            shadow_B  = '0;
            shadow_Op = '0;
        end
    endtask
    
    virtual function void write(transaction #(WIDTH) trans);
        bit [WIDTH-1:0] expected_res;
      
        if (trans.pwrite) begin
            // Update shadow registers on write
            case (trans.paddr)
                'h04: shadow_A = trans.pwdata;
                'h08: shadow_B = trans.pwdata;
                'h0C: shadow_Op = trans.pwdata[3:0];
            endcase
        end else begin
            // Check result on read to RESULT register (0x14)
            if (trans.paddr == 'h14) begin
                expected_res = ref_model.calc_expected(shadow_A, shadow_B, shadow_Op);
                
                if (trans.prdata === expected_res) begin
                    `uvm_info("SCBD_PASS", $sformatf("OP=%0h | A=%0d, B=%0d | MATCH! Result=0x%0h", shadow_Op, shadow_A, shadow_B, trans.prdata), UVM_NONE)
                    pass_count++;
                end else begin
                    `uvm_error("SCBD_FAIL", $sformatf("OP=%0h | A=%0d, B=%0d | MISMATCH! Expected=0x%0h, Actual=0x%0h", shadow_Op, shadow_A, shadow_B, expected_res, trans.prdata))
                    fail_count++;
                end
            end
        end
    endfunction
    
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCBD_REPORT", $sformatf("\n--- SCOREBOARD SUMMARY ---\nPASSED: %0d\nFAILED: %0d\n--------------------------", pass_count, fail_count), UVM_NONE)
    endfunction
    
endclass
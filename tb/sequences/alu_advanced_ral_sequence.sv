// dedicated ral sequecnce for alu
class alu_advanced_ral_seq extends uvm_sequence;
    `uvm_object_utils(alu_advanced_ral_seq)
    
    // Handle to the Register Model
    alu_reg_block regmodel;

    function new(string name = "alu_advanced_ral_seq");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e   status;
        uvm_reg_data_t rdata;
        uvm_reg_data_t mirror_val;
        uvm_reg_data_t desired_val;

        if (regmodel == null) begin
            `uvm_fatal("RAL_SEQ", "Register model handle is null! Must be assigned from test.")
        end

        `uvm_info("RAL_SEQ", "--- STARTING ADVANCED RAL SEQUENCE ---", UVM_LOW)

        // --------------------------------------------------------------------
        // 1. FRONT-DOOR WRITE & READ (Physical bus transaction)
        // --------------------------------------------------------------------
        `uvm_info("RAL_SEQ", "1. Front-door access to OPERAND_A", UVM_LOW)
        regmodel.operand_a.write(status, 8'h42, UVM_FRONTDOOR);
        regmodel.operand_a.read(status, rdata, UVM_FRONTDOOR);
        if (rdata !== 8'h42) `uvm_error("RAL_SEQ", "Front-door read mismatch on OPERAND_A")

        // --------------------------------------------------------------------
        // 2. SET, GET, AND UPDATE (Mirror manipulation)
        // --------------------------------------------------------------------
        `uvm_info("RAL_SEQ", "2. Using set() and update() on OPERAND_B", UVM_LOW)
        // set() updates the "desired" value in the RAL model, but DOES NOT touch the physical bus.
        regmodel.operand_b.set(8'h99); 
        
        // get() returns the "desired" value currently stored in the RAL model.
        desired_val = regmodel.operand_b.get(); 
        `uvm_info("RAL_SEQ", $sformatf("Desired value of OPERAND_B is currently: 0x%0h", desired_val), UVM_LOW)

        // update() compares the "desired" value to the "mirrored" value. 
        // Since they differ, it triggers a physical front-door write to the bus.
        regmodel.operand_b.update(status); 

        // --------------------------------------------------------------------
        // 3. GET_MIRRORED_VALUE (Checking the model's tracked state)
        // --------------------------------------------------------------------
        `uvm_info("RAL_SEQ", "3. Checking mirrored value of OPERAND_B", UVM_LOW)
        // get_mirrored_value() returns what the RAL model *thinks* is in the DUT 
        // based on past transactions, without doing a physical read.
        mirror_val = regmodel.operand_b.get_mirrored_value();
        `uvm_info("RAL_SEQ", $sformatf("Mirrored value of OPERAND_B: 0x%0h", mirror_val), UVM_LOW)

        if (desired_val !== mirror_val) begin
            `uvm_error("RAL_SEQ", "Desired and Mirrored values should match after update()!")
        end

        // --------------------------------------------------------------------
        // 4. PREDICT (Manually updating the mirror)
        // --------------------------------------------------------------------
        `uvm_info("RAL_SEQ", "4. Manually predicting OPCODE state", UVM_LOW)
        // Sometimes you need to force the mirror to a specific value (e.g., after a hard reset)
        regmodel.opcode.predict(4'h5); 
        if (regmodel.opcode.get_mirrored_value() !== 4'h5) begin
             `uvm_error("RAL_SEQ", "Predict failed to update the mirrored value!")
        end

        // --------------------------------------------------------------------
        // 5. BACK-DOOR PEEK & POKE (Zero-time HDL path access)
        // Note: This requires HDL paths to be configured in your reg_block build() phase!
        // --------------------------------------------------------------------
        `uvm_info("RAL_SEQ", "5. Back-door peek/poke (Ensure HDL paths are set)", UVM_LOW)
        // poke() writes directly to the Verilog variable in zero time (no APB transaction)
        // regmodel.operand_a.poke(status, 8'hFF); 
        
        // peek() reads directly from the Verilog variable in zero time (no APB transaction)
        // regmodel.operand_a.peek(status, rdata); 

        `uvm_info("RAL_SEQ", "--- ADVANCED RAL SEQUENCE COMPLETE ---", UVM_LOW)
    endtask
endclass
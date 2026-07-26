//subtraction

class alu_sub_sequence #(parameter WIDTH = 8) extends base_sequence #(WIDTH);
    
    `uvm_object_param_utils(alu_sub_sequence #(WIDTH))
    
    rand bit [WIDTH-1:0] operand_a;
    rand bit [WIDTH-1:0] operand_b;
    
    function new(string name = "alu_sub_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        apb_write_sequence #(WIDTH) wr_seq = apb_write_sequence#(WIDTH)::type_id::create("wr_seq");
        apb_read_sequence  #(WIDTH) rd_seq = apb_read_sequence#(WIDTH)::type_id::create("rd_seq");
        
        wr_seq.addr = 8'h04; wr_seq.data = operand_a; wr_seq.start(m_sequencer);
        wr_seq.addr = 8'h08; wr_seq.data = operand_b; wr_seq.start(m_sequencer);
        
        // SUB Opcode
        wr_seq.addr = 8'h0C; wr_seq.data = 8'h01; wr_seq.start(m_sequencer);
        
        wr_seq.addr = 8'h00; wr_seq.data = 8'h01; wr_seq.start(m_sequencer);
        
        do begin
            rd_seq.addr = 8'h10;
            rd_seq.start(m_sequencer);
        end while (rd_seq.read_data[1] == 1'b0);
        
        rd_seq.addr = 8'h14;
        rd_seq.start(m_sequencer);
        
        `uvm_info("ALU_SUB_SEQ", $sformatf("Executed SUB: A=%0d, B=%0d, Result=%0d", operand_a, operand_b, rd_seq.read_data), UVM_MEDIUM)
    endtask
endclass
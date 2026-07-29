// APB SLAVE
module apb_slave #(parameter WIDTH = 8)(
    input                  PCLK,
    input                  PRESET_n,
    input                  PSEL,
    input                  PENABLE,
    input                  PWRITE,
    input      [WIDTH-1:0] PWDATA,
    input      [WIDTH-1:0] PADDR,
    output reg [WIDTH-1:0] PRDATA,
    output reg             PREADY,
    output reg             wr_en,
    output reg [WIDTH-1:0] wdata,
    output reg [WIDTH-1:0] addr,
    input      [WIDTH-1:0] rdata,
    input      [31:0]      status,
    input      [31:0]      result
);

// We don't strictly need this FSM for basic APB, but leaving it for your debug monitors
parameter IDLE   = 2'b00;
parameter SETUP  = 2'b01;
parameter ACCESS = 2'b11;

reg [1:0] PS, NS;

// 1. FSM State Register
always @(posedge PCLK, negedge PRESET_n)begin
    if(!PRESET_n)begin 
        PS <= IDLE; 
    end
    else begin
        PS <= NS;
    end
end

// 2. FSM Next-State Logic (Combinational)
always @(*) begin
    addr = PADDR; wdata = PWDATA; 
    case(PS)
        IDLE   : begin if(PSEL & !PENABLE) begin  NS = SETUP ; /*addr = PADDR; wdata = PWDATA;*/ end else NS = IDLE;    end
        SETUP  : begin if(PSEL & PENABLE) NS = ACCESS;  else if(PSEL & !PENABLE) NS = SETUP;  else NS = IDLE;  end
        ACCESS : begin
                    if(PREADY) begin
                        if(!PSEL)
                            NS = IDLE;
                        else
                            NS = SETUP;
                    end
                    else begin
                        NS = ACCESS;
                    end
                 end
        default : NS = IDLE;
    endcase
end

// ========================================================
// THE FIX: Combinational PREADY 
// ========================================================
always @(*) begin
    // If we are in the Access Phase (PSEL & PENABLE) and the ALU is BUSY (status[2]), 
    // stall the bus immediately by dropping PREADY to 0.
    if (PSEL && PENABLE && status[2]) begin
        PREADY = ~status[2];
    end else begin
        PREADY = ~status[2];
    end
end

// 3. Output and APB Transaction Logic
always @(posedge PCLK, negedge PRESET_n)begin
    if(!PRESET_n)begin 
        wr_en  <= 1'b0;
        addr   <= {WIDTH{1'b0}};
        wdata  <= {WIDTH{1'b0}};
        PRDATA <= {WIDTH{1'b0}};
    end
    else begin  
        // Default assignments
        wr_en  <= 1'b0; 
        // An APB transaction phase occurs precisely when PSEL and PENABLE are HIGH.
        // We only complete the read/write if the slave is NOT busy (!status[2]).
        if (PSEL && PENABLE && !status[2]) begin
            if (PWRITE) begin      // Write Transaction
                wr_en <= 1'b1;
            end 
            else begin             // Read Transaction
                // PRDATA = rdata;
            end
        end
    end
end

// always @(*) PRDATA = (!PWRITE && PSEL && PENABLE) ? rdata : {WIDTH{1'b0}}; // Read Transaction
always @(*) if(!PWRITE && PSEL && PENABLE) PRDATA =  rdata; // Read Transaction

// always @(posedge PCLK)
//     $strobe("[%0t] PS=%0d NS=%0d PSEL=%b PENABLE=%b PWRITE=%b",
//              $time, PS, NS, PSEL, PENABLE, PWRITE);

endmodule
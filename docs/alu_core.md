flowchart LR

&#x20;   %% Inputs

&#x20;   subgraph Inputs

&#x20;       IN\_A("A \[WIDTH-1:0]")

&#x20;       IN\_B("B \[WIDTH-1:0]")

&#x20;       IN\_OP("opcode \[3:0]")

&#x20;       IN\_START(start)

&#x20;       IN\_CLK(clk)

&#x20;       IN\_RST(rst\_n)

&#x20;   end



&#x20;   %% Decoder

&#x20;   DEC\[OPCODE DECODER]

&#x20;   IN\_OP --> DEC

&#x20;   IN\_START --> DEC



&#x20;   %% Functional Units

&#x20;   subgraph Arithmetic Units

&#x20;       ADD\[ADDER]

&#x20;       SUB\[SUBTRACTOR]

&#x20;       MUL\[MULTIPLIER]

&#x20;       DIV\[DIVIDER]

&#x20;   end



&#x20;   subgraph Shift / Rotate Units

&#x20;       SHL\[SHIFT LEFT]

&#x20;       SHR\[SHIFT RIGHT]

&#x20;       ROL\[ROTATE LEFT]

&#x20;       ROR\[ROTATE RIGHT]

&#x20;   end



&#x20;   subgraph Logic Units

&#x20;       AND\[AND]

&#x20;       OR\[OR]

&#x20;       XOR\[XOR]

&#x20;       XNOR\[XNOR]

&#x20;       NAND\[NAND]

&#x20;       NOR\[NOR]

&#x20;   end



&#x20;   subgraph Compare Units

&#x20;       GT\[GREATER THAN]

&#x20;       EQ\[EQUAL]

&#x20;   end



&#x20;   %% Global Data Routing

&#x20;   IN\_A --> ADD \& SUB \& MUL \& DIV \& SHL \& SHR \& ROL \& ROR \& AND \& OR \& XOR \& XNOR \& NAND \& NOR \& GT \& EQ

&#x20;   IN\_B --> ADD \& SUB \& MUL \& DIV \& SHL \& SHR \& ROL \& ROR \& AND \& OR \& XOR \& XNOR \& NAND \& NOR \& GT \& EQ



&#x20;   %% Enables

&#x20;   DEC -- "\[0]" --> ADD

&#x20;   DEC -- "\[1]" --> SUB

&#x20;   DEC -- "\[2]" --> MUL

&#x20;   DEC -- "\[3]" --> DIV

&#x20;   DEC -- "\[4]" --> SHL

&#x20;   DEC -- "\[5]" --> SHR

&#x20;   DEC -- "\[6]" --> ROL

&#x20;   DEC -- "\[7]" --> ROR

&#x20;   DEC -- "\[8]" --> AND

&#x20;   DEC -- "\[9]" --> OR

&#x20;   DEC -- "\[10]" --> XOR

&#x20;   DEC -- "\[11]" --> XNOR

&#x20;   DEC -- "\[12]" --> NAND

&#x20;   DEC -- "\[13]" --> NOR

&#x20;   DEC -- "\[14]" --> GT

&#x20;   DEC -- "\[15]" --> EQ



&#x20;   %% MUX

&#x20;   MUX\["OUTPUT MUX<br>(Combinational)"]



&#x20;   ADD -- "ADD\_RESULT, CARRY\_ADD" --> MUX

&#x20;   SUB -- "SUB\_RESULT, NEGATIVE\_SUB" --> MUX

&#x20;   MUL -- "MUL\_RESULT, OVERFLOW\_MUL" --> MUX

&#x20;   DIV -- "DIV\_RESULT, ZERO\_DIV" --> MUX

&#x20;   

&#x20;   SHL -- SHL\_RESULT --> MUX

&#x20;   SHR -- SHR\_RESULT --> MUX

&#x20;   ROL -- ROL\_RESULT --> MUX

&#x20;   ROR -- ROR\_RESULT --> MUX

&#x20;   

&#x20;   AND -- AND\_RESULT --> MUX

&#x20;   OR -- OR\_RESULT --> MUX

&#x20;   XOR -- XOR\_RESULT --> MUX

&#x20;   XNOR -- XNOR\_RESULT --> MUX

&#x20;   NAND -- NAND\_RESULT --> MUX

&#x20;   NOR -- NOR\_RESULT --> MUX

&#x20;   

&#x20;   GT -- GT\_in --> MUX

&#x20;   EQ -- EQ\_in --> MUX



&#x20;   IN\_OP --> MUX

&#x20;   IN\_START --> MUX



&#x20;   %% FSM Block

&#x20;   FSM\["FSM \& OUTPUT REGISTERS<br>States: IDLE, EXECUTE, COMPLETE"]

&#x20;   IN\_CLK --> FSM

&#x20;   IN\_RST --> FSM

&#x20;   IN\_START --> FSM



&#x20;   MUX -- "result\_w, valid\_w, zero\_w,<br>carry\_w, negative\_w, overflow\_w,<br>gt\_w, eq\_w" --> FSM



&#x20;   %% Outputs

&#x20;   subgraph Registered Outputs

&#x20;       FSM --> OUT\_RESULT("RESULT \[WIDTH-1:0]")

&#x20;       FSM --> OUT\_VALID(VALID)

&#x20;       FSM --> OUT\_CARRY(CARRY)

&#x20;       FSM --> OUT\_NEGATIVE(NEGATIVE)

&#x20;       FSM --> OUT\_OVERFLOW(OVERFLOW)

&#x20;       FSM --> OUT\_ZERO(ZERO)

&#x20;       FSM --> OUT\_GT(GT)

&#x20;       FSM --> OUT\_EQ(EQ)

&#x20;       FSM --> OUT\_DONE(done)

&#x20;       FSM --> OUT\_BUSY(busy)

&#x20;   end

&#x20;   

&#x20;   classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;

&#x20;   classDef logic fill:#e1f5fe,stroke:#0288d1;

&#x20;   classDef fsm fill:#fff3e0,stroke:#f57c00,stroke-width:2px;

&#x20;   class DEC,MUX logic;

&#x20;   class FSM fsm;


graph LR

&#x20;   %% Styles

&#x20;   classDef uvm fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;

&#x20;   classDef dut fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;

&#x20;   classDef vif fill:#fff3e0,stroke:#e65100,stroke-width:2px,shape:hexagon;

&#x20;   classDef ral fill:#f3e5f5,stroke:#6a1b9a,stroke-width:2px;

&#x20;   classDef internal fill:#ffffff,stroke:#333,stroke-width:1px;



&#x20;   subgraph UVM\_TESTBENCH \["UVM Testbench (alu\_tb\_pkg)"]

&#x20;       TEST\[UVM Test / Sequences]:::uvm

&#x20;       

&#x20;       subgraph RAL\_ENV \["Register Abstraction Layer"]

&#x20;           REG\_MODEL\[alu\_reg\_block]:::ral

&#x20;           ADAPTER\[alu\_reg\_adapter]:::ral

&#x20;           PREDICTOR\[alu\_predictor]:::ral

&#x20;       end



&#x20;       subgraph APB\_AGENT \["APB Agent (Active)"]

&#x20;           SEQR\[apb\_sequencer]:::uvm

&#x20;           DRV\[apb\_driver]:::uvm

&#x20;           MON\[apb\_monitor]:::uvm

&#x20;       end



&#x20;       subgraph ENV\_CHECKS \["Verification Environment"]

&#x20;           SCBD\[alu\_scoreboard \\n + alu\_reference\_model]:::uvm

&#x20;           COV\[alu\_coverage]:::uvm

&#x20;       end



&#x20;       %% UVM Internal Connections

&#x20;       TEST -- "Register read/write()" --> REG\_MODEL

&#x20;       REG\_MODEL -- "reg2bus" --> ADAPTER

&#x20;       ADAPTER -- "transaction" --> SEQR

&#x20;       SEQR --> DRV

&#x20;       

&#x20;       MON -- "item\_collected\_port (Analysis)" --> SCBD

&#x20;       MON -- "item\_collected\_port (Analysis)" --> COV

&#x20;       MON -- "bus2reg" --> PREDICTOR

&#x20;       PREDICTOR --> REG\_MODEL

&#x20;   end



&#x20;   VIF{{"apb\_if (Virtual Interface)"}}:::vif



&#x20;   subgraph DUT\_ALU\_TOP \["DUT: alu\_top (Hardware)"]

&#x20;       APB\_SLAVE\["APB Slave FSM\\n(IDLE -> SETUP -> ACCESS)"]:::internal

&#x20;       REG\_FILE\["Register File\\n(0x00 - 0x14)"]:::internal

&#x20;       

&#x20;       subgraph ALU\_CORE \["ALU Core"]

&#x20;           ALU\_DP\["Datapath\\n(Add, Sub, Mul, Div, Logic)"]:::internal

&#x20;           ALU\_FSM\["Control FSM\\n(IDLE -> EXEC -> COMP)"]:::internal

&#x20;       end

&#x20;       

&#x20;       %% DUT Internal Connections

&#x20;       APB\_SLAVE -- "wr\_en, wdata, addr" --> REG\_FILE

&#x20;       REG\_FILE -- "rdata, PREADY" --> APB\_SLAVE

&#x20;       

&#x20;       REG\_FILE -- "operand\_a, operand\_b, opcode" --> ALU\_DP

&#x20;       REG\_FILE -- "start" --> ALU\_FSM

&#x20;       

&#x20;       ALU\_DP -- "result, flags" --> REG\_FILE

&#x20;       ALU\_FSM -- "done, busy" --> REG\_FILE

&#x20;   end



&#x20;   %% Environment to Interface Connections

&#x20;   DRV == "Drives: PSEL, PENABLE, PWRITE, PWDATA" === VIF

&#x20;   VIF -. "Samples: All APB Pins" .-> MON



&#x20;   %% Interface to DUT Connections

&#x20;   VIF == "Physical Wires" === APB\_SLAVE


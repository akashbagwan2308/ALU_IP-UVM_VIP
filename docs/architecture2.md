flowchart TD
    %% Define Professional Color Themes
    classDef test fill:#bbdefb,stroke:#1976d2,stroke-width:2px,color:#000
    classDef ral fill:#c8e6c9,stroke:#388e3c,stroke-width:2px,color:#000
    classDef agent fill:#ffcc80,stroke:#f57c00,stroke-width:2px,color:#000
    classDef checks fill:#e1bee7,stroke:#8e24aa,stroke-width:2px,color:#000
    classDef vif fill:#ffcdd2,stroke:#d32f2f,stroke-width:3px,color:#000,shape:hexagon
    classDef dut fill:#cfd8dc,stroke:#455a64,stroke-width:2px,color:#000
    classDef internal fill:#ffffff,stroke:#78909c,stroke-width:1px,color:#000

    %% --------------------------------------------------------
    %% UVM SOFTWARE LAYER
    %% --------------------------------------------------------
    subgraph TB [UVM Testbench Top]
        direction TD
        TEST["<b>UVM Test / Sequences</b><br/>(Generates High-Level Stimulus)"]:::test

        subgraph ENV [ALU UVM Environment]
            direction LR
            
            subgraph RAL [Register Abstraction Layer]
                direction TD
                REG_BLOCK["<b>alu_reg_block</b><br/>(Maintains Shadow Registers)"]:::ral
                ADAPTER["<b>alu_reg_adapter</b><br/>(Converts reg2bus & bus2reg)"]:::ral
                PREDICTOR["<b>alu_predictor</b><br/>(Updates Register Mirror)"]:::ral
            end

            subgraph AGENT [Active APB Agent]
                direction TD
                SEQR["<b>apb_sequencer</b><br/>(Transaction Router)"]:::agent
                DRV["<b>apb_driver</b><br/>(Drives physical APB protocol)"]:::agent
                MON["<b>apb_monitor</b><br/>(Observes physical APB bus)"]:::agent
            end

            subgraph CHECKS [Verification & Checking]
                direction TD
                SCBD["<b>alu_scoreboard</b><br/>(Uses alu_reference_model)"]:::checks
                COV["<b>alu_coverage</b><br/>(Collects Functional Coverage)"]:::checks
            end
        end
    end

    %% --------------------------------------------------------
    %% VIRTUAL INTERFACE (THE BRIDGE)
    %% --------------------------------------------------------
    VIF{{"<b>apb_if</b><br/>(Virtual Interface / Clock & Reset)"}}:::vif

    %% --------------------------------------------------------
    %% RTL HARDWARE LAYER
    %% --------------------------------------------------------
    subgraph DUT [Design Under Test: alu_top]
        direction LR
        
        APB_SLAVE["<b>APB Slave FSM</b><br/>(IDLE -> SETUP -> ACCESS)"]:::internal
        REG_FILE["<b>Register File</b><br/>(0x00 to 0x14)"]:::internal

        subgraph CORE [ALU Core]
            direction TD
            ALU_FSM["<b>Control FSM</b><br/>(Manages 2-Cycle Latency)"]:::internal
            ALU_DP["<b>ALU Datapath</b><br/>(Math, Logic, Shift, Compare)"]:::internal
        end
    end

    %% --------------------------------------------------------
    %% ROUTING & CONNECTIONS
    %% --------------------------------------------------------
    
    %% Stimulus Flow (Downwards)
    TEST -- "reg.write() / reg.read()" --> REG_BLOCK
    REG_BLOCK -- "uvm_reg_bus_op" --> ADAPTER
    ADAPTER -- "transaction" --> SEQR
    SEQR -- "req" --> DRV
    DRV == "Drives: PADDR, PWDATA,\nPSEL, PENABLE, PWRITE" === VIF

    %% Hardware Execution Flow
    VIF == "Physical Wires" === APB_SLAVE
    APB_SLAVE -- "wr_en, addr, wdata" --> REG_FILE
    REG_FILE -- "PRDATA, PREADY" --> APB_SLAVE
    
    REG_FILE -- "start" --> ALU_FSM
    REG_FILE -- "opcode, operand_a, operand_b" --> ALU_DP
    
    ALU_FSM -- "done, busy" --> REG_FILE
    ALU_DP -- "result, flags" --> REG_FILE

    %% Monitoring Flow (Upwards)
    VIF -. "Samples: All APB Pins" .-> MON
    MON -- "transaction" --> PREDICTOR
    PREDICTOR -. "Updates Mirror" .-> REG_BLOCK
    
    MON -- "Broadcasts transaction\nvia Analysis Port" --> SCBD
    MON -- "Broadcasts transaction\nvia Analysis Port" --> COV

    %% Invisible links to force layout alignment
    RAL ~~~ AGENT
    AGENT ~~~ CHECKS
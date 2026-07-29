flowchart LR
    %% Inputs
    subgraph Inputs
        IN_A("A [WIDTH-1:0]")
        IN_B("B [WIDTH-1:0]")
        IN_OP("opcode [3:0]")
        IN_START(start)
        IN_CLK(clk)
        IN_RST(rst_n)
    end

    %% Decoder
    DEC[OPCODE DECODER]
    IN_OP --> DEC
    IN_START --> DEC

    %% Functional Units
    subgraph Arithmetic Units
        ADD[ADDER]
        SUB[SUBTRACTOR]
        MUL[MULTIPLIER]
        DIV[DIVIDER]
    end

    subgraph Shift / Rotate Units
        SHL[SHIFT LEFT]
        SHR[SHIFT RIGHT]
        ROL[ROTATE LEFT]
        ROR[ROTATE RIGHT]
    end

    subgraph Logic Units
        AND[AND]
        OR[OR]
        XOR[XOR]
        XNOR[XNOR]
        NAND[NAND]
        NOR[NOR]
    end

    subgraph Compare Units
        GT[GREATER THAN]
        EQ[EQUAL]
    end

    %% Global Data Routing
    IN_A --> ADD & SUB & MUL & DIV & SHL & SHR & ROL & ROR & AND & OR & XOR & XNOR & NAND & NOR & GT & EQ
    IN_B --> ADD & SUB & MUL & DIV & SHL & SHR & ROL & ROR & AND & OR & XOR & XNOR & NAND & NOR & GT & EQ

    %% Enables
    DEC -- "[0]" --> ADD
    DEC -- "[1]" --> SUB
    DEC -- "[2]" --> MUL
    DEC -- "[3]" --> DIV
    DEC -- "[4]" --> SHL
    DEC -- "[5]" --> SHR
    DEC -- "[6]" --> ROL
    DEC -- "[7]" --> ROR
    DEC -- "[8]" --> AND
    DEC -- "[9]" --> OR
    DEC -- "[10]" --> XOR
    DEC -- "[11]" --> XNOR
    DEC -- "[12]" --> NAND
    DEC -- "[13]" --> NOR
    DEC -- "[14]" --> GT
    DEC -- "[15]" --> EQ

    %% MUX
    MUX["OUTPUT MUX<br>(Combinational)"]

    ADD -- "ADD_RESULT, CARRY_ADD" --> MUX
    SUB -- "SUB_RESULT, NEGATIVE_SUB" --> MUX
    MUL -- "MUL_RESULT, OVERFLOW_MUL" --> MUX
    DIV -- "DIV_RESULT, ZERO_DIV" --> MUX
    
    SHL -- SHL_RESULT --> MUX
    SHR -- SHR_RESULT --> MUX
    ROL -- ROL_RESULT --> MUX
    ROR -- ROR_RESULT --> MUX
    
    AND -- AND_RESULT --> MUX
    OR -- OR_RESULT --> MUX
    XOR -- XOR_RESULT --> MUX
    XNOR -- XNOR_RESULT --> MUX
    NAND -- NAND_RESULT --> MUX
    NOR -- NOR_RESULT --> MUX
    
    GT -- GT_in --> MUX
    EQ -- EQ_in --> MUX

    IN_OP --> MUX
    IN_START --> MUX

    %% FSM Block
    FSM["FSM & OUTPUT REGISTERS<br>States: IDLE, EXECUTE, COMPLETE"]
    IN_CLK --> FSM
    IN_RST --> FSM
    IN_START --> FSM

    MUX -- "result_w, valid_w, zero_w,<br>carry_w, negative_w, overflow_w,<br>gt_w, eq_w" --> FSM

    %% Outputs
    subgraph Registered Outputs
        FSM --> OUT_RESULT("RESULT [WIDTH-1:0]")
        FSM --> OUT_VALID(VALID)
        FSM --> OUT_CARRY(CARRY)
        FSM --> OUT_NEGATIVE(NEGATIVE)
        FSM --> OUT_OVERFLOW(OVERFLOW)
        FSM --> OUT_ZERO(ZERO)
        FSM --> OUT_GT(GT)
        FSM --> OUT_EQ(EQ)
        FSM --> OUT_DONE(done)
        FSM --> OUT_BUSY(busy)
    end
    
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef logic fill:#e1f5fe,stroke:#0288d1;
    classDef fsm fill:#fff3e0,stroke:#f57c00,stroke-width:2px;
    class DEC,MUX logic;
    class FSM fsm;

flowchart LR
    %% --------------------------------------------------------
    %% 1. SYSTEM I/O (APB INTERFACE)
    %% --------------------------------------------------------
    subgraph IO ["Top-Level APB Interface"]
        direction TB
        IN_CLK("CLK")
        IN_RST("RST_N")
        IN_SEL("SEL")
        IN_EN("ENABLE")
        IN_WR("WRITE")
        IN_WDATA("WDATA [WIDTH-1:0]")
        IN_ADDR("ADDR [WIDTH-1:0]")
        OUT_RDATA("RDATA [WIDTH-1:0]")
        OUT_READY("READY")
    end

    %% --------------------------------------------------------
    %% 2. APB SLAVE MODULE
    %% --------------------------------------------------------
    subgraph SLAVE ["APB Slave Module"]
        direction TB
        APB_FSM["APB State Machine<br>(States: IDLE, SETUP, ACCESS)"]
        APB_CTRL["Bus Control Logic<br>(PREADY Stall logic on alu_busy)"]
    end

    %% --------------------------------------------------------
    %% 3. REGISTER FILE MODULE
    %% --------------------------------------------------------
    subgraph REGS ["Register File Module"]
        direction TB
        REG_CTRL["0x00: CTRL<br>[0] START"]
        REG_A["0x04: OPERAND_A"]
        REG_B["0x08: OPERAND_B"]
        REG_OP["0x0C: OPCODE"]
        REG_STAT["0x10: STATUS<br>(Flags, BUSY, DONE, VALID)"]
        REG_RES["0x14: RESULT"]
    end

    %% --------------------------------------------------------
    %% 4. ALU CORE MODULE (Detailed internal structure)
    %% --------------------------------------------------------
    subgraph ALU ["ALU Core Module"]
        direction LR
        DEC["OPCODE DECODER<br>(One-Hot Enable Gen)"]
        
        subgraph DataPath ["ALU Datapath"]
            direction TB
            ARITH["Arithmetic Units<br>(ADD, SUB, MUL, DIV)"]
            SHIFT["Shift/Rotate Units<br>(SHL, SHR, ROL, ROR)"]
            LOGIC["Logic Units<br>(AND, OR, XOR, XNOR, NAND, NOR)"]
            COMP["Compare Units<br>(GT, EQ)"]
        end
        
        MUX["OUTPUT MUX<br>(Opcode Based)"]
        ALU_FSM["ALU FSM & LATCHES<br>(2-Cycle Latency)"]
    end

    %% ========================================================
    %% ROUTING & CONNECTIONS
    %% ========================================================
    
    %% Globals
    IN_CLK & IN_RST --> SLAVE & REGS & ALU
    
    %% IO to APB Slave
    IN_SEL & IN_EN & IN_WR & IN_WDATA & IN_ADDR --> SLAVE
    SLAVE --> OUT_RDATA & OUT_READY
    
    %% APB Slave to Register File
    SLAVE -- "APB_ADDR, APB_WDATA,<br>APB_WR_EN" --> REGS
    REGS -- "APB_RDATA" --> SLAVE
    
    %% Note: APB_STATUS is used by slave to drop PREADY when ALU is busy
    REGS -. "APB_STATUS[2] (alu_busy)" .-> APB_CTRL

    %% Register File to ALU Core Inputs
    REG_OP -- "opcode [3:0]" --> DEC
    REG_CTRL -- "start" --> DEC & MUX & ALU_FSM
    REG_A -- "A [WIDTH-1:0]" --> DataPath
    REG_B -- "B [WIDTH-1:0]" --> DataPath
    
    %% ALU Core Internal Routing
    DEC -- "Control Signals [15:0]" --> DataPath
    REG_OP -- "opcode [3:0]" --> MUX
    DataPath -- "All Results & Flags" --> MUX
    MUX -- "result_w, valid_w, zero_w,<br>carry_w, overflow_w, etc." --> ALU_FSM
    
    %% ALU Core back to Register File
    ALU_FSM -- "RESULT_REG" --> REG_RES
    ALU_FSM -- "DONE, BUSY, VALID,<br>CARRY, ZERO, OVERFLOW, etc." --> REG_STAT
    ALU_FSM -. "alu_done clears start bit" .-> REG_CTRL
    
    %% ========================================================
    %% STYLING
    %% ========================================================
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef io fill:#eceff1,stroke:#607d8b,stroke-width:2px;
    classDef apb fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;
    classDef reg fill:#fff8e1,stroke:#fbc02d,stroke-width:2px;
    classDef alu fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;
    classDef inner logic fill:#e1f5fe,stroke:#0288d1;
    
    class IO io;
    class SLAVE apb;
    class REGS reg;
    class ALU alu;
    class DEC,MUX,DataPath,ALU_FSM inner;


flowchart TB
    %% ========================================================
    %% 1. UVM TESTBENCH TOP (tb_top)
    %% ========================================================
    subgraph TB_TOP ["tb_top (Verification Top)"]
        
        %% Clock & Reset Generation
        CLK_GEN["Clock & Reset Generator<br>(100MHz PCLK, PRESET_n)"]

        %% ========================================================
        %% 2. UVM CLASS HIERARCHY
        %% ========================================================
        subgraph UVM ["UVM Test Hierarchy (run_test)"]
            direction TB
            
            CDB[("uvm_config_db<br>Stores 'vif' from tb_top")]
            
            subgraph TEST ["base_test"]
                direction TB
                
                subgraph ENV ["alu_env"]
                    direction TB
                    
                    VSQR["virtual_sequencer<br>(v_sqr)"]
                    SCBD["alu_scoreboard<br>(scbd)"]
                    COV["alu_coverage<br>(cov)"]
                    
                    subgraph AGENT ["apb_agent (Active)"]
                        direction LR
                        SEQR["apb_sequencer"]
                        DRV["apb_driver"]
                        MON["apb_monitor"]
                        
                        %% Agent Internal Connections
                        SEQR -- "req (seq_item_port)" --> DRV
                    end
                    
                    %% Env Internal TLM Connections
                    MON -- "item_collected_port" --> SCBD & COV
                    VSQR -. "Routes to" .-> SEQR
                end
                
                %% Sequence Injection
                SEQ("base_sequence<br>#(transaction)") -. "Executes on" .-> VSQR
            end
            
            %% Config DB lookups
            CDB -. "vif" .-> TEST
            TEST -. "Passes vif via config_db" .-> MON & DRV
        end

        %% ========================================================
        %% 3. SYSTEMVERILOG INTERFACE (apb_inft)
        %% ========================================================
        subgraph IF ["apb_inft (SystemVerilog Interface)"]
            direction LR
            CB["Clocking Blocks<br>(drv_cb, mon_cb)"]
            MODS["Modports<br>(DRIVER, MONITOR, DUT)"]
            SIGS["APB Bus Signals<br>(PSEL, PENABLE, PWRITE, PADDR, PWDATA)"]
            
            CB --- MODS --- SIGS
        end

        %% ========================================================
        %% 4. DUT: ALU TOP (alu_top)
        %% ========================================================
        subgraph DUT ["DUT: alu_top"]
            direction TB
            
            subgraph SLAVE ["APB Slave Module"]
                APB_FSM["APB State Machine"]
            end
            
            subgraph REGS ["Register File Module"]
                REG_MAP["0x00: CTRL<br>0x04: OPERA<br>0x08: OPERB<br>0x0C: OP<br>0x10: STAT<br>0x14: RES"]
            end
            
            subgraph ALU ["ALU Core Module"]
                direction LR
                DEC["OPCODE<br>DECODER"]
                DP["ALU<br>Datapath"]
                MUX["OUTPUT<br>MUX"]
                FSM["ALU FSM<br>(2-Cycle)"]
                
                DEC --> DP --> MUX --> FSM
            end
            
            %% DUT Internal Routing
            SLAVE -- "APB_ADDR, WDATA" --> REGS
            REGS -- "APB_RDATA" --> SLAVE
            REGS -. "APB_STATUS[2]<br>(Stalls Bus)" .-> SLAVE
            
            REGS -- "A, B, opcode, start" --> ALU
            ALU -- "RESULT, Flags, done, busy" --> REGS
            ALU -. "alu_done clears start" .-> REGS
        end

        %% ========================================================
        %% CROSS-DOMAIN ROUTING & CONNECTIONS
        %% ========================================================
        %% Clocks
        CLK_GEN -->|Drives| IF
        CLK_GEN -->|PCLK, PRESET_n| DUT
        
        %% Interface connection to tb_top config db
        IF -. "Registers vif" .-> CDB
        
        %% UVM to Interface (Virtual Interface interactions)
        DRV == "Drives APB<br>@(vif.drv_cb)" === CB
        MON == "Samples APB<br>@(vif.mon_cb)" === CB
        
        %% Interface to DUT
        IF == "Connected via<br>DUT Modport" === SLAVE
    end

    %% ========================================================
    %% STYLING
    %% ========================================================
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef tb fill:#f3e5f5,stroke:#8e24aa,stroke-width:2px;
    classDef uvm fill:#ede7f6,stroke:#5e35b1,stroke-width:2px;
    classDef uvm_comp fill:#d1c4e9,stroke:#512da8,stroke-width:1px;
    classDef iface fill:#e0f2f1,stroke:#00897b,stroke-width:2px;
    classDef dut fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;
    classDef inner logic fill:#e1f5fe,stroke:#0288d1;
    classDef reg fill:#fff8e1,stroke:#fbc02d;
    
    class TB_TOP tb;
    class UVM,TEST,ENV,AGENT uvm;
    class VSQR,SCBD,COV,SEQR,DRV,MON uvm_comp;
    class IF iface;
    class DUT dut;
    class REGS reg;
    class DEC,DP,MUX,FSM inner;

flowchart TB
    %% ========================================================
    %% 1. UVM TESTBENCH TOP (tb_top)
    %% ========================================================
    subgraph TB_TOP ["tb_top (Verification Top)"]
        
        CLK_GEN["Clock & Reset Generator<br>(100MHz PCLK, PRESET_n)"]

        %% ========================================================
        %% 2. UVM CLASS HIERARCHY
        %% ========================================================
        subgraph UVM ["UVM Test Hierarchy (run_test)"]
            direction TB
            
            CDB[("uvm_config_db<br>Stores 'vif' from tb_top")]
            
            subgraph TEST ["base_test"]
                direction TB
                
                subgraph ENV ["alu_env"]
                    direction TB
                    
                    %% --- RAL Subsystem ---
                    subgraph RAL ["Register Abstraction Layer (RAL)"]
                        direction TB
                        REG_MODEL["Register Model<br>(alu_reg_status, etc.)"]
                        ADAPTER["alu_reg_adapter<br>(reg2bus / bus2reg)"]
                        PREDICTOR["alu_predictor"]
                        
                        REG_MODEL -. "Uses for auto-conversion" .-> ADAPTER
                        PREDICTOR -. "Updates implicitly" .-> REG_MODEL
                    end
                    
                    VSQR["virtual_sequencer<br>(v_sqr)"]
                    
                    %% --- Scoreboard Subsystem ---
                    subgraph SCBD_GRP ["alu_scoreboard"]
                        direction LR
                        SCBD["Scoreboard Control<br>(Shadow Regs, Compare Logic)"]
                        REF["alu_reference_model<br>(Golden calc_expected)"]
                        SCBD -- "Queries expected result" --> REF
                    end
                    
                    %% --- Coverage Subsystem ---
                    subgraph COV_GRP ["alu_coverage"]
                        direction LR
                        COV["Subscriber Logic<br>(Shadow Regs)"]
                        CG["covergroup alu_cg<br>(Samples on START)"]
                        COV -- "Triggers" --> CG
                    end
                    
                    %% --- Agent Subsystem ---
                    subgraph AGENT ["apb_agent (Active)"]
                        direction LR
                        SEQR["apb_sequencer"]
                        DRV["apb_driver"]
                        MON["apb_monitor"]
                        
                        SEQR -- "req (seq_item_port)" --> DRV
                    end
                    
                    %% Env Internal TLM Connections
                    MON -- "item_collected_port" --> PREDICTOR & SCBD & COV
                    VSQR -. "Routes to" .-> SEQR
                    ADAPTER -. "Mapped sequence items" .-> SEQR
                end
                
                %% Sequence Injection
                SEQ("base_sequence<br>#(transaction)") -. "Executes on" .-> VSQR
            end
            
            CDB -. "vif" .-> TEST
            TEST -. "Passes vif via config_db" .-> MON & DRV
        end

        %% ========================================================
        %% 3. SYSTEMVERILOG INTERFACE (apb_inft)
        %% ========================================================
        subgraph IF ["apb_inft (SystemVerilog Interface)"]
            direction LR
            CB["Clocking Blocks<br>(drv_cb, mon_cb)"]
            MODS["Modports<br>(DRIVER, MONITOR, DUT)"]
            SIGS["APB Bus Signals<br>(PSEL, PENABLE, PWRITE, etc.)"]
            
            CB --- MODS --- SIGS
        end

        %% ========================================================
        %% 4. DUT: ALU TOP (alu_top)
        %% ========================================================
        subgraph DUT ["DUT: alu_top"]
            direction TB
            
            subgraph SLAVE ["APB Slave Module"]
                APB_FSM["APB State Machine"]
            end
            
            subgraph REGS ["Register File Module"]
                REG_MAP["0x00: CTRL<br>0x04: OPERA<br>0x08: OPERB<br>0x0C: OP<br>0x10: STAT<br>0x14: RES"]
            end
            
            subgraph ALU ["ALU Core Module"]
                direction LR
                DEC["OPCODE<br>DECODER"]
                DP["ALU<br>Datapath"]
                MUX["OUTPUT<br>MUX"]
                FSM["ALU FSM<br>(2-Cycle)"]
                
                DEC --> DP --> MUX --> FSM
            end
            
            %% DUT Internal Routing
            SLAVE -- "APB_ADDR, WDATA" --> REGS
            REGS -- "APB_RDATA" --> SLAVE
            REGS -. "APB_STATUS[2]<br>(Stalls Bus)" .-> SLAVE
            
            REGS -- "A, B, opcode, start" --> ALU
            ALU -- "RESULT, Flags, done, busy" --> REGS
            ALU -. "alu_done clears start" .-> REGS
        end

        %% ========================================================
        %% CROSS-DOMAIN ROUTING & CONNECTIONS
        %% ========================================================
        CLK_GEN -->|Drives| IF
        CLK_GEN -->|PCLK, PRESET_n| DUT
        
        IF -. "Registers vif" .-> CDB
        
        DRV == "Drives APB<br>@(vif.drv_cb)" === CB
        MON == "Samples APB<br>@(vif.mon_cb)" === CB
        
        IF == "Connected via<br>DUT Modport" === SLAVE
    end

    %% ========================================================
    %% STYLING
    %% ========================================================
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef tb fill:#f3e5f5,stroke:#8e24aa,stroke-width:2px;
    classDef uvm fill:#ede7f6,stroke:#5e35b1,stroke-width:2px;
    classDef uvm_comp fill:#d1c4e9,stroke:#512da8,stroke-width:1px;
    classDef ral fill:#ffe0b2,stroke:#f57c00,stroke-width:2px;
    classDef iface fill:#e0f2f1,stroke:#00897b,stroke-width:2px;
    classDef dut fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;
    classDef inner logic fill:#e1f5fe,stroke:#0288d1;
    classDef reg fill:#fff8e1,stroke:#fbc02d;
    
    class TB_TOP tb;
    class UVM,TEST,ENV,AGENT uvm;
    class VSQR,SCBD,COV,SEQR,DRV,MON,REF,CG uvm_comp;
    class RAL,REG_MODEL,ADAPTER,PREDICTOR ral;
    class IF iface;
    class DUT dut;
    class REGS reg;
    class DEC,DP,MUX,FSM inner;

flowchart TB
    %% ========================================================
    %% 1. UVM TESTBENCH TOP (tb_top)
    %% ========================================================
    subgraph TB_TOP ["tb_top (Verification Top)"]
        
        CLK_GEN["Clock & Reset Generator<br>(100MHz PCLK, PRESET_n)"]

        %% ========================================================
        %% 2. UVM CLASS HIERARCHY
        %% ========================================================
        subgraph UVM ["UVM Test Hierarchy (run_test)"]
            direction TB
            
            CDB[("uvm_config_db<br>Stores 'vif' from tb_top")]
            
            %% --- Test Library ---
            subgraph TEST_LIB ["Test Library (extends base_test)"]
                direction LR
                T1["alu_smoke_test"]
                T2["alu_add_test / alu_sub_test"]
                T3["alu_reg_test<br>(Stuck-at fault check)"]
                T4["alu_reset_test<br>(On-the-fly reset check)"]
                T5["alu_random_test / alu_stress_test"]
            end

            subgraph TEST ["base_test (Active Instance)"]
                direction TB
                
                %% --- Sequence Library ---
                subgraph SEQ_LIB ["Sequence Library (extends base_sequence)"]
                    direction TB
                    
                    subgraph OP_SEQS ["Operational Sequences"]
                        S1["alu_add_sequence"]
                        S2["alu_sub_sequence"]
                        S3["alu_random_sequence"]
                    end
                    
                    subgraph TX_SEQS ["Transactional Sequences"]
                        S4["apb_write_sequence"]
                        S5["apb_read_sequence"]
                    end
                    
                    OP_SEQS -. "Composed of" .-> TX_SEQS
                end

                subgraph ENV ["alu_env"]
                    direction TB
                    
                    %% --- RAL Subsystem ---
                    subgraph RAL ["Register Abstraction Layer (RAL)"]
                        direction TB
                        REG_MODEL["Register Model<br>(alu_reg_status, etc.)"]
                        ADAPTER["alu_reg_adapter<br>(reg2bus / bus2reg)"]
                        PREDICTOR["alu_predictor"]
                        
                        REG_MODEL -. "Uses for auto-conversion" .-> ADAPTER
                        PREDICTOR -. "Updates implicitly" .-> REG_MODEL
                    end
                    
                    VSQR["virtual_sequencer<br>(v_sqr)"]
                    
                    %% --- Scoreboard Subsystem ---
                    subgraph SCBD_GRP ["alu_scoreboard"]
                        direction LR
                        SCBD["Scoreboard Control<br>(Shadow Regs, Compare Logic)"]
                        REF["alu_reference_model<br>(Golden calc_expected)"]
                        SCBD -- "Queries expected result" --> REF
                    end
                    
                    %% --- Coverage Subsystem ---
                    subgraph COV_GRP ["alu_coverage"]
                        direction LR
                        COV["Subscriber Logic<br>(Shadow Regs)"]
                        CG["covergroup alu_cg<br>(Samples on START)"]
                        COV -- "Triggers" --> CG
                    end
                    
                    %% --- Agent Subsystem ---
                    subgraph AGENT ["apb_agent (Active)"]
                        direction LR
                        SEQR["apb_sequencer"]
                        DRV["apb_driver"]
                        MON["apb_monitor"]
                        
                        SEQR -- "req (seq_item_port)" --> DRV
                    end
                    
                    %% Env Internal TLM Connections
                    MON -- "item_collected_port" --> PREDICTOR & SCBD & COV
                    VSQR -. "Routes to" .-> SEQR
                    ADAPTER -. "Mapped sequence items" .-> SEQR
                end
                
                %% Sequence Injection
                TX_SEQS -. "Executes on" .-> VSQR
            end
            
            TEST_LIB -. "+UVM_TESTNAME<br>Selects & Instantiates" .-> TEST
            CDB -. "vif" .-> TEST
            TEST -. "Passes vif via config_db" .-> MON & DRV
        end

        %% ========================================================
        %% 3. SYSTEMVERILOG INTERFACE (apb_inft)
        %% ========================================================
        subgraph IF ["apb_inft (SystemVerilog Interface)"]
            direction LR
            CB["Clocking Blocks<br>(drv_cb, mon_cb)"]
            MODS["Modports<br>(DRIVER, MONITOR, DUT)"]
            SIGS["APB Bus Signals<br>(PSEL, PENABLE, PWRITE, etc.)"]
            
            CB --- MODS --- SIGS
        end

        %% ========================================================
        %% 4. DUT: ALU TOP (alu_top)
        %% ========================================================
        subgraph DUT ["DUT: alu_top"]
            direction TB
            
            subgraph SLAVE ["APB Slave Module"]
                APB_FSM["APB State Machine"]
            end
            
            subgraph REGS ["Register File Module"]
                REG_MAP["0x00: CTRL<br>0x04: OPERA<br>0x08: OPERB<br>0x0C: OP<br>0x10: STAT<br>0x14: RES"]
            end
            
            subgraph ALU ["ALU Core Module"]
                direction LR
                DEC["OPCODE<br>DECODER"]
                DP["ALU<br>Datapath"]
                MUX["OUTPUT<br>MUX"]
                FSM["ALU FSM<br>(2-Cycle)"]
                
                DEC --> DP --> MUX --> FSM
            end
            
            %% DUT Internal Routing
            SLAVE -- "APB_ADDR, WDATA" --> REGS
            REGS -- "APB_RDATA" --> SLAVE
            REGS -. "APB_STATUS[2]<br>(Stalls Bus)" .-> SLAVE
            
            REGS -- "A, B, opcode, start" --> ALU
            ALU -- "RESULT, Flags, done, busy" --> REGS
            ALU -. "alu_done clears start" .-> REGS
        end

        %% ========================================================
        %% CROSS-DOMAIN ROUTING & CONNECTIONS
        %% ========================================================
        CLK_GEN -->|Drives| IF
        CLK_GEN -->|PCLK, PRESET_n| DUT
        
        IF -. "Registers vif" .-> CDB
        
        DRV == "Drives APB<br>@(vif.drv_cb)" === CB
        MON == "Samples APB<br>@(vif.mon_cb)" === CB
        
        IF == "Connected via<br>DUT Modport" === SLAVE
    end

    %% ========================================================
    %% STYLING
    %% ========================================================
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef tb fill:#f3e5f5,stroke:#8e24aa,stroke-width:2px;
    classDef uvm fill:#ede7f6,stroke:#5e35b1,stroke-width:2px;
    classDef uvm_comp fill:#d1c4e9,stroke:#512da8,stroke-width:1px;
    classDef uvm_test fill:#e8eaf6,stroke:#3f51b5,stroke-width:1px;
    classDef uvm_seq fill:#fce4ec,stroke:#c2185b,stroke-width:1px;
    classDef ral fill:#ffe0b2,stroke:#f57c00,stroke-width:2px;
    classDef iface fill:#e0f2f1,stroke:#00897b,stroke-width:2px;
    classDef dut fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;
    classDef inner logic fill:#e1f5fe,stroke:#0288d1;
    classDef reg fill:#fff8e1,stroke:#fbc02d;
    
    class TB_TOP tb;
    class UVM,TEST,ENV,AGENT uvm;
    class VSQR,SCBD,COV,SEQR,DRV,MON,REF,CG uvm_comp;
    class T1,T2,T3,T4,T5,TEST_LIB uvm_test;
    class S1,S2,S3,S4,S5,OP_SEQS,TX_SEQS,SEQ_LIB uvm_seq;
    class RAL,REG_MODEL,ADAPTER,PREDICTOR ral;
    class IF iface;
    class DUT dut;
    class REGS reg;
    class DEC,DP,MUX,FSM inner;

flowchart LR
    %% ========================================================
    %% 1. UVM TESTBENCH TOP (tb_top)
    %% ========================================================
    subgraph TB_TOP ["tb_top (Verification Top)"]
        direction TB
        
        CLK_GEN(["Clock & Reset Generator<br>(100MHz PCLK, PRESET_n)"])

        %% ========================================================
        %% 2. UVM CLASS HIERARCHY (Left Side)
        %% ========================================================
        subgraph UVM ["UVM Test Hierarchy (run_test)"]
            direction TB
            
            CDB[("uvm_config_db<br>Stores 'vif' from tb_top")]
            
            %% --- Test Library ---
            subgraph TEST_LIB ["Test Library"]
                direction TB
                T1("alu_smoke_test")
                T2("alu_add_test / sub_test")
                T3("alu_reg_test (Stuck-at)")
                T4("alu_reset_test (On-the-fly)")
                T5("alu_random_test / stress_test")
            end

            subgraph TEST ["base_test (Active Instance)"]
                direction TB
                
                %% --- Sequence Library ---
                subgraph SEQ_LIB ["Sequence Library"]
                    direction LR
                    
                    subgraph OP_SEQS ["Operational"]
                        S1("alu_add_seq")
                        S2("alu_sub_seq")
                        S3("alu_random_seq")
                    end
                    
                    subgraph TX_SEQS ["Transactional"]
                        S4("apb_write_seq")
                        S5("apb_read_seq")
                    end
                    
                    OP_SEQS -.->|"Composed of"| TX_SEQS
                end

                subgraph ENV ["alu_env"]
                    direction TB
                    
                    %% --- RAL Subsystem ---
                    subgraph RAL ["Register Abstraction Layer"]
                        direction LR
                        REG_MODEL[("Register Model")]
                        ADAPTER["alu_reg_adapter"]
                        PREDICTOR["alu_predictor"]
                        
                        REG_MODEL -.->|"Auto-converts"| ADAPTER
                        PREDICTOR -.->|"Updates implicitly"| REG_MODEL
                    end
                    
                    VSQR["virtual_sequencer"]
                    
                    %% --- Scoreboard Subsystem ---
                    subgraph SCBD_GRP ["Scoreboard"]
                        direction LR
                        SCBD["Scoreboard Control"]
                        REF["alu_reference_model"]
                        SCBD -->|"Queries expected"| REF
                    end
                    
                    %% --- Coverage Subsystem ---
                    subgraph COV_GRP ["Coverage"]
                        direction LR
                        COV["Subscriber Logic"]
                        CG["covergroup alu_cg"]
                        COV -->|"Samples on START"| CG
                    end
                    
                    %% --- Agent Subsystem ---
                    subgraph AGENT ["apb_agent (Active)"]
                        direction LR
                        SEQR["apb_sequencer"]
                        DRV["apb_driver"]
                        MON["apb_monitor"]
                        
                        SEQR -->|"seq_item_port"| DRV
                    end
                    
                    %% Env Internal TLM Connections
                    MON -.->|"item_collected_port"| PREDICTOR & SCBD & COV
                    VSQR -.->|"Routes to"| SEQR
                    ADAPTER -.->|"Mapped items"| SEQR
                end
                
                %% Sequence Injection
                TX_SEQS -.->|"Executes on"| VSQR
            end
            
            TEST_LIB -.->|"+UVM_TESTNAME"| TEST
            CDB -.->|"Passes vif"| MON & DRV
        end

        %% ========================================================
        %% 3. SYSTEMVERILOG INTERFACE (Middle)
        %% ========================================================
        subgraph IF ["apb_inft (SV Interface)"]
            direction TB
            CB["Clocking Blocks<br>(drv_cb, mon_cb)"]
            MODS["Modports<br>(DRIVER, MONITOR, DUT)"]
            SIGS["APB Bus Signals<br>(PSEL, PENABLE, PWRITE, etc.)"]
            
            CB --- MODS --- SIGS
        end

        %% ========================================================
        %% 4. DUT: ALU TOP (Right Side)
        %% ========================================================
        subgraph DUT ["DUT: alu_top"]
            direction TB
            
            subgraph SLAVE ["APB Slave Module"]
                APB_FSM["APB State Machine"]
            end
            
            subgraph REGS ["Register File Module"]
                REG_MAP[("0x00: CTRL<br>0x04: OPERA<br>0x08: OPERB<br>0x0C: OPCODE<br>0x10: STATUS<br>0x14: RESULT")]
            end
            
            subgraph ALU ["ALU Core Module"]
                direction LR
                DEC["OPCODE<br>DECODER"]
                DP["ALU<br>Datapath"]
                MUX["OUTPUT<br>MUX"]
                FSM["ALU FSM<br>(2-Cycle)"]
                
                DEC --> DP --> MUX --> FSM
            end
            
            %% DUT Internal Routing
            SLAVE -->|"APB_ADDR, WDATA"| REGS
            REGS -->|"APB_RDATA"| SLAVE
            REGS -.->|"APB_STATUS[2] Stalls Bus"| SLAVE
            
            REGS -->|"A, B, opcode, start"| ALU
            ALU -->|"RESULT, Flags, done, busy"| REGS
            ALU -.->|"alu_done clears start"| REGS
        end

        %% ========================================================
        %% CROSS-DOMAIN ROUTING & CONNECTIONS
        %% ========================================================
        CLK_GEN -->|"Drives"| IF
        CLK_GEN -->|"PCLK, PRESET_n"| DUT
        
        IF -.->|"Registers vif"| CDB
        
        DRV -->|"Drives APB @drv_cb"| CB
        MON -.->|"Samples APB @mon_cb"| CB
        
        IF -->|"Connected via DUT Modport"| SLAVE
    end

    %% ========================================================
    %% STYLING & MATERIAL DESIGN COLOR PALETTE
    %% ========================================================
    classDef default fill:#f8f9fa,stroke:#ced4da,stroke-width:1px,color:#212529,font-family:sans-serif;
    
    %% Top Level
    classDef tb fill:#f3e5f5,stroke:#8e24aa,stroke-width:3px,color:#4a148c;
    
    %% UVM Components
    classDef uvm fill:#ede7f6,stroke:#5e35b1,stroke-width:2px,color:#311b92;
    classDef uvm_comp fill:#d1c4e9,stroke:#512da8,stroke-width:1px,color:#000;
    classDef uvm_test fill:#e8eaf6,stroke:#3f51b5,stroke-width:2px,color:#1a237e;
    classDef uvm_seq fill:#fce4ec,stroke:#c2185b,stroke-width:1px,color:#880e4f;
    classDef ral fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#bf360c;
    
    %% Interface & RTL
    classDef iface fill:#e0f2f1,stroke:#00695c,stroke-width:3px,color:#004d40;
    classDef dut fill:#e3f2fd,stroke:#1565c0,stroke-width:3px,color:#0d47a1;
    classDef inner logic fill:#bbdefb,stroke:#0288d1,stroke-width:1px,color:#000;
    classDef reg fill:#fff8e1,stroke:#f57f17,stroke-width:2px,color:#000;
    classDef db fill:#f1f8e9,stroke:#33691e,stroke-width:2px,color:#000;
    
    %% Assignments
    class TB_TOP tb;
    class UVM,TEST,ENV,AGENT uvm;
    class VSQR,SCBD,COV,SEQR,DRV,MON,REF,CG uvm_comp;
    class T1,T2,T3,T4,T5,TEST_LIB uvm_test;
    class S1,S2,S3,S4,S5,OP_SEQS,TX_SEQS,SEQ_LIB uvm_seq;
    class RAL,ADAPTER,PREDICTOR ral;
    class IF iface;
    class DUT dut;
    class REGS reg;
    class DEC,DP,MUX,FSM,SLAVE inner;
    class CDB,REG_MODEL,REG_MAP db;
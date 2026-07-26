// interface

interface apb_inft #(parameter WIDTH = 8s)();

    //apb signals
    logic             PCLK;
    logic             PRESET_n;
    logic             PSEL;
    logic             PENABLE;
    logic             PWRITE;

    logic [WIDTH-1:0] PADDR;
    logic [WIDTH-1:0] PWDATA;

    logic [WIDTH-1:0] PRDATA;
    logic             PREADY;

    //clocking clock driver
    clocking drv_cb @(posedge PCLK);
        default input #1step output #1;
        
        output PSEL;
        output PENABLE;
        output PWRITE;
        output PADDR;
        output PWDATA;

        input PRDATA;
        input PREADY;
    endclocking

    //clocking clock monitor
    clocking mon_cb @(posedge PCLK);
        default input #1step;
        
        input PSEL;
        input PENABLE;
        input PWRITE;
        input PADDR;
        input PWDATA;
        input PRDATA;
        input PREADY;
    endclocking

    //modport driver
    modport DRIVER(
        clocking drv_cb,
        output PCLK,
        output PRESET_n
    );
    //modport monitor
    modport MONITOR
    (
        clocking mon_cb,

        input PCLK,
        input PRESET_n
    );
    //modport DUT
    modport DUT(
        input PCLK,
        input PRESET_n,
        input PSEL,
        input PENABLE,
        input PWRITE,
        input PADDR,
        input PWDATA,
        output PRDATA,
        output PREADY
    );

endinterface
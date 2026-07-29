@echo off

echo ==============================
echo Cleaning old simulation files
echo ==============================

REM Delete logs and temp files
del /s /q *.log *.jou *.pb *.wdb *.txt *.vcd *.str 2>nul
del /s /q *.backup.* 2>nul
del /s /q *.crvsdump *.dbg *.mem *.reloc *.rtti *.svtype *.type *.xdbg 2>nul
del /s /q *.exe 2>nul

REM Delete simulation directory
rmdir /s /q xsim.dir 2>nul

echo Cleanup Done!
echo.

echo ==============================
echo Running Simulation
echo ==============================

echo Compiling Design...
@REM call xvlog -sv -f rtl\rtl.f
call xvlog C:\Users\akash\Downloads\alu_uvm_ip_vip\rtl\top\alu_top.v

echo Compiling Testbench...
@REM call xvlog -sv -f tb\tb.f
@REM call xvlog -sv -L uvm -i C:\UVM\1.2\src testbench.sv C:\UVM\1.2\src\uvm_pkg.sv
call xvlog -sv -L uvm -i C:\UVM\1.2\src tb\top\tb_top.sv C:\UVM\1.2\src\uvm_pkg.sv


echo Elaborating...
call xelab work.tb_top -s simv -timescale 1ns/1ns
@REM call xelab work.test -s simv -timescale 1ns/1ns

echo Running Simulation...
call xsim simv -runall

echo.
echo Simulation Completed!

echo ==============================
echo Running Regression Analysis
echo ==============================
call analyze_regression.bat

pause
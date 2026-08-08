@echo off

echo ==============================
echo Cleaning old simulation files
echo ==============================

REM Delete logs, temp files, and old coverage data
del /s /q *.log *.jou *.pb *.wdb *.txt *.vcd *.str 2>nul
del /s /q *.backup.* 2>nul
del /s /q *.crvsdump *.dbg *.mem *.reloc *.rtti *.svtype *.type *.xdbg 2>nul
del /s /q *.exe 2>nul

REM Delete simulation and coverage directories
rmdir /s /q xsim.dir 2>nul
rmdir /s /q cov_db 2>nul
rmdir /s /q cov_report 2>nul

echo Cleanup Done!
echo.

echo ==============================
echo Running Simulation
echo ==============================

echo Compiling Design...
call xvlog C:\Users\akash\Downloads\alu_uvm_ip_vip\rtl\top\alu_top.v

echo Compiling Testbench...
call xvlog -sv -L uvm -i C:\UVM\1.2\src tb\top\tb_top.sv C:\UVM\1.2\src\uvm_pkg.sv

echo Elaborating...
REM Added Coverage Flags: -cc_type (code coverage), -cov_db_name, -cov_db_dir
call xelab work.tb_top -s simv -timescale 1ns/1ns -cc_type sbct -cov_db_name alu_cov -cov_db_dir ./cov_db

echo Running Simulation...
call xsim simv -runall

echo.
echo Simulation Completed!

echo ==============================
echo Generating Coverage Reports
echo ==============================

REM 1. Generate Functional Coverage Report (Reads from xsim.covdb)
call xcrg -dir ./cov_db -db_name alu_cov -report_dir ./cov_report/functional -report_format html

REM 2. Generate Code Coverage Report (Reads from xsim.codeCov)
call xcrg -cc_dir ./cov_db -cc_db alu_cov -cc_report ./cov_report/code -report_format html

echo.
echo Functional coverage report generated in: .\cov_report\functional\dashboard.html
echo Code coverage report generated in: .\cov_report\code\dashboard.html

echo ==============================
echo Running Regression Analysis
echo ==============================
call analyze_regression.bat

pause
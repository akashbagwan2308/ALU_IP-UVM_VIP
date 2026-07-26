@echo off
setlocal

echo ========================================
echo Setting up Simulation Workspace
echo ========================================

REM Create the sim directory if it doesn't exist
if not exist sim mkdir sim

REM Step into the simulation directory to quarantine all generated logs and files
cd sim

echo ========================================
echo Cleaning old simulation artifacts
echo ========================================
REM Because we are inside the dedicated 'sim' folder, we can safely wipe everything
del /q /s *.* 2>nul
rmdir /s /q xsim.dir 2>nul


echo.
echo ========================================
echo Compiling Design
echo ========================================
REM Use relative paths pointing back to the RTL folder
call xvlog -sv ..\rtl\top\alu_top.v
REM Tip: When ready, switch back to your file list instead of hardcoding the top file:
REM call xvlog -sv -f ..\rtl\rtl.f

echo.
echo ========================================
echo Compiling Testbench
echo ========================================
REM Use relative path for the testbench
call xvlog -sv -L uvm -i C:\UVM\1.2\src ..\verilog_testbench\testbench.sv C:\UVM\1.2\src\uvm_pkg.sv

echo.
echo ========================================
echo Elaborating
echo ========================================
REM Added '-debug typical' to ensure you can generate waveforms (VCD/WDB)
call xelab work.test -s simv -debug typical

echo.
echo ========================================
echo Running Simulation
echo ========================================
call xsim simv -runall

echo.
echo ========================================
echo Simulation Completed!
echo ========================================

REM Step back out to the root directory
cd ..
pause
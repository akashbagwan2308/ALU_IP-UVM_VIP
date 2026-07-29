@echo off
setlocal enabledelayedexpansion

REM Generate a reliable timestamp using PowerShell (WMIC is deprecated on newer Windows)
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set TIMESTAMP=%%I

set SIM_LOG=xsim.log
set REPORT=regression_report_!TIMESTAMP!.txt
set TEMP_MSG_FILE=temp_unique_msgs.txt

echo ==========================================
echo       REGRESSION ANALYSIS REPORT
echo ==========================================
echo.

REM Check if log file exists
if not exist "%SIM_LOG%" (
    echo [ERROR] Simulation log '%SIM_LOG%' not found!
    echo Did the simulation run successfully?
    pause
    exit /b 1
)

echo Parsing %SIM_LOG%...
echo.

REM Initialize Counters
set uvm_fatal_cnt=0
set uvm_error_cnt=0
set uvm_warn_cnt=0
set sva_fail_cnt=0
set scbd_pass_cnt=0
set scbd_fail_cnt=0

REM Count occurrences using findstr and find /c
for /f %%A in ('findstr /C:"UVM_FATAL C" "%SIM_LOG%" 2^>nul ^| find /c /v ""') do set uvm_fatal_cnt=%%A
for /f %%A in ('findstr /C:"UVM_ERROR C" "%SIM_LOG%" 2^>nul ^| find /c /v ""') do set uvm_error_cnt=%%A
for /f %%A in ('findstr /C:"UVM_WARNING C" "%SIM_LOG%" 2^>nul ^| find /c /v ""') do set uvm_warn_cnt=%%A
for /f %%A in ('findstr /C:"Error: [SVA]" "%SIM_LOG%" 2^>nul ^| find /c /v ""') do set sva_fail_cnt=%%A
for /f %%A in ('findstr /C:"[SCBD_PASS] O" "%SIM_LOG%" 2^>nul ^| find /c /v ""') do set scbd_pass_cnt=%%A
for /f %%A in ('findstr /C:"[SCBD_FAIL] O" "%SIM_LOG%" 2^>nul ^| find /c /v ""') do set scbd_fail_cnt=%%A

REM Determine Overall Status
set TEST_STATUS=PASSED
if !uvm_fatal_cnt! GTR 0 set TEST_STATUS=FAILED
if !uvm_error_cnt! GTR 0 set TEST_STATUS=FAILED
if !sva_fail_cnt! GTR 0 set TEST_STATUS=FAILED
if !scbd_fail_cnt! GTR 0 set TEST_STATUS=FAILED

REM Extract Unique UVM_ERROR and UVM_FATAL messages using PowerShell
REM This saves the unique lines to a temporary file in ASCII format to prevent batch escaping issues
powershell -NoProfile -Command "$matches = Select-String -Path '%SIM_LOG%' -Pattern 'UVM_ERROR|UVM_FATAL'; if ($matches) { $matches.Line | Sort-Object -Unique | Out-File -FilePath '%TEMP_MSG_FILE%' -Encoding ascii } else { 'None found.' | Out-File -FilePath '%TEMP_MSG_FILE%' -Encoding ascii }"

REM Output to terminal
echo ------------------------------------------
echo               SUMMARY METRICS             
echo ------------------------------------------
echo UVM_FATAL      : !uvm_fatal_cnt!
echo UVM_ERROR      : !uvm_error_cnt!
echo UVM_WARNING    : !uvm_warn_cnt!
echo SVA Violations : !sva_fail_cnt!
echo Scoreboard PASS: !scbd_pass_cnt!
echo Scoreboard FAIL: !scbd_fail_cnt!
echo ------------------------------------------
echo     UNIQUE ERROR ^& FATAL MESSAGES
echo ------------------------------------------
type "%TEMP_MSG_FILE%"
echo ------------------------------------------

if "!TEST_STATUS!"=="PASSED" (
    echo Overall Status : [ PASSED ]
) else (
    echo Overall Status : [ FAILED ]
)
echo ==========================================

REM Save results to a text file for record keeping
> "%REPORT%" echo ==========================================
>> "%REPORT%" echo       REGRESSION ANALYSIS REPORT
>> "%REPORT%" echo ==========================================
>> "%REPORT%" echo Date/Time      : %date% %time%
>> "%REPORT%" echo Target Log     : %SIM_LOG%
>> "%REPORT%" echo.
>> "%REPORT%" echo UVM_FATAL      : !uvm_fatal_cnt!
>> "%REPORT%" echo UVM_ERROR      : !uvm_error_cnt!
>> "%REPORT%" echo UVM_WARNING    : !uvm_warn_cnt!
>> "%REPORT%" echo SVA Violations : !sva_fail_cnt!
>> "%REPORT%" echo Scoreboard PASS: !scbd_pass_cnt!
>> "%REPORT%" echo Scoreboard FAIL: !scbd_fail_cnt!
>> "%REPORT%" echo.
>> "%REPORT%" echo ------------------------------------------
>> "%REPORT%" echo     UNIQUE ERROR ^& FATAL MESSAGES
>> "%REPORT%" echo ------------------------------------------
type "%TEMP_MSG_FILE%" >> "%REPORT%"
>> "%REPORT%" echo ------------------------------------------
>> "%REPORT%" echo.
>> "%REPORT%" echo Overall Status : !TEST_STATUS!
>> "%REPORT%" echo ==========================================

REM Cleanup the temporary file
if exist "%TEMP_MSG_FILE%" del "%TEMP_MSG_FILE%"

echo.
echo Detailed report saved to %REPORT%
pause
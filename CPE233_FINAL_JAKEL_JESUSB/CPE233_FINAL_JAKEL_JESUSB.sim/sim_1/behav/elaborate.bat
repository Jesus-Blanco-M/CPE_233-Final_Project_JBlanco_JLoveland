@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto f93155657d1143d09732e9827d69838b -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot testbench_behav xil_defaultlib.testbench -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0

@echo off
REM ****************************************************************************
REM Vivado (TM) v2017.4 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Thu Mar 15 16:07:02 -0700 2018
REM SW Build 2086221 on Fri Dec 15 20:55:39 MST 2017
REM
REM Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
call xsim RAT_wrapper_behav -key {Behavioral:sim_1:Functional:RAT_wrapper} -tclbatch RAT_wrapper.tcl -view C:/Users/Jesus Blanco/Documents/Assignment_6/Assignment_6.srcs/sim_1/imports/CPE_233_HW_4_RAT_Wrapper_2_10_18_Working_SlowedClock/testbench_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0

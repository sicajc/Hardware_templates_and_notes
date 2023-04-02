# DC WorkFlow that tries to save your time
## Before going dc or eda cloud.
0. Throw your design into Vivado first to check whether your design is synthesizable or not first.
1. Remove the delay of your design then run again,making sure it works, note the delay should be less than 1.0
2. Seperate the files into HDL,SIM,SYN
- HDL contains designs all *.v
- SIM contains your data and tb.sv or tb.v
- SYN contains your scripts for synthesis, sdf file and synopsys.dc_setup, also your synthesis result.
- Partition your SYN file into REPORT,NETLIST,PROCESS
- You can use *.v or *.sv to quickly moves files between each folders.

## File editing
1. Double check if you code it correct after you merged your design into 1 single file. Rerun the design again to make sure it works.
2. Set the file directory of TB,SDF to the local directory.
3. Do the synthesis from SYN. The generated result is also stored in SYN, there should be no other places containing syn result.
4. Check the clock cycle of your design, also the clock cycle specified in TB's design.
5. Check for the CLK or clk name in tcl script, is it the same as the clock name you defined in your design?
6. Change the name of dc.tcl into the design you want and set the directory of your tcl right.
7. Check if the dc uses elaborate analyze technique.

## Into DC
### 00_run_RTL
1. First run the RTL sim using vcs or ncverilog to make sure that your design is correct in RTL level.
2. Run for all test cases you want to check.

### 01_run_dc
1. First do a fast compile without using
2. Remember to add -load_delay net
```
compile_ultra -your goal

```
2. Then see the report to see if the specification is met.

### 02_run_GATE
1. Run to see if Gate level pass, tsmc_neg13.v is needed!
2. The tsmc_neg13.v must be placed in the folder of SYN.
3. SDF, SYN.v should be generated in this process and placed in SYN folder.

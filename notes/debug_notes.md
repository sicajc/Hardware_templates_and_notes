# Debug notes
## Debugging tips
1. Fatal simulation error can come from coding style.
2. You can first run till IMPLEMENTATION to check for whether multiple drives error exists.
3. You can group and add Divider to clearly seperate signals for better visualization
4. When debugging, you paper and graph for debugging! Dont try to simply guess! It would destroy the whole system.
5. Each time you are making a major changes, commit first!
6. Debug breakpoints can be added to help you monitor the signal.
7. Printing out signals can be a good way of debugging.

## Algorithmic level
0. VISUALIZE, VISUALIZE, VISUALIZE!!!! From an example, trace through the whole code when debugging.
1. Which Data structure you are going to use? Implement its interfaces.
2. Are you reading the spec corecctly? Did you consider every cases?
3. Decision tables and Decision tress can help resolving complex logics.
4. Basic DFG can help you identify the flow process of the algorithm.
5. Is the algorithm you choose hardware friendly?
6. Do some basic examples first and then trace through the whole process.
7. Consider some corner cases, n=1 or some transition condition, the boundary conditions, or some backtracking possibility.
8. Generalise your thought into psuedoCode, trace through the pseudo code again using easy example, boundary conditions and base case.
9. From the psuedoCode, fast code it using python and test with easy non trivial example,base case and boundary conditions.
10. After the algorithm works, you can generate TB and start designing your architecture.
11. When doing Sequential analysis, do not think about parrlellism.
12. Reusing codeBlocks allows you to create design faster.


##  Architecture level
- Converting your design into ASMD chart, you can at the same time, visualize your datapath components.
0. Do a fast analysis, from the design goal identify where you need to optimize in terms of architecture.
1. Draw out the block diagram and tries the connect the block diagram with wires.
2. Specify the main components for your design. CTR,CNTS,FF,CIRCULAR BUF,STACK,PROCESSOR,I/O etc...
3. List out the condition flags for termination as a table for fast trace.
4. Trace the whole block diagram using simple example, also try to visualize the delays happening in this process.
5. Is the delay correct? Should you add more delays?
6. Draw the interface out, ONLY draw the datapath components out.

## Drawing Blocks
0. From ASMD chart draw out the following.
1. Combining CNTs and PTRs with the Main control blocks.
2. Simply seperate the datapath components away from the controller.
3. Uses only Blocks, draw it on a large paper using pencil.
4. Specify the I/O signal boundary, draw the name of your signals.
5. Seperate Combinational block and Sequential block.
6. Draw out the Muxes and Demuxes.
7. Draw out the control signals controlling the blocks and the muxes.
8. Connect signal using rulers. The signal must be straight and perpendicular to each other.

## Post-implementation debugging.
0. Check for FSM, is your FSM behaving correctly?
1. Check for control flags, are they in the condition you hope to terminate?
2. Check for sub-controls and cnts, are they counting as you expected?
3. Check for the transition edges of the state, is the value preserved correctly? Does the value reseted correctly?
4. Check for the transition of state, does the value come late or not?
5. Check for sequential assignments and combinational assignments?
6. Check for your wrong signal, have you assigned the wrong signal value?
7. Check for the array index, is the array index you specified correct?
8. Check for bit Width declration, is your bit width enough?
9. Check for possibility when Overflowing, this happens a lot when doing arithmetic operations, signed value also has possibility of overFlowing.
10. For the problem of convergence, check for boundary conditions.
11. Check for the consistency of data types, is the signal you assigned to of the same data type? Sign and unsigned.
12. Check for concatenation and sign-extension error, did you align the value in a right way?
13. Check for data placement problem, when sharing registers, did you place the value in the right position of the register?
14. Check for the value sent in, did you sample the correct data?
15. Check for Vivado Erros and Warnings, clear them all.
16. Check for vivado synthesis error and warnings.

# Testbench
1. Uses Random pattern for common functional case.
2. Add 0,+inf,-inf to your pattern to check for validity.

# Block Timing
1. Decode and generate valid signals, propogate the valid signal along with the data through the pipeline.
2. Pipelining the circuit if the calculation is done in an ordered manner.
3. Parrallel processing if there is a lot of if~else conditions. Generate HWs for each if else condition. Select the result using a MUX

# MAC Tree
- This is actually valid and usable which generates an adder tree.
```verilog

    integer i;
    for(i = 0;i<N;i=i+1)
    begin
        sum = 0;
        sum = sum + partial_sum[i];
    end

    always@(*)
    begin
        // This generates a MAC tree, Output at product, must consider the maximum number of product length to accommodate all possible value.
        product = 0;
        product = mult[0] * K1 + mult[0] * K1;
        product = mult[1] * K2 + product;
        product = mult[3] * K3 + product;
        product = mult[4] * K4 + product;
    end
```

# Memory technique
- To increase the size of memory or increase the BW of memory, since memory are usually given as block of fixed size.
1. Banking the memory to increase BW
2. Bit slicing also helps.

# SRAM access
1. If the data you want to access is more than 1KB, uses SRAM which comprises 1 Row decoder and another column decoder.
2. SRAM, when reading data, first sends addr, then after a cycle, output come out.
3. Write, sends in the data and address at the same time.


# DRAM access
1. DRAM in seperated into multiple banks, usually 10MB~512MB size of DRAM is used.
2. First Find bank, activate the bank, select row and then select column, reading out the whole column out.
3. Thus enabling us to read consecutive data.
4. If we want to read data from another bank, must turn off the current bank, turn on another bank to enable the reading.
5. The data sequence order within DRAM matters, since we do not want data lies within another bank. Reactivating bank need time.
6. Turning on and switching the bank usually takes 4~5 cycles, thus we usually would like to place likely used data within the same bank.



# System design
1. Spec analysis in terms of how many ARITHMETIC units you might need, to meet the required computational speed.
2. Do basic analysis, basic math and calculate the execution time.
3. Select the algorithm, do algorithmic strength reduction on the algorithm to make the algorithm more HW friendly.
4. Common subexpression sharing is  a useful technique, this is also a type of algorithmic strength reduction.
5. We can use LUT or ROM table to replace the multiplier, then select the desired output from the ROM table to reduce the area and power.

# CSD(Canonical Signed Digit)
1. A type of representation used in booth multiplier to reduce the computation cost of one multiplier into add and subtract operations. This is also a type of algorithmic strength reduction.


# AXI
## Error problem
1. Valid originally pulls up to one, note only when ready pulls up and down once, valid can be pulled down. This need to be varified using VIP.

## Access pattern
1. First Address handshaking then next perform write data handshaking to complete one data transcation.

## Handshaking
1. valid, ready and response



## Master & Slave
1. Two types of ports exist, master port and slave port.
2. There might be multiple ports on an interface. Master port controls the slave port. Slave must wait until the handshaking is completed to pull the ready signal down, or send the write response back to Master.
3. Only master sends address, slave cannot send address.
4. Only when half full of a fifo will we start sending the value to slave as a master.
5. Write response is for telling the master as a slave if the data write in is sucessul or not, if fial, we will send error back.
6. Register space just like the address of RF, usually we reads out a multiple consecutive address space within 1 blank of data.

## Decoding of address
1. When decoding address 00,01,02,03 must all get mapped to 00, you shall not forget to do the decoding.
2. 04,05,06,07 mapped to 04.
3. Since in AXI, usually it is byte addressable.
4. Thus such design must be addressed.


## 5 ports
1. read channel
2. addr write channel
3. addr read channel
4. write channel
5. write response channel
- These all follows the protocal of AXI, simply a protocals for handshaking.


## Concept of MMIO
1. In AXI, all devices are just address space.
2.

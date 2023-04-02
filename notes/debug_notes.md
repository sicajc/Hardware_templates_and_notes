# Debug notes
## Debugging tips
1. Fatal simulation error can come from coding style.
2. You can group and add Divider to clearly seperate signals for better visualization
3. When debugging, you paper and graph for debugging! Dont try to simply guess! It would destroy the whole system.
4. Each time you are making a major changes, commit first!
5. Debug breakpoints can be added to help you monitor the signal.
6. Printing out signals can be a good way of debugging.

## Algorithm level
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

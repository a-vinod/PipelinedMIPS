# Pipelined MIPS

We implemented four versions of a pipelined MIPS architecture from scratch using Verilog. The implementations were developed and simulated using ModelSim.

These processors are based on the [Harvard architecture](https://en.wikipedia.org/wiki/Harvard_architecture). They're five-stage processors as specified in [Digital Design and Computer Architecture by Harris & Harris](https://www.amazon.com/Digital-Design-Computer-Architecture-Harris/dp/0123944244). Forwarding and stalling logic is used to handle hazards.

**Fetch** &rarr; **Decode** &rarr; **Execute** &rarr; **Memory** &rarr; **Writeback**

| Stage | Description |
| --- | --- |
| `Fetch` | Fetch instruction from instruction cache/memory. If there's a branch predictor, this is where it will use the program counter to make a prediction. |
| `Decode` | Decode the instruction into a collection of control signals and read data from registers referenced by the instruciton from register file. This is also where it's determined if the instruction is a branch taken. |
| `Execute` | Execute the arithmetic required for the instruction using the ALU. |
| `Memory` | If the instruction is a `LW` or `SW`, this stage is where values in registers are read or written to data memory. |
| `Writeback` | The logic to determine the PC for the next cycle is here. In addition, the result from the execution stage is sent back to the decode stage to update values of registers. |

Each implementation is dedicated its own branch in this repository. Namely:

| Branch | Description |
| --- | --- |
| `data_instr_cache` | Most basic implementation of the five-stage processor with a data and instruction cache. On a cache miss, main memory accesses take 20 cycles.(See Proj. 2 Report) |
| `local_branch_predictor` | Uses a 2-bit local branch predictor. (See Proj. 3 Report) |
| `global_branch_predictor` | Uses a 2-bit global branch predictor. (See Proj. 3 Report)|
| `dual_issue` | A dual-issue superscalar five-stage processor. (See Proj. 4 Report) |

The following ISA is supported by these implementations: 

- add
- addi
- sub
- and
- or
- xor
- xnor
- andi
- ori
- xori
- slt
- slti
- lw (20 cycles on cache miss)
- sw
- lui
- jal
- bne
- beq

The following instructions are supported by all the processors EXCEPT for the dual-issue superscalar:

- mult (32 cycles)
- multu (32 cycles)
- mflo
- mfhi

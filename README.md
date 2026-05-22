# MIPS32 Pipelined Processor Core

A 32-bit MIPS RISC processor core implemented in Systemverilog, featuring a classic 5-stage pipeline with data forwarding and flush-based hazard control.

---

## Pipeline Architecture

Classic 5-stage pipeline:

```
IF  →  ID  →  EX  →  MEM  →  WB
```

| Stage | Description |
|-------|-------------|
| IF  | Instruction Fetch |
| ID  | Instruction Decode & Register Read |
| EX  | Execute / ALU Operation |
| MEM | Memory Access |
| WB  | Write Back |

### Hazard Handling

- **Forwarding Unit** — resolves RAW (Read After Write) data hazards by forwarding results from EX/MEM/WB stages directly to the EX stage inputs, avoiding unnecessary stalls.
- **Flush Logic** — handles control hazards (branches) by flushing incorrectly fetched instructions from the pipeline on a taken branch.

---

## Pipeline Diagram

<!-- Add pipeline diagram image here -->
> _Pipeline diagram with forwarding paths coming soon._

---

## Verification Architecture
<!-- Add pipeline diagram image here -->
> _verification diagram coming soon._

---

### Approach

The core was verified using a **reference model-based approach** with both random and directed stimulus generation:

- A reference model runs in parallel with the RTL.
- Outputs are compared after every instruction.
- A random stimulus generator drives instruction sequences automatically, with an option to switch to directed test cases for targeted scenario coverage.

### Test Scenarios

| Scenario | Focus |
|----------|-------|
| R-type instructions | ALU correctness |
| I-type instructions | Immediate operations |
| Load / Store | Memory read-write correctness |
| Branch instructions | Control flow, flush logic |
| Data hazard sequences | Forwarding unit correctness |
| Load-use hazards | Stall + forward interaction |

---

## Sample Instructions

### R-Type

```asm
add $t3, $t1, $t2
sub $t4, $t1, $t2
and $t5, $t1, $t2
or  $t6, $t1, $t2
mul $t7, $t1, $t2
```

### I-Type

```asm
addi $t0, $t1, 25
```

### Load / Store

```asm
lw $t0, 0($t1)
sw $t2, 1($t1)
```

---

### Branch with Data Hazard (BEQZ)

```asm
addi $t0, $t1, 0
beqz $t0, LABEL        ; control hazard — flush tested here
add  $t1, $t0, $t0
LABEL:
addi $t2, $zero, 10
```

### Branch with Data Hazard (BNEQZ)

```asm
sub  $t0, $t1, $t2
bneqz $t0, LABEL
add  $t1, $t0, $t0
LABEL:
addi $t3, $zero, 10
```

### DATA Hazard - dependency on result produced

```asm
ADD $t1, $t2, $t3      ; produces $t1
ADD $t4, $t1, $t5      ; Forwarding tested here
ADD $t6, $t7, $t1      ; Forwarding tested here
```
```asm
ADD $t1, $t2, $t3      ; first write to $t1
ADD $t1, $t4, $t5      ; second write to $t1
ADD $t6, $t1, $t7      ; must read latest $t1
```

### Load-Use Hazard

```asm
lw $t3, 1($t1)         ; load followed by dependent use
ADD $t4,$t3,$t2        ;$t3 is used as source register here 
```

---

## Repository Structure

```
mips32-core/
├── rtl/               # Verilog RTL source files
├── tb/                # Testbenches
├── ref_model/         # Reference model (golden interpreter)
├── sim/               # Simulation scripts and waveforms
└── docs/              # Block diagrams and documentation
```

---


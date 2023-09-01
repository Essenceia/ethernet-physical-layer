# Test bench

This directory contains a collection of self checking unit and top level testing suite
targeting our PCS implementation.
It is built from the top level Makefile.

## Overview

Top level test bench :
`pcs_tb.sv` covers `rx` and `tx` is driven via the `vpi` by `C/C++` code contained in the `vpi` folder

Unit test benches : 
`am_tx_tb.sv` `tx` alignment marker content check, uses `vpi` and expected results are provided by `C/C++` code.
`block_sync_rx_tb.sv`  checks `rx` block lock follows behaviour outlines in clause 82.12 
`lane_reorder_rx_tb.sv` `rx` lane reordering check 
`xgmii_dec_rx_tb.sv` check translation from internal decoded 
    representation to standard xgmii representation, used for compatibility
    with third party MACs.
`_64b66b_tb.sv` checks scrambler and descrambler behavior, data going though
    scrambler then descrambler should match original
`pcs_10g_enc_tb.sv` check xgmii to internal representation interface behavior,
    this is the `tx` counterpart to the `rx` `xgmii_dec_rx_tb`
`am_lock_rx_tb.sv` check `rx` alignment locking matches behavior outlined in clause 82.13
`deskew_rx_tb.sv` check skew compensation and lane realignment on `rx` path
`gearbox_tx_tb.sv` check `tx` path 66b to 64b gearbox 


### Simulators 

This project support **2 simulators** `iverilog` and `verilator`.
We recommend using `verilator` for speed.

To switch between simulators set the `SIM` variable when invoking make.
```
make SIM=<I or V> [...]
```

By default `iverilog` will be used.

`SIM` values :

- `I` : use `iverilog`

- `V` : use `verilator`

### Get waves

Waves will be written to files in the root `wave` directory.

### Other options

To disable waves :
```
make wave= [...]
```

To disable fail on asserts when using verilator asserts :
```
make assert= [....]
```

To enable debug logs
```
make clean
make debug=1 [...]
```
## Unit test 

Commands for running the none `vpi` unit test benches.

#### scrambler / decrambler
```
make run__64b66b
```

#### TX gearbox
```
make run_gearbox_tx
```

#### RX block sync
```
make run_sync_rx
```

#### RX Alignment marker lock
```
make run_am_lock_rx
```

#### RX lane reordering 
```
make run_lane_reorder_rx
```

#### RX xgmii decoder interface 
```
make run_xgmii_dec_rx
```

#### RX lane deskew
```
make run_deskew_rx
```
 
## VPI

**Before** running and test benches using the `vpi` please set the path to the
`vpi` library..

### Setup VPI library

Some of our test benches use a golden model coded in `C/C++` and uses the `vpi` to interface
with our system verilog test bench.
These golden models will be compiled into a dynamically relocatable library that will
be loaded at run time by the simulator.

Taking into account the simulator you will be using check the path to the simulator library 
in the `tb/vpi/Makefile` through the `VPI_INC` variable. 


### Full 40Gbe PCS

Full test bench for the 4 lane, 64 bits per lane, 40GBASE-R.
I recommend using verilator to speed up this test.

To build a run:
```
make clean
make SIM=V run_pcs
```

## 40Gbe PCS alignment marker

Partial test bench covering only the alignment marker logic. 
Although this block is also tested under the full 40Gbe PCS test bench, 
because the alignment marker is only added on a per lane bases every 16383 blocks
I have decided to create a special test bench targeting only this feature to speed
up iterations.

To build and run :
```
make clean
make run_am_tx
```



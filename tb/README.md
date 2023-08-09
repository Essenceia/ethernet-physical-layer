# Test bench

In order to test these PCS implementations multiple test benches are available.

These test benches use `iverilog` as a simulator.
**Before** running and test benches using the `vpi` please follow the setup instructions.

Currently only 40Gbe test benches are in use, as such there is no guaranty on the state 
of the 10Gbe benches.

## Setup VPI library

Some of our test benches use a golden model coded in `C` and the `vpi` to interface with our system verilog test bench.
These golden models will be compiled into a dynamically relocatable library that will
be loaded at run time by the simulator.

Since we use `iverilog` as a simulator, in our build process we need to
provide the `path` to the folder where `iverilog` library files reside.

This is set by the `IVERILOG` variable in the `tb/vpi/makefile`.

If this is not set correctly during the `vpi` build process `vpi_user.h` will not be found.

## Full 40Gbe PCS

Full test bench for the 4 lane, 64 bits per lane, 40GBASE-R.
This bench is driven by a golden model coded in C and interfaces with our
rtl via a `vpi` interface.


To build and run this model, at project root run :
```
make clean
make run
```

To get debug logs :
```
make run debug=1
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
make run_marker
```

To get debug logs :
```
make run debug=1
```

## Get waves

Waves will be opened using the viewer specified by `VIEW`, by default this is set to
`gtkwave`. This is configured in the root `makefile`.  

```
make wave
```

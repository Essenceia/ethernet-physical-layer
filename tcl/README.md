# FPGA build flow

Build flow target's `quartus` and is by default set to target the intel cyclone 10 GX `10CX150YF780E5G`.

This project is a work in progress, we are not generating the device configuation file as of today.
The default design implements a single 10GBASE-R PMA+PCS in loopback mode.

## Quickstart


To create quartus project, generate IPs, run place, route, and generate timming reports:

```sh
make build
```



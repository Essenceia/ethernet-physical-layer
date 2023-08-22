# TODO list

- add formal assertions

- LINT :
    - remove `-Wno-LATCH` 

- 10BASE-R
    - add testbench for full pcs tx lite in 16b
- TX
    - enc : add support for control codes O
    - enc : add error

. RX 
    - dec : add support for control codes 0
    - discard alignement markers in top
    - modify top level to exclude alignement marker
      related features for 10g
    - fake gearbox in tb
    - write 10G version

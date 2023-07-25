# RTL Ethernet Physical Layer

Physical layer rtl to be shared between the very low latency ethernet application and the
compliant network verification ethernet application.
Modules should be parametrisable to support multiple configurations. 

## Objective

The objective is to support using different modules 10GBASE-R and 40GBASE-R.

10GBASE-R:

- 16b wide data path, very low latency

- 64b wide data path, no latency requirement

40GBASE-R:

- ?b wide data part, very low latency

- 256b wide data path, no latency requirement

Features not supported :

- MDIO

- RS - Reconsiliation Sublayer

- WIS - WAN Interface Sublayer

- EEE - Ethernet Energy Efficiency 

# License 

This code uses the MIT license, all rights belong to Julia Desmazes.


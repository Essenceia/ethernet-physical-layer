# Custom board pin assignement

set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 780
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1

#[Transceiver Ref Clocks]
set_location_assignment PIN_U24 -to GXB1C_644M
set_location_assignment PIN_R24 -to GXB1D_125M
set_location_assignment PIN_N24 -to GXB1D_644M
set_instance_assignment -name IO_STANDARD LVDS -to GXB1C_644M -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD LVDS -to GXB1D_125M -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD LVDS -to GXB1D_644M -entity c10gx_pinout
set_location_assignment PIN_U23 -to "GXB1C_644M(n)"
set_location_assignment PIN_R23 -to "GXB1D_125M(n)"
set_location_assignment PIN_N23 -to "GXB1D_644M(n)"

#[Transceiver Lanes (Bank 1D)]
set_location_assignment PIN_P26 -to GXB1D_RXD[0]
set_location_assignment PIN_M26 -to GXB1D_RXD[1]
set_location_assignment PIN_K26 -to GXB1D_RXD[2]
set_location_assignment PIN_H26 -to GXB1D_RXD[3]
set_location_assignment PIN_F26 -to GXB1D_RXD[4]
set_location_assignment PIN_D26 -to GXB1D_RXD[5]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to GXB1D_RXD[*] -entity c10gx_pinout
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 0_9V -to GXB1D_RXD[*] -entity c10gx_pinout
set_location_assignment PIN_D25 -to "GXB1D_RXD[5](n)"
set_location_assignment PIN_F25 -to "GXB1D_RXD[4](n)"
set_location_assignment PIN_H25 -to "GXB1D_RXD[3](n)"
set_location_assignment PIN_K25 -to "GXB1D_RXD[2](n)"
set_location_assignment PIN_M25 -to "GXB1D_RXD[1](n)"
set_location_assignment PIN_P25 -to "GXB1D_RXD[0](n)"
set_location_assignment PIN_R28 -to GXB1D_TXD[0]
set_location_assignment PIN_N28 -to GXB1D_TXD[1]
set_location_assignment PIN_L28 -to GXB1D_TXD[2]
set_location_assignment PIN_J28 -to GXB1D_TXD[3]
set_location_assignment PIN_G28 -to GXB1D_TXD[4]
set_location_assignment PIN_E28 -to GXB1D_TXD[5]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to GXB1D_TXD[*] -entity c10gx_pinout
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 0_9V -to GXB1D_TXD[*] -entity c10gx_pinout
set_location_assignment PIN_E27 -to "GXB1D_TXD[5](n)"
set_location_assignment PIN_G27 -to "GXB1D_TXD[4](n)"
set_location_assignment PIN_J27 -to "GXB1D_TXD[3](n)"
set_location_assignment PIN_L27 -to "GXB1D_TXD[2](n)"
set_location_assignment PIN_N27 -to "GXB1D_TXD[1](n)"
set_location_assignment PIN_R27 -to "GXB1D_TXD[0](n)"

#[Transceiver Lanes (Bank 1C)]
set_location_assignment PIN_AF26 -to GXB1C_RXD[0]
set_location_assignment PIN_AD26 -to GXB1C_RXD[1]
set_location_assignment PIN_AB26 -to GXB1C_RXD[2]
set_location_assignment PIN_Y26 -to GXB1C_RXD[3]
set_location_assignment PIN_V26 -to GXB1C_RXD[4]
set_location_assignment PIN_T26 -to GXB1C_RXD[5]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to GXB1C_RXD[*] -entity c10gx_pinout
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 0_9V -to GXB1C_RXD[*] -entity c10gx_pinout
set_location_assignment PIN_T25 -to "GXB1C_RXD[5](n)"
set_location_assignment PIN_V25 -to "GXB1C_RXD[4](n)"
set_location_assignment PIN_Y25 -to "GXB1C_RXD[3](n)"
set_location_assignment PIN_AB25 -to "GXB1C_RXD[2](n)"
set_location_assignment PIN_AD25 -to "GXB1C_RXD[1](n)"
set_location_assignment PIN_AF25 -to "GXB1C_RXD[0](n)"
set_location_assignment PIN_AG28 -to GXB1C_TXD[0]
set_location_assignment PIN_AE28 -to GXB1C_TXD[1]
set_location_assignment PIN_AC28 -to GXB1C_TXD[2]
set_location_assignment PIN_AA28 -to GXB1C_TXD[3]
set_location_assignment PIN_W28 -to GXB1C_TXD[4]
set_location_assignment PIN_U28 -to GXB1C_TXD[5]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to GXB1C_TXD[*] -entity c10gx_pinout
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 0_9V -to GXB1C_TXD[*] -entity c10gx_pinout
set_location_assignment PIN_U27 -to "GXB1C_TXD[5](n)"
set_location_assignment PIN_W27 -to "GXB1C_TXD[4](n)"
set_location_assignment PIN_AA27 -to "GXB1C_TXD[3](n)"
set_location_assignment PIN_AC27 -to "GXB1C_TXD[2](n)"
set_location_assignment PIN_AE27 -to "GXB1C_TXD[1](n)"
set_location_assignment PIN_AG27 -to "GXB1C_TXD[0](n)"

#[SRAM]
set_location_assignment PIN_AH18 -to SRAM_CSn
set_location_assignment PIN_AF17 -to SRAM_OEn
set_location_assignment PIN_AG13 -to SRAM_WEn
set_location_assignment PIN_AF16 -to SRAM_LBn
set_location_assignment PIN_AE17 -to SRAM_UBn
set_location_assignment PIN_AG9 -to SRAM_A[10]
set_location_assignment PIN_AE10 -to SRAM_A[11]
set_location_assignment PIN_AE11 -to SRAM_A[12]
set_location_assignment PIN_AF11 -to SRAM_A[13]
set_location_assignment PIN_AG21 -to SRAM_A[1]
set_location_assignment PIN_AH21 -to SRAM_A[0]
set_location_assignment PIN_AE16 -to SRAM_D[15]
set_location_assignment PIN_AH10 -to SRAM_A[9]
set_location_assignment PIN_AG10 -to SRAM_A[8]
set_location_assignment PIN_AH11 -to SRAM_A[7]
set_location_assignment PIN_AE12 -to SRAM_A[14]
set_location_assignment PIN_AF18 -to SRAM_A[15]
set_location_assignment PIN_AE19 -to SRAM_A[16]
set_location_assignment PIN_AH20 -to SRAM_A[2]
set_location_assignment PIN_AG20 -to SRAM_A[3]
set_location_assignment PIN_AG19 -to SRAM_A[4]
set_location_assignment PIN_AH12 -to SRAM_A[5]
set_location_assignment PIN_AG11 -to SRAM_A[6]
set_location_assignment PIN_AD15 -to SRAM_D[13]
set_location_assignment PIN_AF12 -to SRAM_D[8]
set_location_assignment PIN_AD13 -to SRAM_D[9]
set_location_assignment PIN_AF13 -to SRAM_D[10]
set_location_assignment PIN_AE14 -to SRAM_D[11]
set_location_assignment PIN_AF14 -to SRAM_D[12]
set_location_assignment PIN_AE15 -to SRAM_D[14]
set_location_assignment PIN_AH16 -to SRAM_D[2]
set_location_assignment PIN_AG16 -to SRAM_D[3]
set_location_assignment PIN_AH15 -to SRAM_D[4]
set_location_assignment PIN_AG15 -to SRAM_D[5]
set_location_assignment PIN_AH17 -to SRAM_D[1]
set_location_assignment PIN_AG18 -to SRAM_D[0]
set_location_assignment PIN_AF19 -to SRAM_A[17]
set_location_assignment PIN_AG14 -to SRAM_D[6]
set_location_assignment PIN_AH13 -to SRAM_D[7]
set_instance_assignment -name IO_STANDARD "1.8 V" -to SRAM_CSn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SRAM_LBn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SRAM_UBn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SRAM_WEn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SRAM_OEn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SRAM_D -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SRAM_A -entity c10gx_pinout

#[MII]
set_location_assignment PIN_H2 -to PHY_REF
set_location_assignment PIN_M1 -to PHY_RSTn
set_instance_assignment -name IO_STANDARD "1.8 V" -to PHY_REF
set_instance_assignment -name IO_STANDARD "1.8 V" -to PHY_RSTn
set_location_assignment PIN_H1 -to MII_TXD[2]
set_location_assignment PIN_J2 -to MII_TXD[3]
set_location_assignment PIN_K1 -to MII_TXD[1]
set_location_assignment PIN_K2 -to MII_TXD[0]
set_location_assignment PIN_L2 -to MII_TX_CLK
set_location_assignment PIN_L1 -to MII_TX_EN
set_location_assignment PIN_N1 -to MII_RX_CLK
set_location_assignment PIN_T2 -to MII_RX_ER
set_location_assignment PIN_N2 -to MII_OEn
set_location_assignment PIN_R2 -to MII_RXD[0]
set_location_assignment PIN_T1 -to MII_RXD[1]
set_location_assignment PIN_P2 -to MII_RXD[2]
set_location_assignment PIN_R1 -to MII_RXD[3]
set_location_assignment PIN_W2 -to MII_RX_DV
set_instance_assignment -name IO_STANDARD "1.8 V" -to MII_RX_DV
set_instance_assignment -name IO_STANDARD "1.8 V" -to MII_RXD
set_instance_assignment -name IO_STANDARD "1.8 V" -to MII_RX_ER
set_instance_assignment -name IO_STANDARD "1.8 V" -to MII_RX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to MII_TX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to MII_TX_EN
set_instance_assignment -name IO_STANDARD "1.8 V" -to MII_TXD
set_instance_assignment -name IO_STANDARD "1.8 V" -to MII_OEn -entity c10gx_pinout
set_location_assignment PIN_J19 -to MII_COL

#[HYPER-RAM]
set_location_assignment PIN_AC1 -to HBUS_CK
set_instance_assignment -name IO_STANDARD LVDS -to HBUS_CK -entity c10gx_pinout
set_location_assignment PIN_AC2 -to "HBUS_CK(n)"
set_location_assignment PIN_AE1 -to HBUS_D[5]
set_location_assignment PIN_Y2 -to HBUS_RSTn
set_location_assignment PIN_AA1 -to HBUS_D[2]
set_location_assignment PIN_AA2 -to HBUS_D[3]
set_location_assignment PIN_AB1 -to HBUS_CSn
set_location_assignment PIN_AD2 -to HBUS_RWDS
set_location_assignment PIN_AE2 -to HBUS_D[0]
set_location_assignment PIN_Y1 -to HBUS_D[4]
set_location_assignment PIN_AF2 -to HBUS_D[1]
set_location_assignment PIN_AF1 -to HBUS_D[6]
set_location_assignment PIN_AG1 -to HBUS_D[7]
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_RWDS -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_RSTn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_D[7] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_D[6] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_D[5] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_D[4] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_D[3] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_D[2] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_D[1] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_D[0] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_D -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to HBUS_CSn -entity c10gx_pinout

#[3.0V I/O]
set_location_assignment PIN_A24 -to OSC_50m
set_instance_assignment -name IO_STANDARD "1.8 V" -to OSC_50m -entity c10gx_pinout
set_location_assignment PIN_G1 -to SD_CSn
set_location_assignment PIN_V1 -to SD_MOSI
set_location_assignment PIN_V2 -to SD_SCK
set_location_assignment PIN_U1 -to SD_MISO
set_location_assignment PIN_AH2 -to USER_SW
set_instance_assignment -name IO_STANDARD "1.8 V" -to USER_SW -entity c10gx_pinout
set_location_assignment PIN_U3 -to MII_CRS
set_instance_assignment -name IO_STANDARD "1.8 V" -to MII_CRS -entity c10gx_pinout
set_location_assignment PIN_F18 -to PORT_RS1[1]
set_location_assignment PIN_H16 -to PORT_RS1[2]
set_location_assignment PIN_J17 -to PORT_RS0[2]
set_location_assignment PIN_K17 -to PORT_RXLOS[2]
set_location_assignment PIN_H17 -to PORT_PRSNTn[2]
set_location_assignment PIN_J18 -to PORT_SCL[2]
set_location_assignment PIN_H18 -to PORT_SDA[2]
set_location_assignment PIN_G18 -to PORT_TXDIS[2]
set_location_assignment PIN_F17 -to PORT_RXLOS[1]
set_location_assignment PIN_E16 -to PORT_RS0[1]
set_location_assignment PIN_E17 -to PORT_PRSNTn[1]
set_location_assignment PIN_C16 -to PORT_SCL[1]
set_location_assignment PIN_D17 -to PORT_SDA[1]
set_location_assignment PIN_C17 -to PORT_TXDIS[1]
set_location_assignment PIN_K19 -to PORT_RSTn
set_location_assignment PIN_K22 -to PORT_SCL[3]
set_location_assignment PIN_K21 -to PORT_SDA[3]
set_location_assignment PIN_C23 -to PORT_PRSNTn[3]
set_location_assignment PIN_E23 -to PORT_TXDIS[3]
set_location_assignment PIN_D23 -to PORT_MSELn[3]
set_location_assignment PIN_H23 -to PORT_PRSNTn[4]
set_location_assignment PIN_K23 -to PORT_TXDIS[4]
set_location_assignment PIN_J23 -to PORT_MSELn[4]
set_location_assignment PIN_F22 -to PORT_MSELn[5]
set_location_assignment PIN_F23 -to PORT_PRSNTn[5]
set_location_assignment PIN_G23 -to PORT_TXDIS[5]
set_location_assignment PIN_K20 -to PORT_INTn
set_location_assignment PIN_A26 -to UART_TXD
set_location_assignment PIN_D22 -to UART_RXD
set_location_assignment PIN_E22 -to FPGA_RSTn
set_location_assignment PIN_C22 -to FPGA_ACT
set_location_assignment PIN_E21 -to LB_CSn
set_location_assignment PIN_F21 -to LB_AD[7]
set_location_assignment PIN_G21 -to LB_AD[6]
set_location_assignment PIN_D20 -to LB_AD[5]
set_location_assignment PIN_E20 -to LB_AD[4]
set_location_assignment PIN_D19 -to LB_AD[3]
set_location_assignment PIN_E19 -to LB_AD[2]
set_location_assignment PIN_C18 -to LB_AD[1]
set_location_assignment PIN_D18 -to LB_AD[0]
set_location_assignment PIN_G20 -to LB_RDn
set_location_assignment PIN_F19 -to LB_WRn
set_location_assignment PIN_G19 -to LB_ALEn
set_location_assignment PIN_H20 -to SMI_MDC
set_location_assignment PIN_J20 -to SMI_MDIO
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to SMI_MDC -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to SMI_MDIO -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to MII_COL -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_WRn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_RDn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_CSn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_ALEn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_AD[7] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_AD[6] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_AD[5] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_AD[4] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_AD[3] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_AD[2] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_AD[1] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_AD[0] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to LB_AD -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_INTn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_MSELn[3] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_MSELn[4] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_MSELn[5] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_MSELn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_PRSNTn[1] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_PRSNTn[2] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_PRSNTn[3] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_PRSNTn[4] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_PRSNTn[5] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_PRSNTn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_RS0[1] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_RS0[2] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_RS0 -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_RS1[1] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_RS1[2] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_RS1 -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_RSTn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_RXLOS[1] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_RXLOS[2] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_SCL[1] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_SCL[2] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_SCL[3] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_SCL -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_SDA[1] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_SDA[2] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_SDA[3] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_SDA -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_TXDIS[1] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_TXDIS[2] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_TXDIS[3] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_TXDIS[4] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_TXDIS[5] -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PORT_TXDIS -entity c10gx_pinout
set_location_assignment PIN_H22 -to PWR_SCL
set_location_assignment PIN_J22 -to PWR_SDA
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PWR_SCL -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to PWR_SDA -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SD_CSn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SD_MISO -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SD_MOSI -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to SD_SCK -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to UART_RXD -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "1.8 V" -to UART_TXD -entity c10gx_pinout
set_location_assignment PIN_B8 -to USER_LED[0]
set_location_assignment PIN_A8 -to USER_LED[1]
set_location_assignment PIN_B9 -to USER_LED[2]
set_location_assignment PIN_A9 -to USER_LED[3]
set_location_assignment PIN_B10 -to USER_LED[4]
set_location_assignment PIN_B11 -to USER_LED[5]
set_location_assignment PIN_A11 -to USER_LED[6]
set_location_assignment PIN_A12 -to USER_LED[7]
set_location_assignment PIN_A13 -to USER_LED[8]
set_location_assignment PIN_B13 -to USER_LED[9]
set_location_assignment PIN_H21 -to FAULTn
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to FAULTn -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to FPGA_ACT -entity c10gx_pinout
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to FPGA_RSTn -entity c10gx_pinout
set_location_assignment PIN_AH3 -to LA_DAT[0]
set_location_assignment PIN_AG3 -to LA_DAT[1]
set_location_assignment PIN_AF3 -to LA_DAT[2]
set_location_assignment PIN_AE4 -to LA_DAT[3]
set_location_assignment PIN_AD4 -to LA_DAT[4]
set_location_assignment PIN_AD3 -to LA_DAT[5]
set_location_assignment PIN_AC3 -to LA_DAT[6]
set_location_assignment PIN_AC5 -to LA_DAT[7]
set_location_assignment PIN_AB4 -to LA_DAT[8]
set_location_assignment PIN_AB3 -to LA_DAT[9]
set_location_assignment PIN_AA4 -to LA_DAT[10]
set_location_assignment PIN_AA3 -to LA_DAT[11]
set_location_assignment PIN_Y4 -to LA_DAT[12]
set_location_assignment PIN_AF6 -to LA_CLK
set_instance_assignment -name IO_STANDARD LVDS -to LA_CLK -entity c10gx_pinout
set_location_assignment PIN_AE6 -to "LA_CLK(n)"
set_location_assignment PIN_Y5 -to LA_DAT[13]
set_location_assignment PIN_W5 -to LA_DAT[14]
set_location_assignment PIN_W4 -to LA_DAT[15]
set_location_assignment PIN_W3 -to LA_DAT[16]
set_location_assignment PIN_V3 -to LA_DAT[17]
set_location_assignment PIN_V5 -to LA_DAT[18]
set_location_assignment PIN_U4 -to LA_DAT[19]
set_location_assignment PIN_U5 -to LA_DAT[20]
set_location_assignment PIN_T3 -to LA_DAT[21]
set_location_assignment PIN_T4 -to LA_DAT[22]
set_location_assignment PIN_R4 -to LA_DAT[23]
set_location_assignment PIN_R5 -to LA_DAT[24]
set_location_assignment PIN_P3 -to LA_DAT[25]
set_location_assignment PIN_P4 -to LA_DAT[26]
set_location_assignment PIN_N3 -to LA_DAT[27]
set_location_assignment PIN_M3 -to LA_DAT[28]
set_location_assignment PIN_M4 -to LA_DAT[29]
set_location_assignment PIN_L4 -to LA_DAT[30]
set_location_assignment PIN_K4 -to LA_DAT[31]
set_location_assignment PIN_AC6 -to LA_QUAL


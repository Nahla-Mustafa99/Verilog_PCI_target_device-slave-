# Verilog_PCI_target_device-slave-
In this project, it is required to implement a PCI target device (slave) in Verilog. The project 
should achieve the following goals:
1. When the PCI target device receives the command and recognize its address, the following should be done:
- The DEVSEL should be configured properly (asserted low at certain time).
- The TRDY should be configured properly (asserted low at certain time).
2. If the received command in PCI target device is a read operation:
- The target device should start sending out a frame upon having FRAME signal asserted to low.
- The target device should stop sending out a frame upon having FRAME signal asserted to high.
3. If the received command in PCI target device is a write operation:
- The target device should start saving the received data in an internal storage with respect to byte enable (BE) bits upon having FRAME signal asserted to low.
- The target device should stop saving the received data in internal storage upon having FRAME signal asserted to high.
4. A testbench should be created to simulate different read/write scenarios (act as a simplified PCI master device).
5. Testbench should verify write command by doing the following:
- Sending a write command.
- Followed by a read command with same address used for the previous write command.
6. It is assumed that the PCI master device granted the PCI bus to initiate the transactionwith the target. So, no need to implement the PCI arbiter.
7. The source code of the project should be synthesizable.
8. It is allowed to use non-synthesizable code in testbench.

# APB TIMER UVM Verification

This directory contains the UVM testbench for `apb_timer_wrapper` via APB interface.

## Directory tree

```text
uvm/
|-- agent/
|   |-- apb_agent.sv
|   |-- apb_item.sv
|   |-- apb_sequencer.sv
|   |-- timer_agent.sv
|   |-- timer_item.sv
|-- driver/
|   |-- apb_driver.sv
|   |-- timer_driver.sv
|-- env/
|   `-- apb_timer_env.sv
|-- monitor/
|   |-- apb_monitor.sv
|   |-- timer_monitor.sv
|-- scoreboard/
|   `-- apb_timer_scoreboard.sv
|-- sequences/
|   |-- apb_timer_base_seq.sv
|   `-- apb_timer_smoke_seq.sv
|-- tb/
|   |-- apb_if.sv
|   |-- timer_if.sv
|   |-- apb_timer_tb_top.sv
|   `-- apb_timer_uvm_pkg.sv
|-- tests/
|   |-- apb_timer_base_test.sv
|   `-- apb_timer_smoke_test.sv
```

## Questa example

Chay tu thu muc `apb-timer-core`:

```sh
make compile
make run
```

Chay test rieng:

```sh
make run UVM_TEST=apb_timer_smoke_test
```

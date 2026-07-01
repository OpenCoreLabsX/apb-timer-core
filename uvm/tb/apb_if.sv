`ifndef APB_IF_SV
`define APB_IF_SV

interface apb_if #(parameter int DATA_WIDTH = 32, parameter int ADDR_WIDTH = 8) (input logic pclk, input logic presetn);
  logic [ADDR_WIDTH-1:0] paddr;
  logic                  psel;
  logic                  penable;
  logic                  pwrite;
  logic [DATA_WIDTH-1:0] pwdata;
  logic [(DATA_WIDTH/8)-1:0] pstrb;
  logic [DATA_WIDTH-1:0] prdata;
  logic                  pready;
  logic                  pslverr;

  modport master (
    output paddr, psel, penable, pwrite, pwdata, pstrb,
    input  prdata, pready, pslverr
  );

  modport slave (
    input  paddr, psel, penable, pwrite, pwdata, pstrb,
    output prdata, pready, pslverr
  );
endinterface

`endif

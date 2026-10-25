module dual_port_ram #(
    parameter DATA_WIDTH = 4,
    parameter ADDR_WIDTH = 4
) (
    input logic                  wclk,
    input logic                  winc,
    input logic                  wfull,
    input logic [ADDR_WIDTH-1:0] waddr,
    input logic [DATA_WIDTH-1:0] wdata,

    input  logic                  rclk,
    input  logic                  rinc,
    input  logic                  rempty,
    input  logic [ADDR_WIDTH-1:0] raddr,
    output logic [DATA_WIDTH-1:0] rdata
);

  logic [DATA_WIDTH-1:0] mem[0:(1<<ADDR_WIDTH)-1];

  always_ff @(posedge wclk) begin
    if (winc && !wfull) begin
      mem[waddr] <= wdata;
    end
  end

  always_ff @(posedge rclk) begin
    if (rinc && !rempty) begin
      rdata <= mem[raddr];
    end
  end

endmodule

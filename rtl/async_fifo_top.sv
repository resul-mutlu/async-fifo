module async_fifo_top #(
    parameter DATA_WIDTH = 4,
    parameter ADDR_WIDTH = 4
) (

    input  logic                  wclk,
    input  logic                  wrst_n,
    input  logic                  winc,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic                  wfull,

    input  logic                  rclk,
    input  logic                  rrst_n,
    input  logic                  rinc,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  rempty
);

  logic [ADDR_WIDTH-1:0] waddr, raddr;
  logic [ADDR_WIDTH:0] wptr_gray, rptr_gray;
  logic [ADDR_WIDTH:0] wq2_rptr_gray;
  logic [ADDR_WIDTH:0] rq2_wptr_gray;


  dual_port_ram #(DATA_WIDTH, ADDR_WIDTH) ram_inst (
      .wclk (wclk),
      .winc (winc),
      .wfull(wfull),
      .waddr(waddr),
      .wdata(wdata),

      .rclk  (rclk),
      .rinc  (rinc),
      .rempty(rempty),
      .raddr (raddr),
      .rdata (rdata)
  );

  sync_2ff #(ADDR_WIDTH) r2w_sync (
      .clk  (wclk),
      .rst_n(wrst_n),
      .d_in (rptr_gray),
      .q_out(wq2_rptr_gray)
  );

  sync_2ff #(ADDR_WIDTH) w2r_sync (
      .clk  (rclk),
      .rst_n(rrst_n),
      .d_in (wptr_gray),
      .q_out(rq2_wptr_gray)
  );

  wptr_full #(ADDR_WIDTH) wptr_inst (
      .wclk         (wclk),
      .wrst_n       (wrst_n),
      .winc         (winc),
      .wq2_rptr_gray(wq2_rptr_gray),
      .wfull        (wfull),
      .waddr        (waddr),
      .wptr_gray    (wptr_gray)
  );

  rptr_empty #(ADDR_WIDTH) rptr_inst (
      .rclk         (rclk),
      .rrst_n       (rrst_n),
      .rinc         (rinc),
      .rq2_wptr_gray(rq2_wptr_gray),
      .rempty       (rempty),
      .raddr        (raddr),
      .rptr_gray    (rptr_gray)
  );

endmodule

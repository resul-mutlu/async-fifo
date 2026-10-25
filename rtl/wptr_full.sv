module wptr_full #(
    parameter ADDR_WIDTH = 4
) (
    input logic                wclk,
    input logic                wrst_n,
    input logic                winc,
    input logic [ADDR_WIDTH:0] wq2_rptr_gray,

    output logic                  wfull,
    output logic [ADDR_WIDTH-1:0] waddr,
    output logic [  ADDR_WIDTH:0] wptr_gray
);

  logic [ADDR_WIDTH:0] wbin, wbin_next, wgray_next;
  logic wfull_val;

  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      wbin      <= 0;
      wptr_gray <= 0;
      wfull     <= 0;
    end else begin
      wbin      <= wbin_next;
      wptr_gray <= wgray_next;
      wfull     <= wfull_val;
    end
  end

  assign wbin_next = wbin + (winc & ~wfull);

  assign wgray_next = (wbin_next >> 1) ^ wbin_next;

  assign waddr = wbin[ADDR_WIDTH-1:0];

  assign wfull_val = (wgray_next == {~wq2_rptr_gray[ADDR_WIDTH:ADDR_WIDTH-1],
                                        wq2_rptr_gray[ADDR_WIDTH-2:0]});

endmodule

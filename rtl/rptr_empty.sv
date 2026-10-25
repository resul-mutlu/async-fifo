module rptr_empty #(
    parameter ADDR_WIDTH = 4
) (
    input logic                rclk,
    input logic                rrst_n,
    input logic                rinc,
    input logic [ADDR_WIDTH:0] rq2_wptr_gray,

    output logic                  rempty,
    output logic [ADDR_WIDTH-1:0] raddr,
    output logic [  ADDR_WIDTH:0] rptr_gray
);

  logic [ADDR_WIDTH:0] rbin, rbin_next, rgray_next;
  logic rempty_val;

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      rbin      <= 0;
      rptr_gray <= 0;
      rempty    <= 1'b1;
    end else begin
      rbin      <= rbin_next;
      rptr_gray <= rgray_next;
      rempty    <= rempty_val;
    end
  end

  assign rbin_next = rbin + (rinc & ~rempty);

  assign rgray_next = (rbin_next >> 1) ^ rbin_next;

  assign raddr = rbin[ADDR_WIDTH-1:0];

  assign rempty_val = (rgray_next == rq2_wptr_gray);

endmodule

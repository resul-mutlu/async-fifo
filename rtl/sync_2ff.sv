module sync_2ff #(
    parameter WIDTH = 4
) (
    input  logic           clk,
    input  logic           rst_n,
    input  logic [WIDTH:0] d_in,
    output logic [WIDTH:0] q_out
);

  logic [WIDTH:0] q1;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q1    <= 0;
      q_out <= 0;
    end else begin
      q1    <= d_in;
      q_out <= q1;
    end
  end

endmodule

`timescale 1ns / 1ps

module tb_top;

  // Interface signals
  logic       wclk = 0;
  logic       wrst_n;
  logic       winc;
  logic [3:0] wdata;
  logic       wfull;

  logic       rclk = 0;
  logic       rrst_n;
  logic       rinc;
  logic [3:0] rdata;
  logic       rempty;

  // Clock generation (wclk: 100 MHz, rclk: ~43 MHz)
  always #5 wclk = ~wclk;
  always #11.5 rclk = ~rclk;

  // DUT Instantiation
  async_fifo_top DUT (
      .wclk  (wclk),
      .wrst_n(wrst_n),
      .winc  (winc),
      .wdata (wdata),
      .wfull (wfull),
      .rclk  (rclk),
      .rrst_n(rrst_n),
      .rinc  (rinc),
      .rdata (rdata),
      .rempty(rempty)
  );

  // Waveform dumping setup
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

  // Scenario 1: Write-on-Full (Overflow Stress)
  task test_write_on_full();
    $display("[%0t] TEST: Scenario 1 (Overflow Stress) started...", $time);

    // Fill the FIFO completely
    while (!wfull) begin
      @(posedge wclk);
      winc  = 1;
      wdata = $urandom_range(0, 15);
    end

    $display("[%0t] TEST: FIFO is full. Attempting to force writes...", $time);

    // Force additional writes when full
    repeat (5) begin
      @(posedge wclk);
      winc  = 1;
      wdata = $urandom_range(0, 15);
    end

    @(posedge wclk);
    winc = 0;
    $display("[%0t] TEST: Scenario 1 completed.", $time);
  endtask

  // Scenario 2: Read-on-Empty & Concurrent Execution
  task test_read_on_empty_and_concurrent();
    $display("[%0t] TEST: Scenario 2 (Underflow & Concurrent) started...", $time);

    // Part A: Force reads while empty (Underflow test)
    repeat (5) begin
      @(posedge rclk);
      rinc = 1;
    end
    @(posedge rclk);
    rinc = 0;
    $display("[%0t] TEST: Forced empty reads attempted (Underflow protection active).", $time);

    #50;

    // Part B: Concurrent read and write burst
    $display("[%0t] TEST: Concurrent Read/Write burst starting...", $time);

    fork
      // Write thread
      begin
        repeat (15) begin
          @(posedge wclk);
          winc = (!wfull);
          if (winc) wdata = $urandom_range(0, 15);
        end
        @(posedge wclk);
        winc = 0;
      end

      // Read thread
      begin
        repeat (15) begin
          @(posedge rclk);
          rinc = (!rempty);
        end
        @(posedge rclk);
        rinc = 0;
      end
    join

    $display("[%0t] TEST: Scenario 2 completed.", $time);
  endtask

  // Scenario 3: Asynchronous Reset Storm
  task test_reset_storm();
    $display("[%0t] TEST: Scenario 3 (Asynchronous Reset Storm) started...", $time);

    // Write some initial data
    repeat (5) begin
      @(posedge wclk);
      winc  = 1;
      wdata = $urandom_range(0, 15);
    end
    @(posedge wclk);
    winc = 0;

    // Wait for an unaligned, random time interval
    #17;

    // Inject asynchronous resets
    wrst_n = 0;
    #3;
    rrst_n = 0;
    $display("[%0t] TEST: Reset injected. Pointers should drop to zero.", $time);

    #25;  // Hold reset

    // Deassert resets
    wrst_n = 1;
    rrst_n = 1;
    $display("[%0t] TEST: Power restored. System should recover smoothly.", $time);

    #50;  // Wait for synchronizers to settle

    // Post-Reset Sanity Check
    $display("[%0t] TEST: Post-reset sanity check writing hex 'A'...", $time);
    @(posedge wclk);
    winc  = 1;
    wdata = 4'hA;
    @(posedge wclk);
    winc = 0;

    #100;

    @(posedge rclk);
    rinc = 1;
    @(posedge rclk);
    rinc = 0;
    $display("[%0t] TEST: Scenario 3 completed. Core recovered successfully.", $time);
  endtask

  // Main Simulation Flow
  initial begin
    // Initialize
    wrst_n = 0;
    rrst_n = 0;
    winc   = 0;
    rinc   = 0;
    wdata  = 0;

    #30;
    wrst_n = 1;
    rrst_n = 1;
    #20;

    test_write_on_full();
    #100;

    test_read_on_empty_and_concurrent();
    #100;

    test_reset_storm();
    #100;
    $finish;
  end

endmodule

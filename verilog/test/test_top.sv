`timescale 1ns/100ps
module top;

localparam CYCLE=5000000;
localparam DW = 16;

logic clk,clk_div,reset_n;
logic [2:0] os_sel;
wire [DW-1:0] data_in;
wire [DW-1:0] data_out;

cic_filter #(16) DUT(
    .clk        ( clk      ),
    .clk_div    ( clk_div  ),
    .reset_n    ( reset_n  ),
    .os_sel     ( os_sel   ),
    .data_in    ( data_in  ),
    .data_out   ( data_out )
);


initial
begin
  clk = 0;
  forever #(CYCLE/2) clk = ~clk;
end

initial begin
  reset_n = 0;
  os_sel = 3'b001;
  #10000 reset_n = 1;
end

`define INPUT_FILE "cic_testdata.csv"
`define NULL 0

integer data_file;
integer scan_file;
logic signed [DW-1:0] captured_data;
integer idx;

initial
begin
  data_file = $fopen(`INPUT_FILE, "r");
  if (data_file == `NULL) begin
    $display("Input data_file handle was NULL");
    $finish;
  end

  idx = 0;
  while(1) begin
    @(posedge clk);
    scan_file = $fscanf(data_file, "%d,", captured_data); 
    $display("id[%d]:%d\n",idx,captured_data); 
    if ($feof(data_file)) begin
      $finish;
    end
    idx++;
  end
end

endmodule

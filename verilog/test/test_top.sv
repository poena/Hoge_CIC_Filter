`timescale 1ns/100ps
module top;

localparam CYCLE=5000000;
localparam DW = 16;

logic clk,clk_div,reset_n,dv;
logic [2:0] os_sel;
logic [DW-1:0] data_in;
wire [DW-1:0] data_out;

logic [31:0] counter;

cic_filter #(16) DUT(
    .clk        ( clk      ),
    .clk_div    ( clk_div  ),
    .reset_n    ( reset_n  ),
    .os_sel     ( os_sel   ),
    .data_in    ( data_in  ),
    .data_out   ( data_out )
);

`define INPUT_FILE "cic_testdata.csv"
`define INTE_OUT_FILE "cic_int_out.csv"
`define NULL 0

integer data_file;
integer scan_file;
integer inte_file;
logic signed [DW-1:0] captured_data;
integer idx;

//initial begin
//  $vpdplusfile("vpd");
//  $vpdpluson();
//end
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

always_ff @(posedge clk or negedge reset_n)
begin
    if (!reset_n) begin
        counter <= '0;
        dv <= 1'b0;
    end else if (os_sel == '0) begin
        counter <= '0;
        dv <= 1'b0;
    end else begin
        counter <= (counter < 2**os_sel-1) ? counter + 1 : '0;
        dv <= (counter == 2**os_sel-1);
    end
end

assign clk_div = (os_sel == 3'b000)?clk:dv;

initial
begin
  data_in = '0;
  data_file = $fopen(`INPUT_FILE, "r");
  if (data_file == `NULL) begin
    $display("Input data_file handle was NULL");
    $finish;
  end

  wait(reset_n);
  repeat(100) @(posedge clk);

  idx = 0;
  while(1) begin
    @(posedge clk);
    scan_file = $fscanf(data_file, "%d,", captured_data); 
    //$display("id[%d]:%d @%t\n",idx,captured_data,$time); 
    data_in = captured_data;
    if ($feof(data_file)) begin
      $fclose(data_file);
      $finish;
    end
    idx++;
  end
end

string inte_data, inte_flag;
integer flag_v;
integer str_len = 1;

initial
begin
  inte_file = $fopen(`INTE_OUT_FILE, "r");
  if (inte_file == `NULL) begin
    $display("Input `INTE_OUT_FILE handle was NULL");
    $finish;
  end

  if(!$fgets(inte_data,inte_file))begin
    $display("Input `INTE_OUT_FILE read data error.");
    $finish;
  end
  //$display(inte_data);
  if(!$fgets(inte_flag,inte_file))begin
    $display("Input `INTE_OUT_FILE read flag error.");
    $finish;
  end
  //$display(inte_flag);

  $fclose(inte_file);

  idx = 0;
  $display("string len is %d",inte_flag.len());
  while(str_len > 0) begin
    @(posedge clk);
    str_len = $sscanf(inte_flag.substr(idx*2), "%d,", flag_v);
    if(str_len > 0) begin
      $display("id[%d]:%d,\n",idx,flag_v, str_len); 
    end
    idx++;
  end

end

endmodule

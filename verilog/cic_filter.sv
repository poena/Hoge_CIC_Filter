module cic_filter
#(parameter DW = 16)
(
    input                   clk,
    input                   clk_div,
    input                   reset_n,
    input          [2:0]    os_sel,
    input          [DW-1:0] data_in,
    output         [DW-1:0] data_out 
);

//localparam MAX_OS = 64;
localparam OW     =  6;

wire        [DW-1   :0] int_in;
wire        [DW+OW  :0] int_out;
wire        [1      :0] flag_t;
wire        [DW+OW  :0] comb_in;
wire        [DW-1   :0] comb_out;

assign int_in = data_in;

integrator #(DW, DW+OW+1) int_inst(
    .clk        ( clk       ),
    .clk_div    ( clk_div   ),
    .reset_n    ( reset_n   ),
    .os_sel     ( os_sel    ),
    .data_in    ( int_in    ),
    .flag_t     ( flag_t    ),
    .data_out   ( int_out   )
);

assign comb_in = int_out;

comb #(DW+OW+1, DW, 1) comb_inst(
    .clk_div    ( clk_div   ),
    .reset_n    ( reset_n   ), 
    .os_sel     ( os_sel    ),
    .flag_in    ( flag_t    ),
    .data_in    ( comb_in   ), 
    .data_out   ( comb_out  )
);

assign data_out = comb_out;

endmodule

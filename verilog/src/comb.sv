module comb
#(parameter IDW = 23, ODW = 16, DM = 1)
(
    input                 clk_div  ,
    input                 reset_n  ,
    input       [    2:0] os_sel   ,
    input       [IDW-1:0] data_in  ,
    input       [    1:0] flag_in  ,
    output  reg [ODW-1:0] data_out 
);

localparam TW = IDW-6; //TW must great than or equal to ODW

reg        [IDW-1:0] data_reg;
reg        [    1:0] flag_reg;
reg        [IDW  :0] data_sub;
reg        [IDW+1:0] trunc_value;
wire                 trunc_fix;
wire                 trunc_sign;
wire       [IDW+1:0] data_sub_fix;
reg                  sub_overflow_up;
reg                  sub_overflow_dn;

///////////////////////////////////////////////////////////
assign trunc_fix = (flag_in != flag_reg);
assign trunc_sign = flag_in[1];
//assign trunc_value = {trunc_fix&trunc_sign,trunc_fix,{(IDW-1){1'b0}}};

assign data_sub     = {data_in[IDW-1],data_in} - {data_reg[IDW-1],data_reg};
assign data_sub_fix = {data_sub[IDW],data_sub} + trunc_value;

always_comb
begin
  case (os_sel)
    3'b001 : begin
        sub_overflow_up = ( (|data_sub_fix[IDW:ODW+0]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+0]))&( data_sub_fix[IDW+1]);
        trunc_value     = {{(7){trunc_fix&trunc_sign}},trunc_fix,{(TW){1'b0}}};
    end
    3'b010 : begin
        sub_overflow_up = ( (|data_sub_fix[IDW:ODW+1]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+1]))&( data_sub_fix[IDW+1]);
        trunc_value     = {{(6){trunc_fix&trunc_sign}},trunc_fix,{(TW+1){1'b0}}};
    end
    3'b011 : begin
        sub_overflow_up = ( (|data_sub_fix[IDW:ODW+2]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+2]))&( data_sub_fix[IDW+1]);
        trunc_value     = {{(5){trunc_fix&trunc_sign}},trunc_fix,{(TW+2){1'b0}}};
    end
    3'b100 : begin
        sub_overflow_up = ( (|data_sub_fix[IDW:ODW+3]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+3]))&( data_sub_fix[IDW+1]);
        trunc_value     = {{(4){trunc_fix&trunc_sign}},trunc_fix,{(TW+3){1'b0}}};
    end
    3'b101 : begin
        sub_overflow_up = ( (|data_sub_fix[IDW:ODW+4]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+4]))&( data_sub_fix[IDW+1]);
        trunc_value     = {{(3){trunc_fix&trunc_sign}},trunc_fix,{(TW+4){1'b0}}};
    end
    3'b110 : begin
        sub_overflow_up = ( (|data_sub_fix[IDW:ODW+5]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+5]))&( data_sub_fix[IDW+1]);
        trunc_value     = {{(2){trunc_fix&trunc_sign}},trunc_fix,{(TW+5){1'b0}}};
    end
    default: begin
        sub_overflow_up = 1'b0;
        sub_overflow_dn = 1'b0;
        trunc_value     = '0;
    end
  endcase
end

//integer i;
always_ff @(posedge clk_div or negedge reset_n)
begin
    if (!reset_n) begin
        data_reg <= '0;
        flag_reg <= '0;
    end else if(os_sel == 3'b000) begin
        data_reg <= '0;
        flag_reg <= '0;
    end else begin
        data_reg <= data_in;
        flag_reg <= flag_in;
    end
end

always_ff @(posedge clk_div or negedge reset_n)
begin
    if (!reset_n)
      data_out <= '0;
    else if(sub_overflow_up)
      data_out[ODW-1:0] <= {1'b0,{(IDW-1){1'b1}}};
    else if(sub_overflow_dn)
      data_out[ODW-1:0] <= {1'b1,{(IDW-1){1'b0}}};
    else
      case(os_sel)
        3'b001 : data_out[ODW-1:0] <= {data_sub_fix[IDW+1],data_sub_fix[ODW-1:1]};
        3'b010 : data_out[ODW-1:0] <= {data_sub_fix[IDW+1],data_sub_fix[ODW+0:2]};
        3'b011 : data_out[ODW-1:0] <= {data_sub_fix[IDW+1],data_sub_fix[ODW+1:3]};
        3'b100 : data_out[ODW-1:0] <= {data_sub_fix[IDW+1],data_sub_fix[ODW+2:4]};
        3'b101 : data_out[ODW-1:0] <= {data_sub_fix[IDW+1],data_sub_fix[ODW+3:5]};
        3'b110 : data_out[ODW-1:0] <= {data_sub_fix[IDW+1],data_sub_fix[ODW+4:6]};
        default: data_out[ODW-1:0] <= {data_sub_fix[IDW+1],data_sub_fix[ODW-2:0]};
      endcase
end

endmodule

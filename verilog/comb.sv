module comb
#(parameter IDW = 23, ODW = 16, DM = 1)
(
    input             clk      ,
    input             reset_n  ,
    input   [    2:0] os_sel   ,
    input   [IDW-1:0] data_in  ,
    input   [    1:0] flag_in  ,
    output  [ODW-1:0] data_out 
);

reg        [IDW-1:0] data_reg[g];
reg        [    1:0] flag_reg[g];
reg        [IDW  :0] data_sub;
wire       [IDW  :0] trunc_value;
wire                 trunc_fix;
wire                 trunc_sign;
wire       [IDW+1:0] data_sub_fix;
wire                 sub_overflow_up;
wire                 sub_overflow_dn;

///////////////////////////////////////////////////////////
assign trunc_fix = (flag_in != flag_reg[DM-1]);
assign trunc_sign = flag_in[1];
assign trunc_value = {trunc_fix&trunc_sign,trunc_fix,{(IDW-1){1'b0}}};

assign data_sub     = data_in - data_reg[DM-1];
assign data_sub_fix = data_sub + trunc_value;

always_comb
begin
  case (os _sel)
    3'b001 : begin
        sub_overflow_up = (~(|data_sub_fix[IDW:ODW+0]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+0]))&( data_sub_fix[IDW+1]);
    end
    3'b010 : begin
        sub_overflow_up = (~(|data_sub_fix[IDW:ODW+1]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+1]))&( data_sub_fix[IDW+1]);
    end
    3'b011 : begin
        sub_overflow_up = (~(|data_sub_fix[IDW:ODW+2]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+2]))&( data_sub_fix[IDW+1]);
    end
    3'b100 : begin
        sub_overflow_up = (~(|data_sub_fix[IDW:ODW+3]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+3]))&( data_sub_fix[IDW+1]);
    end
    3'b101 : begin
        sub_overflow_up = (~(|data_sub_fix[IDW:ODW+4]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+4]))&( data_sub_fix[IDW+1]);
    end
    3'b110 : begin
        sub_overflow_up = (~(|data_sub_fix[IDW:ODW+5]))&(~data_sub_fix[IDW+1]);
        sub_overflow_dn = (~(&data_sub_fix[IDW:ODW+5]))&( data_sub_fix[IDW+1]);
    end
    default: begin
        sub_overflow_up = 1'b0;
        sub_overflow_dn = 1'b0;
    end
  endcase
end

integer i;
always_ff @(posedge clk iff reset_n == 1 or negedge reset_n)
begin
    if (!reset_n) begin
        for (i=0;i<DM;i++) begin
            data_reg[i] <= '0;
            flag_reg[i] <= '0;
        end
        //data_sub <= '0;
    end else if(os_sel == 3'b000) begin
        for (i=0;i<DM;i++) begin
            data_reg[i] <= '0;
            flag_reg[i] <= '0;
        end
    end else begin
        data_reg[0] <= data_in;
        flag_reg[0] <= flag_in;
        for (i=1;i<DM;i++) begin
            data_reg[i] <= data_reg[i-1];
            flag_reg[i] <= flag_reg[i-1];
        end
        //data_sub <= data_in - data_reg[DM-1];
    end
end

always_ff @(posedge clk iff reset_n == 1 or negedge reset_n)
begin
    if (!reset_n)
      data_out <= '0;
    else if(sub_overflow_up)
      data_out[ODW-1:0] = {1'b0,{(IDW-1){1'b1}}};
    else if(sub_overflow_dn)
      data_out[ODW-1:0] = {1'b1,{(IDW-1){1'b0}}};
    else
      case(os_sel)
        3'b001 : data_out[ODW-1:0] = {data_sub_fix[IDW+1],data_sub_fix[ODW-1:1]};
        3'b010 : data_out[ODW-1:0] = {data_sub_fix[IDW+1],data_sub_fix[ODW+0:2]};
        3'b011 : data_out[ODW-1:0] = {data_sub_fix[IDW+1],data_sub_fix[ODW+1:3]};
        3'b100 : data_out[ODW-1:0] = {data_sub_fix[IDW+1],data_sub_fix[ODW+2:4]};
        3'b101 : data_out[ODW-1:0] = {data_sub_fix[IDW+1],data_sub_fix[ODW+3:5]};
        3'b110 : data_out[ODW-1:0] = {data_sub_fix[IDW+1],data_sub_fix[ODW+4:6]};
        default: data_out[ODW-1:0] = {data_sub_fix[IDW+1],data_sub_fix[ODW-2:0]};;
      endcase
end

endmodule

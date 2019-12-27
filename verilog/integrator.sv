/*
*/
module integrator #(
    parameter IDW = 16, //Input data datawidth
    parameter ODW = 23  //Output data datawidth
) //output bits should be IDW+OSBITS+AW
(
    input                       clk     ,
    input                       reset_n ,
    input             [2    :0] os_sel  ,
    input             [IDW-1:0] data_in ,
    output reg        [1    :0] flag_t  ,
    output            [ODW-1:0] data_out
);

//TW is local valid bits
//TW should be IDW+log2(OS), with sign
localparam TW = ODW-IDW-6; //TW must great than 0

reg  [ODW-1:0] data_reg;
wire [ODW-1:0] data_in_ext;
wire [ODW  :0] data_sum;
reg  [ODW-1:0] data_sum_trunc;
reg            trunc;

assign data_in_ext = {{(ODW-IDW+1){data_in[IDW-1]}},data_in[IDW-2:0]};

assign data_sum = data_reg + data_in_ext;

always_comb
begin
    case (os_sel)
        3'b001 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-IDW-0){data_sum[ODW]}},data_sum[IDW-1:0]}; //2 OS
            trunc = ~((|data_sum[ODW-1:IDW])&(~data_sum[ODW]) ||
                      (&data_sum[ODW-1:IDW])&  data_sum[ODW]  );
        end
        3'b010 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-IDW-1){data_sum[ODW]}},data_sum[IDW+0:0]}; //4 OS
            trunc = ~((|data_sum[ODW-1:IDW+1])&(~data_sum[ODW]) ||
                      (&data_sum[ODW-1:IDW+1])&  data_sum[ODW]  );
        end
        3'b011 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-IDW-2){data_sum[ODW]}},data_sum[IDW+1:0]}; //8 OS
            trunc = ~((|data_sum[ODW-1:IDW+2])&(~data_sum[ODW]) ||
                      (&data_sum[ODW-1:IDW+2])&  data_sum[ODW]  );
        end
        3'b100 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-IDW-3){data_sum[ODW]}},data_sum[IDW+2:0]}; //16 OS
            trunc = ~((|data_sum[ODW-1:IDW+3])&(~data_sum[ODW]) ||
                      (&data_sum[ODW-1:IDW+3])&  data_sum[ODW]  );
        end
        3'b101 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-IDW-4){data_sum[ODW]}},data_sum[IDW+3:0]}; //32 OS
            trunc = ~((|data_sum[ODW-1:IDW+4])&(~data_sum[ODW]) ||
                      (&data_sum[ODW-1:IDW+4])&  data_sum[ODW]  );
        end
        3'b110 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-IDW-5){data_sum[ODW]}},data_sum[IDW+4:0]}; //64 OS
            trunc = ~((|data_sum[ODW-1:IDW+5])&(~data_sum[ODW]) ||
                      (&data_sum[ODW-1:IDW+5])&  data_sum[ODW]  );
        end
        //3'b111 : //INVALID
        default: begin
            data_sum_trunc[ODW-1:0] = {data_sum[ODW-1:0]}; //NO OS
            trunc = 0;
        end
    endcase
end

always_ff @(negedge clk iff reset_n == 1 or negedge reset_n)
begin
    if (!reset_n)
        data_reg <= '0;
    else
        data_reg <= data_sum_trunc;
end

assign data_out = data_reg;

always_ff @(negedge clk iff reset_n == 1 or negedge reset_n)
begin
    if (!reset_n)
        flag_t <= 2'b0;
    else if(trunc) flag_t   <= {data_sum[ODW],~flag_t[0]};
end

endmodule

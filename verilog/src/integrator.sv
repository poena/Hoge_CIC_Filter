/*
*/
module integrator #(
    parameter IDW = 16, //Input data datawidth
    parameter ODW = 23  //Output data datawidth
) //output bits should be IDW+OSBITS+AW
(
    input                       clk     ,
    input                       clk_div ,
    input                       reset_n ,
    input             [2    :0] os_sel  ,
    input             [IDW-1:0] data_in ,
    output reg        [1    :0] flag_t  ,
    output reg        [ODW-1:0] data_out
);

//TW is local valid bits
//TW should be IDW+log2(OS), with sign
localparam TW = ODW-6; //TW must great than or equal to IDW

reg  [ODW-1:0] data_reg;
wire [ODW  :0] data_in_ext;
wire [ODW  :0] data_sum;
reg  [ODW-1:0] data_sum_trunc;
reg            trunc;
reg  [1    :0] flag_reg;
wire [1    :0] flag_comb;

assign data_in_ext = {{(ODW-IDW+2){data_in[IDW-1]}},data_in[IDW-2:0]};

assign data_sum = {data_reg[ODW-1],data_reg} + data_in_ext; // Two bits sign

//assert data_sum overflow

always_comb
begin
    case (os_sel)
        3'b001 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-TW-0){data_sum[ODW]}},data_sum[TW-1:0]}; //2 OS
            trunc = (( |data_sum[ODW-1:TW])&(~data_sum[ODW]) ||
                     (~&data_sum[ODW-1:TW])&  data_sum[ODW]  );
        end
        3'b010 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-TW-1){data_sum[ODW]}},data_sum[TW+0:0]}; //4 OS
            trunc = (( |data_sum[ODW-1:TW+1])&(~data_sum[ODW]) ||
                     (~&data_sum[ODW-1:TW+1])&  data_sum[ODW]  );
        end
        3'b011 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-TW-2){data_sum[ODW]}},data_sum[TW+1:0]}; //8 OS
            trunc = (( |data_sum[ODW-1:TW+2])&(~data_sum[ODW]) ||
                     (~&data_sum[ODW-1:TW+2])&  data_sum[ODW]  );
        end
        3'b100 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-TW-3){data_sum[ODW]}},data_sum[TW+2:0]}; //16 OS
            trunc = (( |data_sum[ODW-1:TW+3])&(~data_sum[ODW]) ||
                     (~&data_sum[ODW-1:TW+3])&  data_sum[ODW]  );
        end
        3'b101 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-TW-4){data_sum[ODW]}},data_sum[TW+3:0]}; //32 OS
            trunc = (( |data_sum[ODW-1:TW+4])&(~data_sum[ODW]) ||
                     (~&data_sum[ODW-1:TW+4])&  data_sum[ODW]  );
        end
        3'b110 : begin
            data_sum_trunc[ODW-1:0] = {{(ODW-TW-5){data_sum[ODW]}},data_sum[TW+4:0]}; //64 OS
            trunc = (( |data_sum[ODW-1:TW+5])&(~data_sum[ODW]) ||
                     (~&data_sum[ODW-1:TW+5])&  data_sum[ODW]  );
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

always_ff @(negedge clk iff reset_n == 1 or negedge reset_n)
begin
    if (!reset_n)
        flag_reg <= 2'b0;
    else if(trunc) flag_reg   <= {data_sum[ODW],~flag_reg[0]};
end

///////////////////////////////////////////////////////
// clk_div domain
assign flag_comb = trunc?{data_sum[ODW],~flag_reg[0]}:flag_reg;

always_ff @(posedge clk_div iff reset_n == 1 or negedge reset_n)
begin
    if (!reset_n) begin
        data_out <= '0;
        flag_t   <= '0;
    end else begin
        data_out <= data_sum_trunc;
        flag_t   <= flag_comb;
    end
end

endmodule

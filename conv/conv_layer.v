
module conv_layer (
    input clk,
    input rst_n,
    input conv_en,
    input [10*8-1:0] image,
    input [7*8-1:0] weight,
    output [4*32-1:0] psum
);

wire signed [7:0] i [0:10-1];
wire signed [7:0] w [0:7-1];
reg [4*32-1:0] value_temp;

genvar m;

generate
    for(m=0;m<10;m=m+1) begin
        assign i[m]=image[(m+1)*8-1:m*8];
    end
endgenerate

genvar n;

generate
    for(n=0;n<7;n=n+1) begin
        assign w[n]=weight[(n+1)*8-1:n*8];
    end
endgenerate

//完成1乘7加 并行4次（一行）
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
        value_temp[(0+1)*32-1:0*32]<=32'b0;
        value_temp[(1+1)*32-1:1*32]<=32'b0;
        value_temp[(2+1)*32-1:2*32]<=32'b0;
        value_temp[(3+1)*32-1:3*32]<=32'b0;
    end
    else if(conv_en) begin
        value_temp[(0+1)*32-1:0*32]<= i[0]*w[0]+i[0+1]*w[1]+i[0+2]*w[2]+i[0+3]*w[3]+i[0+4]*w[4]+i[0+5]*w[5]+i[0+6]*w[6];
        value_temp[(1+1)*32-1:1*32]<= i[1]*w[0]+i[1+1]*w[1]+i[1+2]*w[2]+i[1+3]*w[3]+i[1+4]*w[4]+i[1+5]*w[5]+i[1+6]*w[6];
        value_temp[(2+1)*32-1:2*32]<= i[2]*w[0]+i[2+1]*w[1]+i[2+2]*w[2]+i[2+3]*w[3]+i[2+4]*w[4]+i[2+5]*w[5]+i[2+6]*w[6];
        value_temp[(3+1)*32-1:3*32]<= i[3]*w[0]+i[3+1]*w[1]+i[3+2]*w[2]+i[3+3]*w[3]+i[3+4]*w[4]+i[3+5]*w[5]+i[3+6]*w[6];
    end
    else begin 
        value_temp[(0+1)*32-1:0*32]<=32'b0;
        value_temp[(1+1)*32-1:1*32]<=32'b0;
        value_temp[(2+1)*32-1:2*32]<=32'b0;
        value_temp[(3+1)*32-1:3*32]<=32'b0;
    end
end

assign psum=value_temp;

endmodule
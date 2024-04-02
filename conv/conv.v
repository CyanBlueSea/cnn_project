
module conv (
    input clk,
    input rst_n,
    input conv_en,
    input [10*8-1:0]image,
    input [7*32*8-1:0]weight,
    output [4*32*32-1:0]psum
);

//32层并行
//小层数放在低位
generate
    genvar n;
    for(n=0;n<32;n=n+1) begin
        conv_layer conv_layer(
            .clk(clk),
            .rst_n(rst_n),
            .conv_en(conv_en),
            .image(image),
            .weight(weight[ (n+1)*7*8-1 : n*7*8 ]),
            .psum(psum[ (n+1)*4*32-1 : n*4*32 ])
        );
    end
endgenerate
    
endmodule
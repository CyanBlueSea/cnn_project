
module conv_bias_quan_relu(
    input clk,
    input rst_n,
    input [4*32*32-1:0] output_conv,
    input en,
    input [16*32-1:0] bias,
    output en_store,
    output [4*32*8-1:0] output_layer1
);

generate
    genvar i;
    for (i=0; i<4*32; i=i+1) begin
        unit_bias_quantization_Relu #(
            .QUANTIZATION_M0(111),
            .QUANTIZATION_N(14)
        ) inst_unit
        (
            .clk(clk),
            .rst_n(rst_n),
            .en(en),
            .data_input(output_conv[i*32+31:i*32]),
            .bias(bias[(i/4)*16+15:(i/4)*16]),
            .data_output(output_layer1[i*8+7:i*8]),
            .en_store(en_store)
        );
    end
endgenerate

endmodule

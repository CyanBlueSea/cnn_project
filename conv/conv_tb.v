`timescale 1ns/1ns
module conv_tb();

//input
reg clk;
reg rst_n;
reg [15:0] data_in;
reg image_w_en;
reg conv_bias_r_en;

//connection
wire image_ready;
wire [1:0] case_stage;
wire done_conv_weight;
wire done_conv_bias;
wire conv_en;
wire conv_done;

//output
wire [10*8-1:0] conv_image;
wire [7*32*8-1:0] conv_weight;
wire [16*32-1:0] conv_bias;
wire [4*32*32-1:0] conv_psum;
wire [4*32*32-1:0] output_conv;

//output_test
wire [7:0] image_out [0:10-1];
wire [7:0] weight_out [0:7*32-1];
wire [15:0] bias_out [0:32-1];
wire [31:0] psum_out [0:4*32-1];
wire [31:0] conv_out [0:4*32-1];

//psum buffer test
wire [3:0] wr_ptr;
wire [3:0] rd_ptr;
wire [3:0] cnt1;
wire [2:0] cnt2;
wire [7:0] num;
wire psum_r_en;

integer input_weight[0:2463];
integer input_bias[0:31];
integer input_image[0:299];
integer flag_weight,flag_bias,flag_image;
integer fid_weight,fid_bias,fid_image;
integer i;

conv_weight_buffer conv_weight_buffer(
    .clk(clk),
    .rst_n(rst_n),
    .data_input(data_in),
    .r_en(image_ready),
    .case_stage(case_stage),
    .done_conv_weight(done_conv_weight),
    .conv_en(conv_en),
    .conv_weight(conv_weight)
);

conv_bias_buffer conv_bias_buffer(
    .clk(clk),
    .rst_n(rst_n),
    .done_linear_weight(done_conv_weight),
    .r_en(conv_bias_r_en),
    .data_input(data_in),
    .done_conv_bias(done_conv_bias),
    .conv_bias(conv_bias)
);

image_buffer image_buffer (
    .clk(clk),
    .rst_n(rst_n), 
    .w_en(image_w_en),
    .data_w(data_in),
/*
    .wr_ptr(wr_ptr),
    .rd_ptr(rd_ptr),
    .cnt1(cnt1),
    .cnt2(cnt2),
    .num(num),
*/
    .data_r(conv_image),
    .image_ready(image_ready),
    .case_stage(case_stage)
);

conv conv (
    .clk(clk),
    .rst_n(rst_n),
    .conv_en(conv_en),
    .image(conv_image),
    .weight(conv_weight),
    .psum(conv_psum)
);

conv_psum_buffer conv_psum_buffer (
    .clk(clk),
    .rst_n(rst_n),
    .conv_en(conv_en),
    .case_stage(case_stage),
    .psum(conv_psum),

    .wr_ptr(wr_ptr),
    .rd_ptr(rd_ptr),
    .cnt1(cnt1),
    .cnt2(cnt2),
    .num(num),
    .w_en(psum_w_en),

    .output_conv(output_conv),
    .r_en(conv_done)
);

always #5 clk=~clk;

initial begin
    fid_weight = $fopen("E:/Vivado/project/weight_bias_tb/Param_Conv_Weight.txt","r");
    fid_bias = $fopen("E:/Vivado/project/weight_bias_tb/Param_Conv_Bias.txt","r");
    fid_image = $fopen("E:/Vivado/project/weight_bias_tb/Input.txt","r");
    for(i=0;i<2464;i=i+1)
       begin
        flag_weight= $fscanf(fid_weight,"%d",input_weight[i]);
       end
    for(i=0;i<32;i=i+1)
       begin
        flag_bias= $fscanf(fid_bias,"%d",input_bias[i]);
       end
    for(i=0;i<300;i=i+1) begin
          flag_image= $fscanf(fid_image,"%d",input_image[i]);
    end
    $fclose(fid_image);
    $fclose(fid_weight);
    $fclose(fid_bias);

    rst_n=1;
    clk=0;
    image_w_en=0;
    conv_bias_r_en=0;
    #10 rst_n=0;
    
    data_in=input_weight[0];
    for(i=1;i<2464;i=i+1) begin
    #10  
    data_in=input_weight[i];
    end
    
    #10
    data_in=input_bias[0];
    for(i=1;i<32;i=i+1) begin
    #10  data_in=input_bias[i];
    end
    
    #10 rst_n=1;
    image_w_en=1;
    data_in[7:0]=input_image[0];
    data_in[15:8]=input_image[1];
    for(i=2;i<300;i=i+2) begin
    #10
    data_in[7:0]=input_image[i];
    data_in[15:8]=input_image[i+1];
    end

    #3000 conv_bias_r_en=1;
    #10
    $finish;
end

//test output
genvar n;
generate
    for(n=0;n<7*32;n=n+1) begin
        assign weight_out[n]=conv_weight[(n+1)*8-1:n*8];
    end
endgenerate
generate
    for(n=0;n<32;n=n+1) begin
        assign bias_out[n]=conv_bias[(n+1)*16-1:n*16];
    end
endgenerate
generate
    for(n=0;n<10;n=n+1) begin
        assign image_out[n]=conv_image[(n+1)*8-1:n*8];
    end
endgenerate
generate
    for(n=0;n<4*32;n=n+1) begin
        assign psum_out[n] = conv_psum[(n+1)*32-1:n*32];
    end
endgenerate
generate
    for(n=0;n<4*32;n=n+1) begin
        assign conv_out[n] = output_conv[(n+1)*32-1:n*32];
    end
endgenerate

endmodule
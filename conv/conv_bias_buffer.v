`define VALUE_TEMP_LINE(i) value_temp[16*(i)+15:16*(i)]<=conv_bias_mem[i];

module conv_bias_buffer (
    input clk,
    input rst_n,
    input done_linear_weight,
    input r_en,
    input [15:0]data_input,
    output done_conv_bias,
    output [16*32-1:0] conv_bias
);

reg [15:0] conv_bias_mem [0:31];
reg done_conv_b;  //定义该寄存器，用以标志偏置的输入是否完成，高电平表示输入完成
reg [4:0]cnt_bias;  //定义该寄存器，用以标志输入的数据的位置
reg [16*32-1:0] value_temp; //定义该寄存器，用以暂存即将输出的数据

//在rst_n信号位于低电平且全连接层卷积核的输入完成后进行数据的读入
//每一个周期写入1个数据(16bits)
//第一层卷积运算偏置的输入以及存储
always@(posedge clk or negedge rst_n) begin
    if(rst_n) cnt_bias<=4'b0;
    else if(!done_conv_b&&done_linear_weight)
        if(cnt_bias==32) cnt_bias<=0;
        else cnt_bias<=cnt_bias+1;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n&&!done_conv_b&&done_linear_weight) 
      conv_bias_mem[cnt_bias]<=data_input;
end

always@(posedge clk or negedge rst_n) begin
    if(rst_n) done_conv_b<=0;
    else if(cnt_bias==31) done_conv_b<=1;
         else done_conv_b<=done_conv_b;
end  

assign done_conv_bias=done_conv_b;

//输出逻辑
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) value_temp<=512'b0;
    else if(r_en) begin
      `VALUE_TEMP_LINE(0)
      `VALUE_TEMP_LINE(1)
      `VALUE_TEMP_LINE(2)
      `VALUE_TEMP_LINE(3)
      `VALUE_TEMP_LINE(4)
      `VALUE_TEMP_LINE(5)
      `VALUE_TEMP_LINE(6)
      `VALUE_TEMP_LINE(7)
      `VALUE_TEMP_LINE(8)
      `VALUE_TEMP_LINE(9)
      `VALUE_TEMP_LINE(10)
      `VALUE_TEMP_LINE(11)
      `VALUE_TEMP_LINE(12)
      `VALUE_TEMP_LINE(13)
      `VALUE_TEMP_LINE(14)
      `VALUE_TEMP_LINE(15)
      `VALUE_TEMP_LINE(16)
      `VALUE_TEMP_LINE(17)
      `VALUE_TEMP_LINE(18)
      `VALUE_TEMP_LINE(19)
      `VALUE_TEMP_LINE(20)
      `VALUE_TEMP_LINE(21)
      `VALUE_TEMP_LINE(22)
      `VALUE_TEMP_LINE(23)
      `VALUE_TEMP_LINE(24)
      `VALUE_TEMP_LINE(25)
      `VALUE_TEMP_LINE(26)
      `VALUE_TEMP_LINE(27)
      `VALUE_TEMP_LINE(28)
      `VALUE_TEMP_LINE(29)
      `VALUE_TEMP_LINE(30)
      `VALUE_TEMP_LINE(31)
    end
end

assign conv_bias=value_temp;
assign cnt_bias_tb=cnt_bias;

endmodule

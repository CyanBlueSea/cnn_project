`define VALUE_TEMP_DW_B(i) value_temp[16*(i)+15:16*(i)]<=dwconv_bias_mem[i];

module dwconv_bias_buffer (
    input clk,
    input rst_n,
    input done_conv_bias,
    input r_en,
    input [15:0]data_input,
    output done_dwconv_bias,
    output [32*16-1:0] dwconv_bias
);

reg [15:0] dwconv_bias_mem [0:31];
reg done_dwconv_b;  //定义该寄存器，用以标志偏置的输入是否完成，高电平表示输入完成
reg [5:0]cnt_bias;  //定义该寄存器，用以标志输入的数据的位置
reg [16*32-1:0] value_temp; //定义该寄存器，用以暂存即将输出的数据

//在rst_n信号位于低电平且第一层层卷积核的偏置输入完成后进行数据的读入
//每一个周期写入1个数据(16bits)
//第二层卷积运算偏置的输入以及存储
always@(posedge clk or negedge rst_n) begin
    if(rst_n) cnt_bias<=4'b0;
    else if(!done_dwconv_b&&done_conv_bias) begin
        if(cnt_bias==32) cnt_bias<=0;
        else cnt_bias<=cnt_bias+1;
    end
end

always@(*) begin
    if(!rst_n&&!done_dwconv_b&&done_conv_bias) 
      dwconv_bias_mem[cnt_bias]<=data_input;
end

always@(posedge clk or negedge rst_n) begin
    if(rst_n) done_dwconv_b<=0;
    else if(cnt_bias==31) done_dwconv_b<=1;
end  

assign done_dwconv_bias=done_dwconv_b;

//输出逻辑
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) value_temp<=512'b0;
    else if(r_en) begin
      `VALUE_TEMP_DW_B(0)
      `VALUE_TEMP_DW_B(1)
      `VALUE_TEMP_DW_B(2)
      `VALUE_TEMP_DW_B(3)
      `VALUE_TEMP_DW_B(4)
      `VALUE_TEMP_DW_B(5)
      `VALUE_TEMP_DW_B(6)
      `VALUE_TEMP_DW_B(7)
      `VALUE_TEMP_DW_B(8)
      `VALUE_TEMP_DW_B(9)
      `VALUE_TEMP_DW_B(10)
      `VALUE_TEMP_DW_B(11)
      `VALUE_TEMP_DW_B(12)
      `VALUE_TEMP_DW_B(13)
      `VALUE_TEMP_DW_B(14)
      `VALUE_TEMP_DW_B(15)
      `VALUE_TEMP_DW_B(16)
      `VALUE_TEMP_DW_B(17)
      `VALUE_TEMP_DW_B(18)
      `VALUE_TEMP_DW_B(19)
      `VALUE_TEMP_DW_B(20)
      `VALUE_TEMP_DW_B(21)
      `VALUE_TEMP_DW_B(22)
      `VALUE_TEMP_DW_B(23)
      `VALUE_TEMP_DW_B(24)
      `VALUE_TEMP_DW_B(25)
      `VALUE_TEMP_DW_B(26)
      `VALUE_TEMP_DW_B(27)
      `VALUE_TEMP_DW_B(28)
      `VALUE_TEMP_DW_B(29)
      `VALUE_TEMP_DW_B(30)
      `VALUE_TEMP_DW_B(31)
    end
end

assign dwconv_bias=value_temp;

endmodule


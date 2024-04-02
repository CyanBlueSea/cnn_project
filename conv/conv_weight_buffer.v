`define VALUE_TEMP_WEIGHT(n) value_temp[56*(n)+55:56*(n)] <= {conv_weight_mem[n][7*(cnt)+6], conv_weight_mem[n][7*(cnt)+5], conv_weight_mem[n][7*(cnt)+4], conv_weight_mem[n][7*(cnt)+3], conv_weight_mem[n][7*(cnt)+2], conv_weight_mem[n][7*(cnt)+1], conv_weight_mem[n][7*(cnt)]};

module conv_weight_buffer (
    input clk,
    input rst_n,
    input [15:0] data_input,
    input r_en,
    input [1:0]case_stage,
    output done_conv_weight,
    output reg conv_en,
    output [7*32*8-1:0]conv_weight
);

//case_stage标志第一层卷积的两个阶段，两个不同的阶段卷积核的输出形式不同

parameter  s1=2'b01;
parameter  s2=2'b10;

reg [7:0] conv_weight_mem [0:31][0:76];
reg done_conv_w;//定义寄存器，来标志卷积核的输入完成情况，高电平表示输入完成
reg [4:0]cnt_conv_a;//定义一组寄存器，用以标志输入的数据的位置
reg [6:0]cnt_conv_b;
reg [3:0]cnt1;
reg [3:0]cnt2;
reg [3:0]cnt;
reg [3:0]cnt_limit;  //用以标志cnt的上限，受case_stage控制，在卷积进行的不同阶段取不同的值
reg [3:0]cnt_offset;  //根据case_stage的值选择不同的偏移量
reg [7*32*8-1:0]value_temp;  //用以暂存即将输出的weight的值
integer i;

//在rst_n信号位于低电平时进行数据的读入
//每个周期写入1个数据(8bits)
//第一层卷积核的输入以及存储
always@(posedge clk or negedge rst_n) begin
    if(rst_n) cnt_conv_a<=5'b0;
    else if(!done_conv_w) begin
      if(cnt_conv_b==76) cnt_conv_a<=cnt_conv_a+1;
        else if(cnt_conv_a==32) cnt_conv_a<=0;
    end
end

always@(posedge clk) begin
    if(rst_n) cnt_conv_b<=7'b0;
    else if(!done_conv_w) begin
      if(cnt_conv_b==76) cnt_conv_b<=7'b0;
        else cnt_conv_b<=cnt_conv_b+1;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n&&!done_conv_w) conv_weight_mem[cnt_conv_a][cnt_conv_b]<=data_input[7:0];
end

always@(posedge clk or negedge rst_n) begin
    if(rst_n) done_conv_w<=0;
    else if(cnt_conv_a==31&&cnt_conv_b==76) done_conv_w<=1;

end

assign done_conv_weight=done_conv_w;

//卷积核的输出模块，受第一层卷积运算控制，具体表现为r_en使能信号以及case_stage信号

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) cnt1<=4'b0;
      else if(case_stage==s1) begin
        if(cnt1<4) cnt1<=cnt1+1;
          else cnt1<=4'b0;
      end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) cnt2<=5;
      else if(case_stage==s2) begin
        if(cnt2<10) cnt2<=cnt2+1;
          else cnt2<=5;
      end
end

always @(*) begin
    case (case_stage)
        s1: cnt = cnt1;
        s2: cnt = cnt2;
        default: cnt = 4'b0;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) value_temp<=1792'b0;
    else if(r_en) begin
      `VALUE_TEMP_WEIGHT(0)
      `VALUE_TEMP_WEIGHT(1)
      `VALUE_TEMP_WEIGHT(2)
      `VALUE_TEMP_WEIGHT(3)
      `VALUE_TEMP_WEIGHT(4)
      `VALUE_TEMP_WEIGHT(5)
      `VALUE_TEMP_WEIGHT(6)
      `VALUE_TEMP_WEIGHT(7)
      `VALUE_TEMP_WEIGHT(8)
      `VALUE_TEMP_WEIGHT(9)
      `VALUE_TEMP_WEIGHT(10)
      `VALUE_TEMP_WEIGHT(11)
      `VALUE_TEMP_WEIGHT(12)
      `VALUE_TEMP_WEIGHT(13)
      `VALUE_TEMP_WEIGHT(14)
      `VALUE_TEMP_WEIGHT(15)
      `VALUE_TEMP_WEIGHT(16)
      `VALUE_TEMP_WEIGHT(17)
      `VALUE_TEMP_WEIGHT(18)
      `VALUE_TEMP_WEIGHT(19)
      `VALUE_TEMP_WEIGHT(20)
      `VALUE_TEMP_WEIGHT(21)
      `VALUE_TEMP_WEIGHT(22)
      `VALUE_TEMP_WEIGHT(23)
      `VALUE_TEMP_WEIGHT(24)
      `VALUE_TEMP_WEIGHT(25)
      `VALUE_TEMP_WEIGHT(26)
      `VALUE_TEMP_WEIGHT(27)
      `VALUE_TEMP_WEIGHT(28)
      `VALUE_TEMP_WEIGHT(29)
      `VALUE_TEMP_WEIGHT(30)
      `VALUE_TEMP_WEIGHT(31)
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) conv_en<=1'b0;
    else if(r_en) conv_en<=1'b1;
    else conv_en<=1'b0;
end

assign conv_weight=value_temp;
assign cnt_tb=cnt;
assign cnt_conv_a_tb=cnt_conv_a;
assign cnt_conv_b_tb=cnt_conv_b;

endmodule
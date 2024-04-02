
module image_buffer (
    input clk,
    input rst_n,
    input w_en,
    input [8*2-1:0] data_w,
/*
    //测试信号
    output reg [8:0] wr_ptr,
    output [4:0] rd_ptr,
    output reg [4:0] cnt1,
    output reg [2:0] cnt2,
    output reg [7:0] num,
*/
    output reg [10*8-1:0] data_r,
    output reg image_ready,
    output reg [1:0] case_stage
);

reg [7:0] memory [0:10*30-1];
reg [8:0] wr_ptr;
//读出指针按行计算
wire [4:0] rd_ptr;

/*读入存储操作*/
//每个周期写入2个数据
always@(posedge clk or negedge rst_n) begin
    if((!rst_n)||(!w_en)) wr_ptr<=9'b0;
    else if((wr_ptr==10*5-2)&&(rd_ptr>0)) wr_ptr<=wr_ptr;
    else if(wr_ptr<10*30-2) wr_ptr<=wr_ptr+2;
    else wr_ptr<=9'b0;
end
//memory在复位时要清零吗
//else?
always@(posedge clk or negedge rst_n) begin
    if (w_en && rst_n) begin
        memory[wr_ptr+1]<=data_w[15:8];
        memory[wr_ptr]<=data_w[7:0];
    end
end

/*读出存储操作*/
//num记录cycles数（最大220）
reg [7:0] num;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) num<=8'b0;
    else if((wr_ptr<10*5-2)&&(rd_ptr==0)) num<=8'b0;
    else if(num<8'd219) num<=num+1;
    else num<=8'b0;
end
//image_ready
always@(*) begin
    if(!rst_n) image_ready<=1'b0;
    else if((wr_ptr<10*5-2)&&(rd_ptr==0)) image_ready<=1'b0;
    else image_ready<=1'b1;
end
//case_stage
always@(*) begin
    if(!rst_n) case_stage<=2'b0;
    else if((wr_ptr<10*5-2)&&(rd_ptr==0)) case_stage<=2'b0;
    else if((num<50)||(num>=110 && num<160)) case_stage<=2'b1;
    else case_stage<=2'd2;
end
//cnt12用于确定rd_ptr
reg [4:0] cnt1;
reg [2:0] cnt2;
always@(*) begin
        if(!rst_n) cnt1 = 5'b0;
        else if(num < 50) cnt1 = num / 5;
        else if(num < 110) cnt1 = 5 + (num - 50) / 6;
        else if(num < 160) cnt1 = 10 + (num - 110) / 5;
        else if(num < 220) cnt1 = 15 + (num - 160) / 6;
        else cnt1 = 5'b0;
end
always@(num) begin
        case(case_stage)
            2'b0: cnt2 = 3'b0;
            2'b1: if(cnt2 < 4) cnt2 = cnt2 + 1;
                        else cnt2 = 3'b0;
            2'd2: if(cnt2 < 5) cnt2 = cnt2 + 1;
                        else cnt2 = 3'b0;
            default: cnt2 = 3'b0;
        endcase
end
assign rd_ptr = cnt1 + cnt2;
//每次读一行
genvar i;
generate
    for (i = 0; i < 10; i = i + 1) begin
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) data_r[i*8+7:i*8] <= 0;
            else if (image_ready) data_r[i*8+7:i*8] <= memory[10*rd_ptr+i];
            else data_r[i*8+7:i*8] <= 0;
        end
    end
endgenerate

endmodule
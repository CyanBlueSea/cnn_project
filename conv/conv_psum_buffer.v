`define VALUE_TEMP_PSUM(i) value_temp[(i+1)*4*32-1:i*4*32]={memory[i][rd_ptr][3],memory[i][rd_ptr][2],memory[i][rd_ptr][1],memory[i][rd_ptr][0]};

module conv_psum_buffer (
    input clk,
    input rst_n,
    input conv_en,
    input [1:0]case_stage,
    input [4*32*32-1:0] psum,

    //output_test
    output reg [3:0] wr_ptr,
    output reg [3:0] rd_ptr,
    output reg [3:0] cnt1,
    output reg [2:0] cnt2,
    output reg [7:0] num,
    output reg w_en,

    output [4*32*32-1:0] output_conv,
    output reg r_en
);

//小层数放在低位
reg [4*32*32-1:0] value_temp;
reg [31:0] memory [0:32-1][0:10-1][0:4-1];
//读写指针以行为计数
reg [3:0] wr_ptr;
reg [3:0] rd_ptr;
reg w_en;
integer n,m,q;

wire [31:0] p [0:32-1][0:4-1]; 
genvar i,j;
generate
    for(i=0;i<32;i=i+1) begin
        for(j=0;j<4;j=j+1) begin
            assign p[i][j]=psum[ i*32*4+j*32+31 : i*32*4+j*32 ];
        end
    end
endgenerate

/*psum读入存储操作*/
//conv_en使能后一个周期开始读入psum
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) w_en<=1'b0;
    else if(conv_en) w_en<=1'b1;
    else w_en<=1'b0;
end
//num记录开始读入后的周期数(最多110)
reg [6:0] num;
always@(posedge clk or negedge rst_n) begin
    if((!rst_n)||(!w_en)) num<=7'b0;
    else if(num<110) num<=num+1;
    else num<=7'b1;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) wr_ptr<=4'b0;
    else if(num<50-1) wr_ptr<=(num+1)/5;
    else if(num<110-1) wr_ptr<=(num-49)/6;
    else wr_ptr<=4'b0;
end
//每次读入1行psum（32层）
//else?
always@(posedge clk or negedge rst_n) begin
    if (w_en && rst_n) begin
        for(n=0;n<32;n=n+1) begin
               memory[n][wr_ptr][3]<=p[n][3]+memory[n][wr_ptr][3];
               memory[n][wr_ptr][2]<=p[n][2]+memory[n][wr_ptr][2];   
               memory[n][wr_ptr][1]<=p[n][1]+memory[n][wr_ptr][1];
               memory[n][wr_ptr][0]<=p[n][0]+memory[n][wr_ptr][0];
        end
    end
    else begin
        for(n=0;n<32;n=n+1) begin
            for(m=0;m<10;m=m+1) begin
                for(q=0;q<4;q=q+1) begin
                    memory[n][m][q]<=32'b0;
                end
            end
        end
    end
end

/*output读出存储操作*/
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) r_en<=1'b0;
    else if((num>50)&&((num-50)%6==0)) r_en<=1'b1;
    else r_en<=1'b0;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) rd_ptr<=4'b0;
    else if((r_en)&&(rd_ptr<10-1)) rd_ptr<=rd_ptr+1;
    else if(r_en) rd_ptr<=4'b0;
    else rd_ptr<=rd_ptr;
end
//每次读出1行psum（32层）
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) value_temp<=4096'b0;
    else begin
      `VALUE_TEMP_PSUM(0)
      `VALUE_TEMP_PSUM(1)
      `VALUE_TEMP_PSUM(2)
      `VALUE_TEMP_PSUM(3)
      `VALUE_TEMP_PSUM(4)
      `VALUE_TEMP_PSUM(5)
      `VALUE_TEMP_PSUM(6)
      `VALUE_TEMP_PSUM(7)
      `VALUE_TEMP_PSUM(8)
      `VALUE_TEMP_PSUM(9)
      `VALUE_TEMP_PSUM(10)
      `VALUE_TEMP_PSUM(11)
      `VALUE_TEMP_PSUM(12)
      `VALUE_TEMP_PSUM(13)
      `VALUE_TEMP_PSUM(14)
      `VALUE_TEMP_PSUM(15)
      `VALUE_TEMP_PSUM(16)
      `VALUE_TEMP_PSUM(17)
      `VALUE_TEMP_PSUM(18)
      `VALUE_TEMP_PSUM(19)
      `VALUE_TEMP_PSUM(20)
      `VALUE_TEMP_PSUM(21)
      `VALUE_TEMP_PSUM(22)
      `VALUE_TEMP_PSUM(23)
      `VALUE_TEMP_PSUM(24)
      `VALUE_TEMP_PSUM(25)
      `VALUE_TEMP_PSUM(26)
      `VALUE_TEMP_PSUM(27)
      `VALUE_TEMP_PSUM(28)
      `VALUE_TEMP_PSUM(29)
      `VALUE_TEMP_PSUM(30)
      `VALUE_TEMP_PSUM(31)
    end
end

assign output_conv=value_temp;

endmodule
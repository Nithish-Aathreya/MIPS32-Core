`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2024 21:32:44
// Design Name: 
// Module Name: main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main(clk1,clk2);
input clk1,clk2;

reg [31:0]if_id_ir,if_id_npc,pc;

reg[31:0]id_ex_a,id_ex_b,id_ex_imm,id_ex_npc,id_ex_ir;
reg[2:0] id_ex_type,ex_mem_type,mem_wb_type;

reg [31:0]ex_mem_ir,ex_mem_aluout,ex_mem_cond,ex_mem_b;

reg[31:0]mem_wb_aluout,mem_wb_lmd,mem_wb_ir;

reg [31:0]registerbank[31:0];
reg [31:0]mem[1023:0];

parameter add=6'b000000,sub=6'b000001,AND=6'b000010,OR=6'b000011,beqz=6'b000100,HALT=6'b111111,LW=6'b000110,SW=6'b000111;

parameter RR_type=3'b000,Branch=3'b001,Load=3'b010,Store=3'b011,hlt=3'b100;




reg halt;
reg taken_branch;



//Stage 1 (IF stage)
always @(posedge clk1)
if(halt==1'b0)
begin
if(ex_mem_ir[31:26]==beqz && ex_mem_cond==1'b1)
begin
taken_branch<=1'b1;
if_id_ir<=mem[ex_mem_aluout];
if_id_npc<=ex_mem_aluout + 1'b1;
pc<= ex_mem_aluout + 1'b1;
end
else
begin
taken_branch<=1'b0;
if_id_ir<=mem[pc];
if_id_npc<=pc + 1'b1;
pc<= pc + 1'b1;
end
end

//Stage 2 (ID stage)

always@(posedge clk2)
if(halt==1'b0)
begin
if(if_id_ir[25:21]==5'b0)    //register0 in mips32 default value is zero
id_ex_a<=32'b0;
else
id_ex_a<=registerbank[if_id_ir[25:21]];  //rs

if(if_id_ir[20:16]==5'b0)
id_ex_b<=32'b0;
else
id_ex_b<=registerbank[if_id_ir[20:16]];   //rt

id_ex_imm<={{16{if_id_ir[15]}} ,if_id_ir[15:0]};
id_ex_ir<=if_id_ir;
id_ex_npc<=if_id_npc;

case(if_id_ir[31:26])
add:id_ex_type<=RR_type;
sub:id_ex_type<=RR_type;
AND:id_ex_type<=RR_type;
OR:id_ex_type<=RR_type;
beqz:id_ex_type<=Branch;
LW:id_ex_type<=Load;
SW:id_ex_type<=Store;
HALT:id_ex_type<=hlt;
endcase
end


//Stage 3(EX stage)

always @(posedge clk1)
if(halt==1'b0)
begin
ex_mem_ir<=id_ex_ir;
ex_mem_type<=id_ex_type;
taken_branch=1'b0;
case(id_ex_ir[31:26])
add: ex_mem_aluout<=id_ex_a + id_ex_b;
sub: ex_mem_aluout<=id_ex_a - id_ex_b;
AND: ex_mem_aluout<=id_ex_a & id_ex_b;
OR: ex_mem_aluout<=id_ex_a | id_ex_b;
beqz: begin
ex_mem_aluout<=id_ex_imm + id_ex_npc;
ex_mem_cond<=(id_ex_a==1'b0);
end
LW: begin
ex_mem_aluout<=id_ex_imm + id_ex_a;
ex_mem_b<=id_ex_b;
end
SW:begin
 ex_mem_aluout<=id_ex_imm + id_ex_a;
ex_mem_b<=id_ex_b;
end
endcase
end

//Stage 4 (MEM Stage)

always @(posedge clk2)
if(halt==1'b0)
begin
mem_wb_ir<=ex_mem_ir;
mem_wb_type<=ex_mem_type;

case(ex_mem_type)
RR_type:mem_wb_aluout<=ex_mem_aluout;
Load: mem_wb_lmd<=mem[ex_mem_aluout];
Store: if(taken_branch==1'b0)
mem[ex_mem_aluout]<=registerbank[ex_mem_b[20:16]];
endcase
end



//Stage 5 (WB stage)

always @(posedge clk1)
if(taken_branch==1'b0)
begin
case(mem_wb_type)
RR_type: registerbank[mem_wb_ir[15:11]]<=mem_wb_aluout;
Load: registerbank[mem_wb_ir[20:16]]<=mem_wb_lmd;
hlt: halt<=1'b1;
endcase
end


endmodule

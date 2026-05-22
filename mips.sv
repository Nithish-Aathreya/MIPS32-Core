module mips(clk1,clk2);

//inputs
input clk1,clk2;

//instruction and data memory [harvard architecture]
reg [7:0]mem_i[4095:0];
reg [7:0]mem_d[4095:0];

reg [31:0]reg_bank[31:0];

//opcode parameter's - ADD,SUB,AND,OR,MUL have same opcode's
parameter ADD=6'b000000, ADDI=6'b001000, BEQZ=6'b000100, BNEQZ=6'b000101,LW=6'b100011,SW=6'b101011,HLT=6'b000000, SUB=6'b000000, AND=6'b000000, OR=6'b000000, MUL=6'b000000;

//funct field parameter's
parameter ADD_F=6'b100000, SUB_F=6'b100010, AND_F=6'b100100, OR_F=6'b100101, MUL_F=6'b000010;

string assoc[bit [5:0]]; //to track funct fields of operation
task assoc_assign(); //value assignment to associative array should be inside procedural block
   assoc[6'b100000] = "ADD_FUNCT";
   assoc[6'b100010] = "SUB_FUNCT";
   assoc[6'b100100] = "AND_FUNCT";
   assoc[6'b100101] = "OR_FUNCT";
   assoc[6'b000010] = "MUL_FUNCT";
   assoc[6'b001000] = "ADD_IMMEDIATE_OPCODE";

endtask

//operation type
//parameter R_type=3'b000,I_type=3'b001,B_type=3'b010,L_type=3'b011,S_type=3'b100,HALT_type=3'b101;

typedef enum reg [2:0] {

NOP_type=3'b110,
R_type=3'b000,
I_type=3'b001,
B_type=3'b010,
L_type=3'b011,
S_type=3'b100,
HALT_type=3'b101
    }type_of_op; 

//considered this approach to track operation type by name, 
//instead of by number which happens in parameter based tracking
//id_ex_type,ex_mem_type,mem_wb_type = variables of data type "type_of_op"
//so,earlier declaration of these as signals are commented out
    type_of_op id_ex_type,ex_mem_type,mem_wb_type;

//IF stage declr.
reg [31:0] if_id_ir;
reg [11:0]if_id_npc,pc;
reg hlt,taken_branch;

//ID stage declr.
reg [31:0] id_ex_a,id_ex_b,id_ex_imm,id_ex_ir;
//reg [2:0] id_ ex_type;
reg [11:0]id_ex_npc;

//EX stage declr.
reg [31:0] ex_mem_aluout,ex_mem_b,ex_mem_ir;
reg ex_mem_cond;
//reg [2:0] ex_mem_type;


//Mem stage declr.
reg [31:0] mem_wb_lmd;
//reg [2:0] mem_wb_type;

//WB stage declr.
reg [31:0] mem_wb_ir;

//Forwarding unit declrs.
reg [4:0] ex_mem_dest;

reg [4:0] mem_wb_dest;

wire fwd_A_from_MEM;
wire fwd_B_from_MEM;

wire fwd_A_from_WB;
wire fwd_B_from_WB;
reg [31:0] fwd_a, fwd_b;

//Instruction Fetch Stage
always@(posedge clk1) begin
    if(hlt==0)  begin        //halt is similar to no-operation command in x86
        assoc_assign();
        if( (ex_mem_ir[31:26]==BEQZ && ex_mem_cond==1) || (ex_mem_ir[31:26]==BNEQZ && ex_mem_cond==1 )) begin 
            taken_branch <=1;
            if_id_ir<={mem_i[ex_mem_aluout[11:0]],   mem_i[ex_mem_aluout[11:0]+1],
                                mem_i[ex_mem_aluout[11:0]+2], mem_i[ex_mem_aluout[11:0]+3]};
            pc <= ex_mem_aluout[11:0]+4;
            if_id_npc <= ex_mem_aluout[11:0]+4;
            ex_mem_cond<=0;
        end 
//fetching instruction from instruction memory
//Using Big-Endian - higher byte to lower address
//if_id_ir<={mem_i[ex_mem_aluout[11:0]] = higher byte data(MSB), mem_i[ex_mem_aluout[11:0]+4]= lower byte of data(LSB)
        
        else begin
            taken_branch <=0;
            if_id_ir <= {mem_i[pc], mem_i[pc+1], mem_i[pc+2], mem_i[pc+3]};
            pc<=pc+4;
            if_id_npc<=if_id_npc+4;
    end
end
end


//Instruction decode stage 
always@(posedge clk2) begin
    if(hlt==0) begin
   //  FLUSH: if branch taken, squash whatever is in IR(id_ex_ir) & insert NOP
        if((ex_mem_ir[31:26]==BEQZ && ex_mem_cond==1) || 
           (ex_mem_ir[31:26]==BNEQZ && ex_mem_cond==1)) begin
            id_ex_ir   <= 32'h00000000;  // NOP
            id_ex_type <= NOP_type;     // treat as no-op(stalling), not halt
            id_ex_a    <= 32'h0;
            id_ex_b    <= 32'h0;
            id_ex_imm  <= 32'h0;
            id_ex_npc  <= 12'h0;
        end

        else begin
        id_ex_a<=reg_bank[if_id_ir[25:21]]; //rs  
        id_ex_b<=reg_bank[if_id_ir[20:16]]; //rt
        id_ex_imm<= {{16{if_id_ir[15]}},if_id_ir[15:0]};//sign ext.
        case(if_id_ir[31:26])
            ADD: id_ex_type<=R_type;
            SUB: id_ex_type<=R_type;
            AND: id_ex_type<=R_type;
            OR:  id_ex_type<=R_type;
            MUL: id_ex_type<=R_type;
            //SLT: id_ex_type<=R_type;

            ADDI:id_ex_type<=I_type;
            //SUBI:id_ex_type<=I_type;
            //SLTI:id_ex_type<=I_type;

            BEQZ:id_ex_type<=B_type;
            BNEQZ:id_ex_type<=B_type;

            LW:  id_ex_type<=L_type;

            SW:  id_ex_type<=S_type;

            HLT: id_ex_type<=HALT_type;

            //default: id_ex_type<=HALT_type;
        endcase
        id_ex_ir<=if_id_ir; //need opcode & funct, so forwarding it
        id_ex_npc<=if_id_npc;
    end
    end
end

//Execution stage
always@(posedge clk1) begin
    if(hlt==0) begin
    case(id_ex_type)
        R_type: begin
            case(id_ex_ir[5:0]) //Reg type instr. based on funct. field in instr.
            ADD_F: ex_mem_aluout <=fwd_a + fwd_b;
            //ADD_F: ex_mem_aluout <=id_ex_a + id_ex_b;
            SUB_F: ex_mem_aluout <=fwd_a - fwd_b ;
            AND_F: ex_mem_aluout <=fwd_a & fwd_b ;
            OR_F:  ex_mem_aluout <=fwd_a | fwd_b ;
            MUL_F: ex_mem_aluout <=fwd_a * fwd_b ;
       endcase
       //$display("========================================================");
      // $display("\t Funct field in instruction = %0s",assoc[id_ex_ir[5:0]]);
      // $display("========================================================");
       end
   endcase
   if(id_ex_type!=R_type) begin
    case(id_ex_ir[31:26])
            ADDI:ex_mem_aluout <=fwd_a + id_ex_imm ;
            //SUBI:ex_mem_aluout <=id_ex_a - id_ex_imm ;

            BEQZ:
            begin
                //ex_mem_aluout gives address(Target address) to fetch instruction
                //Target address=(pc+4) + (offset x 4) => 
                //offset = (Target address - (pc+4))/4
                //offset = number of instr. to skip
                //multiply by 4 bcz, each insr. is 4 bytes
                //offset is calculated by assembler 
                //id_ex_imm = offset value
                //so, id_ex_imm is left shifted by 2 (basically multiply by 4)
              ex_mem_aluout <=(id_ex_imm<<2) + id_ex_npc; 
              if(fwd_a==0)begin 
                ex_mem_cond   <=1; 
              end
              else
              ex_mem_cond   <=0; 
              end
            BNEQZ:
            begin
              ex_mem_aluout <=(id_ex_imm<<2) + id_ex_npc  ;
              if(fwd_a!=0) begin
                  ex_mem_cond   <=1; 
              end
              else
                  ex_mem_cond   <=0; 

              end

            LW:  
            begin
              ex_mem_aluout <=id_ex_imm + fwd_a  ;
              //ex_mem_b      <=id_ex_b; 
              ex_mem_b      <=fwd_b; 
              end

            SW:
            begin
              ex_mem_aluout <=id_ex_imm + fwd_a  ;
              //ex_mem_b      <=id_ex_b; 
              ex_mem_b      <=fwd_b; 
              end
        default: ex_mem_aluout <=32'h0;
        endcase
    end
       //$display("========================================================");
     //  $display("\t Opcode field in instruction = %0s",assoc[id_ex_ir[31:26]]);
     //  $display("========================================================");
        ex_mem_type<=id_ex_type;
        ex_mem_ir  <=id_ex_ir;
    end
end

//Memory stage 
always@(posedge clk2) begin
    if(hlt==0) begin
    case(ex_mem_type)
        R_type:mem_wb_lmd <= ex_mem_aluout;
        I_type:mem_wb_lmd <= ex_mem_aluout;
        L_type: mem_wb_lmd <= {mem_d[ex_mem_aluout[11:0]],   mem_d[ex_mem_aluout[11:0]+1],
                                mem_d[ex_mem_aluout[11:0]+2], mem_d[ex_mem_aluout[11:0]+3]};
        S_type: begin
            mem_d[ex_mem_aluout[11:0]]   <= ex_mem_b[31:24];
            mem_d[ex_mem_aluout[11:0]+1] <= ex_mem_b[23:16];
            mem_d[ex_mem_aluout[11:0]+2] <= ex_mem_b[15:8];
            mem_d[ex_mem_aluout[11:0]+3] <= ex_mem_b[7:0];
                end
    endcase
    mem_wb_type<=ex_mem_type;
    mem_wb_ir  <= ex_mem_ir;
end
end

//Write-back stage
always@(posedge clk1) begin
    case(mem_wb_type)
        R_type: reg_bank[mem_wb_ir[15:11]] <= mem_wb_lmd; //rd
        I_type: reg_bank[mem_wb_ir[20:16]] <= mem_wb_lmd; //rt
        L_type: reg_bank[mem_wb_ir[20:16]] <= mem_wb_lmd;
 HALT_type: begin
            if(mem_wb_ir != 32'h0)  // not a NOP bubble
                hlt <= 1;
        end
        NOP_type:;
        default:;
    endcase
end

//finding out dest. reg. @end of EX stage ie.@MEM stage
always @(*) begin
    if      (ex_mem_type == R_type)  ex_mem_dest = ex_mem_ir[15:11];
    else if (ex_mem_type == I_type)  ex_mem_dest = ex_mem_ir[20:16];
    else if (ex_mem_type == L_type)  ex_mem_dest = ex_mem_ir[20:16];
    else                             ex_mem_dest = 5'b0;
end

//only R and I type bcz,in MEM stage LW oprn. not yet completed 
assign fwd_A_from_MEM = (ex_mem_type == R_type || ex_mem_type == I_type) &&
                      (ex_mem_dest == id_ex_ir[25:21]);

assign fwd_B_from_MEM = (ex_mem_type == R_type || ex_mem_type == I_type) &&
                      (ex_mem_dest == id_ex_ir[20:16]);

//finding out dest. reg. @end of MEM stage ie.@WB stage
always @(*) begin
    if      (mem_wb_type == R_type)  mem_wb_dest = mem_wb_ir[15:11];
    else if (mem_wb_type == I_type)  mem_wb_dest = mem_wb_ir[20:16];
    else if (mem_wb_type == L_type)  mem_wb_dest = mem_wb_ir[20:16];
    else                             mem_wb_dest = 5'b0;
end

//R,I and L type bcz,in MEM stage LW oprn. is completed 
assign fwd_A_from_WB = (mem_wb_type == R_type || mem_wb_type == I_type || mem_wb_type == L_type) &&
                     (mem_wb_dest == id_ex_ir[25:21]) && !fwd_A_from_MEM;
//!fwd_B_from_MEM = if mem stage not forwarding, then only wb stage should
//forward
assign fwd_B_from_WB = (mem_wb_type == R_type || mem_wb_type == I_type || mem_wb_type == L_type) &&
                     (mem_wb_dest == id_ex_ir[20:16]) && !fwd_B_from_MEM;

always @(*) begin
    if      (fwd_A_from_MEM)  fwd_a = ex_mem_aluout;
    else if (fwd_A_from_WB)   fwd_a = mem_wb_lmd;
    else                      fwd_a = id_ex_a;

    if      (fwd_B_from_MEM)  fwd_b = ex_mem_aluout;
    else if (fwd_B_from_WB)   fwd_b = mem_wb_lmd;
    else                      fwd_b = id_ex_b;
end
endmodule

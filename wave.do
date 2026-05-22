onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group {CLK } -radix hexadecimal /top/dut/clk1
add wave -noupdate -group {CLK } -radix hexadecimal /top/dut/clk2
add wave -noupdate -radix hexadecimal /top/dut/hlt
add wave -noupdate -expand -group IF_STAGE -radix hexadecimal /top/dut/pc
add wave -noupdate -expand -group IF_STAGE -radix hexadecimal /top/dut/if_id_npc
add wave -noupdate -expand -group IF_STAGE -radix hexadecimal /top/dut/if_id_ir
add wave -noupdate -radix hexadecimal /top/dut/taken_branch
add wave -noupdate -expand -group ID_STAGE -radix hexadecimal /top/dut/id_ex_a
add wave -noupdate -expand -group ID_STAGE -radix hexadecimal /top/dut/id_ex_b
add wave -noupdate -expand -group ID_STAGE -radix hexadecimal /top/dut/id_ex_imm
add wave -noupdate -expand -group ID_STAGE -radix hexadecimal /top/dut/id_ex_type
add wave -noupdate -expand -group ID_STAGE -radix hexadecimal /top/dut/id_ex_ir
add wave -noupdate -expand -group ID_STAGE -radix hexadecimal /top/dut/id_ex_npc
add wave -noupdate -expand -group EX_STAGE -radix hexadecimal /top/dut/ex_mem_ir
add wave -noupdate -expand -group EX_STAGE -radix hexadecimal /top/dut/ex_mem_type
add wave -noupdate -expand -group EX_STAGE -radix hexadecimal /top/dut/ex_mem_aluout
add wave -noupdate -expand -group EX_STAGE -radix hexadecimal /top/dut/ex_mem_b
add wave -noupdate -expand -group EX_STAGE -radix hexadecimal /top/dut/ex_mem_cond
add wave -noupdate -expand -group MEM_WB_STAGE -radix hexadecimal /top/dut/mem_wb_ir
add wave -noupdate -expand -group MEM_WB_STAGE -radix hexadecimal /top/dut/mem_wb_lmd
add wave -noupdate -expand -group MEM_WB_STAGE -radix hexadecimal /top/dut/mem_wb_type
add wave -noupdate -expand -group FU_OPERAND_A -radix hexadecimal /top/dut/ex_mem_dest
add wave -noupdate -expand -group FU_OPERAND_A -radix hexadecimal /top/dut/fwd_A_from_MEM
add wave -noupdate -expand -group FU_OPERAND_A -radix hexadecimal /top/dut/fwd_B_from_MEM
add wave -noupdate -expand -group FU_OPERAND_A -radix hexadecimal /top/dut/fwd_a
add wave -noupdate -expand -group FU_OPERAND_B -radix hexadecimal /top/dut/mem_wb_dest
add wave -noupdate -expand -group FU_OPERAND_B -radix hexadecimal /top/dut/fwd_A_from_WB
add wave -noupdate -expand -group FU_OPERAND_B -radix hexadecimal /top/dut/fwd_B_from_WB
add wave -noupdate -expand -group FU_OPERAND_B -radix hexadecimal /top/dut/fwd_b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 284
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {101 ns}

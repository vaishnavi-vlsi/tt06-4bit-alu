/*
 * Copyright (c) 2026 Vaishnavi Moru
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vaishnavi_4bit_alu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs:  Bidirectional Input path
    output wire [7:0] uio_out,  // IOs:  Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs:  Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered or selected
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Unused bidirectional pins set to 0
    assign uio_out = 8'b0;
    assign uio_oe = 8'b0;

  // Mapping Inputs from ui_in
  // ui_in[3:0] -> Operand A (4 bits)
  // ui_in[7:4] -> Operand B (4 bits)
    wire [3:0] A = ui_in[3:0];
    wire [3:0] B = ui_in[7:4];
    
 // Mapping Opcode selection from uio_in[2:0]
    wire [2:0] opcode = uio_in[2:0];

// Internal Registers & Signals
    reg [3:0] alu_out;
    reg       carry_out;
    reg       zero_flag;

// 4-bit ALU Operations Combinational Logic
    always @(*) begin
        carry_out = 1'b0;
        case (opcode)
             3'b000: {carry_out, alu_out} = A + B; // ADD
             3'b001: {carry_out, alu_out} = A - B; // SUB
             3'b010:  alu_out = A & B; // AND
             3'b011:  alu_out = A | B; // OR
             3'b100:  alu_out = A ^ B; // XOR
             3'b101: alu_out = ~(A | B); // NOR
             3'b110: alu_out = A << 1; // Shift Left A
             3'b111:  alu_out = A >> 1; //  Shift Right A
             default: alu_out = 4'b0000;
        endcase

 // Zero Flag calculation
        zero_flag = (alu_out == 4'b0000) ? 1'b1 : 1'b0;
    end

// Mapping Outputs to uo_out
// uo_out[3:0] -> ALU Result
// uo_out[4] -> Carry Flag
    // uo_out[5] -> Zero Flag
    assign uo_out[3:0] = alu_out;
    assign uo_out[4] = carry_out;
    assign uo_out[5] = zero_flag;
    assign uo_out[7:6] = 2'b00; // Reserved pins tied to 0

// Suppress unused input warnings
    wire _unused = &{ena, clk, rst_n, uio_in[7:3], 1'bo};
    


endmodule

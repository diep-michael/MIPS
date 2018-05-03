`timescale 1ns / 1ps
 /*********************************************************
 * File Name: Pipelined_MCU.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/22/18
 *
 * Purpose: The purpose of this module is a combinational cloud which
 *          generates the appropriate control signals depending on 
 *          the IR input. Each instruction will be decoded
 *          and the appropriate control signals generated.
 *    
 *       INPUTS:
 *          IR         - 32-bit Instruction
 *          intr       - Interrupt Request
 *          IE         - current state of IE flag
 *
 *       OUTPUTS:          
 *          FS         - Function Select/Opcode for ALU
 *          D_en       - Register File Write Enable
 *          D_sel      - Register File Data Select
 *          HILO_ld    - HI/LO Register Load (used for mult/div)
 *          T_sel      - T-Register Select (used for i-type)
 *          Y_sel      - ALU_OUT select
 *          dm_cs      - Data memory Chip Select
 *          dm_wr      - Data memory Write
 *          dm_rd      - Data memory Read
 *          io_cs      - I/O memory Chip Select
 *          io_wr      - I/O memory Write
 *          io_rd      - I/O memory Read
 *          m2r        - MEM2REG mux select
 *          new_IE     - next state of IE flag
 *          RFD_sel    - Reg File Data input Select
 *
 * Notes:   
 *          Rev. 4/16/18  - implemented memory modules 1-13
 *                        updated header and adjusted RTL comments
 *********************************************************/
module Pipelined_MCU(intr, m2r,
                  IE, new_IE,
                  IR, FS,
                  RFD_sel,
                  D_en, D_sel, T_sel, HILO_ld, Y_sel,
                  dm_cs, dm_rd, dm_wr,
                  io_cs, io_rd, io_wr);
            
input intr;
input IE;
input [31:0] IR; 
output reg new_IE;
output reg D_en, HILO_ld, T_sel;
output reg [1:0] D_sel, m2r;
output reg [2:0] Y_sel, RFD_sel;
output reg [4:0] FS;
output reg dm_cs, dm_rd, dm_wr;
output reg io_cs, io_rd, io_wr;

//instruction names
parameter
   SLL = 6'h00, 
   SRL = 6'h02, 
   SRA = 6'h03, 
   JR  = 6'h08, 
   MFHI= 6'h10, 
   MFLO= 6'h12, 
   MULT= 6'h18, 
   DIV = 6'h1A, 
   ADD = 6'h20, 
   ADDU= 6'h21, 
   SUB = 6'h22, 
   SUBU= 6'h23, 
   AND = 6'h24, 
   OR  = 6'h25, 
   XOR = 6'h26, 
   NOR = 6'h27, 
   SLT = 6'h2A, 
   SLTU= 6'h2B, 
   BREAK= 6'h0D,
   SETIE= 6'h1F,
   
   BEQ = 6'h04, 
   BNE = 6'h05, 
   BLEZ= 6'h06, 
   BGTZ= 6'h07, 
   ADDI= 6'h08, 
   SLTI= 6'h0A, 
   SLTIU=6'h0B, 
   ANDI= 6'h0C, 
   ORI = 6'h0D, 
   XORI= 6'h0E, 
   LUI = 6'h0F, 
   LW  = 6'h23, 
   SW  = 6'h2B, 
   
   J   = 6'h02, 
   JAL = 6'h03, 
   
   INPUT = 6'h1C, 
   OUTPUT= 6'h1D,
   RETI =  6'h1E;

always @(*)
 if (intr==1 & IE==1)
  begin //new interrupt pending; prepare for isr
  //control word for ALU_out <- 0x3FC, PC <- MEM2REG (MEM_OUT (dMEM[3FC]))
  {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_10_0_0_000; FS = 5'h15;
  {dm_cs, dm_rd, dm_wr} = 3'b1_1_0;  m2r = 2'b01; RFD_sel = 3'h3;
  end
 else
    begin //no new interrupt pending; fetch an instruction
     if (IR==32'b0) begin //NOP
         {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
         {dm_cs, dm_rd, dm_wr}= 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
         {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
     if (IR[31:26] == 6'b0 & (IR != 32'b0))
        case (IR[5:0])
        //R TYPES
        
        // R[rd] = R[rt] << shamt
        SLL:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h0C;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = R[rt] >> shamt
        SRL:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h0D;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = R[rt] sra shamt
        SRA:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h0E;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // PC = R[rs]
        JR:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = HI
        MFHI:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_100; FS = 5'h0;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = LO
        MFLO:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_011; FS = 5'h0;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // {HI, LO} = R[rs] * R[rt]
        MULT:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_1_000; FS = 5'h1E;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // LO = R[rs]/R[rt]; HI = R[rs]%R[rt]
        DIV:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_1_000; FS = 5'h1F;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = R[rs] + R[rt]
        ADD:begin       
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h02;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = R[rs] + R[rt]
        ADDU:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h04;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = R[rs] - R[rt]
        SUB:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h03;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = R[rs] - R[rt]
        SUBU:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h05;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = R[rs] & R[rt]
        AND:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h08;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = R[rs] | R[rt]
        OR:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h09;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = R[rs] ^ R[rt]
        XOR:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h0A;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = ~(R[rs] | R[rt]}
        NOR:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h0B;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = (R[rs] < R[rt]) ? 1 :0
        SLT:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h06;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        // R[rd] = (R[rs] < R[rt]) ? 1 :0
        SLTU:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS = 5'h07;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;
        end
        
        BREAK:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = IE; RFD_sel = 3'h0;
        {io_cs, io_rd, io_wr} = 3'b0_0_0;

        end
        
        //IE <- 1
        SETIE:begin
        {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
        {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; new_IE = 1'b1; 
        {io_cs, io_rd, io_wr} = 3'b0_0_0; RFD_sel = 3'h0;
        end
        endcase  
        else
        case (IR[31:26])
        
           // if (R[rs] == R[rt]) PC = PC+4+BranchAddr
           BEQ:begin //branches handled in decode
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // if (R[rs] != R[rt]) PC = PC+4+BranchAddr
           BNE:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // if (R[rs] <= 0) PC = PC+4+BranchAddr
           BLEZ:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // if (R[rs] > 0) PC = PC+4+BranchAddr
           BGTZ:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[rt] = R[rs] + SE(IR[15:0])
           ADDI:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_000; FS = 5'h02;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[rt] = (R[rs] < SE(IR[15:0])) ? 1 : 0
           SLTI:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_000; FS = 5'h06;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[rt] = (R[rs] < SE(IR[15:0])) ? 1 : 0
           SLTIU:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_000; FS = 5'h07;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[rt] = R[rs] & SE(IR[15:0])
           ANDI:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_000; FS = 5'h16;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[rt] = R[rs] | SE(IR[15:0])
           ORI:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_000;  FS = 5'h17;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[rt] = R[rs] ^ SE(IR[15:0])
           XORI:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_000; FS = 5'h19;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[rt] = {SE(IR[15:0]), 16'b0}
           LUI:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_000; FS = 5'h18;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[rt] = M[R[rs] + SE(IR[15:0])]
           LW:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_000; FS = 5'h02;
           {dm_cs, dm_rd, dm_wr} = 3'b1_1_0; m2r = 2'b01; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // M[R[rs] + SE(IR[15:0])] = R[rt]
           SW:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_01_1_0_000; FS = 5'h02;
           {dm_cs, dm_rd, dm_wr} = 3'b1_0_1; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // PC = JumpAddr
           J:begin //handled in decode
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0;  RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[31] = PC + 8; PC = JumpAddr
           JAL:begin //jump handled in decode, r31 <- pc
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_10_0_0_010; FS = 5'h0;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h3;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           // R[rt] = ioM[R[rs] + SE(IR[15:0])]
           INPUT:begin 
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_000; FS = 5'h02;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b10; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b1_1_0; new_IE = IE;          
           end
           
           // ioM[R[rs] + SE(IR[15:0])] = R[rt]
           OUTPUT:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_01_1_0_000; FS = 5'h02;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b1_0_1; new_IE = IE;
           end
           
           RETI:begin
           {D_en, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
           {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; m2r = 2'b0; RFD_sel = 3'h0;
           {io_cs, io_rd, io_wr} = 3'b0_0_0; new_IE = IE;
           end
           
           endcase
        
    end
endmodule

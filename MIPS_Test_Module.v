`timescale 1ns / 1ps
/*********************************************************
 * File Name: MIPS_Test_Module.v
 * Project: MIPS ISA Processor - Senior Project
 * Designer: Steven Sallack & Michael Diep
 * Email: Steven.Sallack@gmail.com // michaelkhangdiep@gmail.com
 * Rev. Date: 4/23/2018
 *
 * Purpose: This test fixture instantiates the MIPS CPU,
 *          data memory, and IO module to exercise the 
 *          the CPU and it's ability to interface with both memories.
 *          
 *          The test fixture begins by initalizing memory arrays in 
 *          the Instruction Memory and the Data Memory.
 *          After, all we need to do is assert reset, then let the CPU
 *          begin executing instructions. Once our MCU fetches a BREAK
 *          instruction, it will automatically output the contents of the register
 *          file, data memory, and IO memory.
 *
 * Notes: Rev. 3/21/18  - updated header and adjusted comments
 *        Rev. 4/12/18  - implemented memory module 1,2
 *                        added instructions: BEQ, BNE, ADDI, SRL, J
 *        Rev. 4/13/18  - implemented memory module 3, 4, 5, 6, 7
 *                        added instructions: SRA, SLL, SLT, SLTI, LW, JAL, JR
 *        Rev. 4/14/18  - implemented memory module 8
 *                        added instructions: MULT, MFLO, MFHI
 *        Rev. 4/15/18  - implemented memory module 9
 *                        added instructions: XOR, AND, OR, NOR, SLTU, SLT
 *        Rev. 4/16/18  - implemented memory module 10, 11
 *                        added instructions: DIV, XORI, ANDI, STLIU
 *        Rev. 4/17/18  - implemented memory module 12, 13
 *                        added instructions: BLEZ, BGTZ, SETIE, INPUT, OUTPUT
 *                        added interrupt capability
 *        Rev. 4/23/18  - updated header and adjusted comments
 *********************************************************/
module MIPS_Test_Module;

	// Inputs
	reg clk;
	reg rst;
   
   wire [31:0] D_out, IO_IN, ALU_OUT, RTOUT;
   wire [49:0] EX_MEM; 
   wire [2:0] EX_MEM_IO_SEL;
   wire inta, intr;
   
   integer i;   
	// Instantiate the Units Under Test

	MIPS_top MIPS (
		.clk(clk), 
		.rst(rst),
      .intr(intr),
      .D_out(D_out),
      .IO_IN(IO_IN),
      .inta(inta),
      .EX_MEM(EX_MEM),
      .RTOUT(RTOUT),
      .ALU_OUT(ALU_OUT),
      .EX_MEM_IO_SEL(EX_MEM_IO_SEL)
	);
   
   Data_Memory dMEM (
		.clk(clk), 
		.rst(rst), 
		.dm_cs(EX_MEM[13]), 
		.dm_wr(EX_MEM[15]), 
		.dm_rd(EX_MEM[14]), 
		.addr(ALU_OUT[11:0]), 
		.D_in(RTOUT), 
		.D_out(D_out)
	);
   
   IO_Module   IO (
      .clk(clk),
      .rst(rst),
      .io_cs(EX_MEM_IO_SEL[2]),
      .io_wr(EX_MEM_IO_SEL[1]),
      .io_rd(EX_MEM_IO_SEL[0]),
      .addr(ALU_OUT[11:0]),
      .din(RTOUT),
      .dout(IO_IN),
      .inta(inta),
      .intr(intr)
      );

   always #5 clk = ~clk;
   
   always #5 if (MIPS.Break) Sim_Log;
   
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;

		// Wait 100 ns for global reset to finish
		#100 rst = 0;
      $timeformat(-9, 1, " ns", 9);
      
      ///////UNCOMMENT THE DESIRED MEMORY DATA FOR TESTING//////////
      
      //REMEMBER TO UNCOMMENT THE TWO LINES IN Sim_Log TASK FOR M13/
      
      $readmemh("iMem01_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem02_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem03_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem04_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem05_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem06_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem07_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem08_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem09_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem10_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem11_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem12_Sp18.dat", MIPS.IU.IM.mem_array);      
//      $readmemh("iMem13_Sp18_w_isr.dat", MIPS.IU.IM.mem_array); 



      $readmemh("dMem01_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem02_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem03_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem04_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem05_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem06_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem07_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem08_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem09_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem10_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem11_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem12_Sp18.dat", dMEM.mem_array); 
//      $readmemh("dMem13_Sp18.dat", dMEM.mem_array); 

         
     end //initial

task Dump_Registers; //Dumps Register File's $r0 -> $r31
   for (i = 0; i < 16; i = i + 1)
     $display("Time=%t -- Register $r%0d = %h || Time=%t -- Register $r%0d = %h ",
          $time, i, MIPS.IDP.rf.array[i], $time, i+16, MIPS.IDP.rf.array[i+16]);
endtask

reg [11:0] mem_loc;

task Dump_Mem;
for (mem_loc = 12'h0C0; mem_loc <= 12'h0FF; mem_loc = mem_loc + 12'h4) 
   //output Memory contents at location 0x3F0  
   $display("Time=%t  dM[%h]=%h", $time, mem_loc,
            {dMEM.mem_array[mem_loc + 12'h0],
            dMEM.mem_array[mem_loc + 12'h1],
            dMEM.mem_array[mem_loc + 12'h2],
            dMEM.mem_array[mem_loc + 12'h3]});
endtask

reg [11:0] iomem_loc;

task Dump_IO;
for (iomem_loc = 12'h0C0; iomem_loc <= 12'h0FF; iomem_loc = iomem_loc + 12'h4) 
   //output IO Memory contents at location 0xC0 - 0xFF  
   $display("Time=%t  ioM[%h]=%h", $time, iomem_loc,
         {IO.IOMEM.mem_array[iomem_loc + 12'h0],
         IO.IOMEM.mem_array[iomem_loc + 12'h1],
         IO.IOMEM.mem_array[iomem_loc + 12'h2],
         IO.IOMEM.mem_array[iomem_loc + 12'h3]});

endtask

task Sim_Log;
  begin
  $display(" R E G I S T E R  F I L E  A F T E R  B R E A K \n");
  Dump_Registers;
  $display("\n D A T A  M E M O R Y  L O C A T I O N S  0 x C 0  to  0 x F F \n");
  Dump_Mem;
  $display("\n I S R  L O C A T I O N  I N  D A T A  M E M O R Y  [ 0 x 3 F C ]\n");
  $display("Time = %t   dM[3FC]=%h", $time, 
                              {dMEM.mem_array[12'h3FC],
                              dMEM.mem_array[12'h3FD],
                              dMEM.mem_array[12'h3FE],
                              dMEM.mem_array[12'h3FF]});
//UNCOMMENT THE TWO FOLLOWING LINES FOR MODULE 13
  $display("\n I / O  M E M O R Y  L O C A T I O N S  0 x C 0  to  0 x F F \n");
  Dump_IO; 
  $stop;
  end
endtask
endmodule


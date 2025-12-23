`define A1 0
`define A2 1
`define A3 2
`define M1 3
`define M2 4
`define X1 5
`define X2 6
`define X3 7



//-------------------
// Condition for DAA
//-------------------
// Input   |Output
// ACC  CY |ACC  CY
// --------+---------
// 0-9  0  |0-9  0 (No Carry, CY unchanged)
// 0-9  1  |6-F  1 (No Carry, CY unchanged)
// A-F  0  |0-5  1 (Carry, CY changed)
// A-F  1  |0-5  1 (Carry, CY changed)









// NOP : No Operation
`define NOP 8'b0000_0000
// JCN : Jump Conditional
`define JCN 8'b0001_????
// FIM : Fetch Immediate from ROM
`define FIM 8'b0010_???0
// SRC : Send Register Control
`define SRC 8'b0010_???1
// FIN : Fetch Indirect from ROM
`define FIN 8'b0011_???0
// JIN : Jump Indirect
`define JIN 8'b0011_???1
// JUN : Jump Unconditional
`define JUN 8'b0100_????
// JMS : Jump to Subroutine
`define JMS 8'b0101_????
// INC : Increment Index Register
`define INC 8'b0110_????
// ISZ : Increment Index Register, Skip if Zero
`define ISZ 8'b0111_????
// ADD : Add Index Register to ACC
`define ADD 8'b1000_????
// SUB : Subtract Index Register from ACC
`define SUB 8'b1001_????
// LD : Load Index Register to ACC
`define LD 8'b1010_????
 // XCH : Exchange Load Index Register and ACC
 `define XCH 8'b1011_????
 // BBL : Branch Back and Load to ACC
 `define BBL 8'b1100_????
 // LDM : Load Imm4 to ACC
 `define LDM 8'b1101_????
 //--------------------------------------
 // WRM : Write RAM_CH from ACC             8'b1110_0000
 // WMP : Write RAM Output Port from ACC    8'b1110_0001
 // WRR : Write ROM Output Port from ACC    8'b1110_0010
 // WPM : Write R/W Program Memory from ACC 8'b1110_0011
 // WR0 : Write RAM Status 0 from ACC       8'b1110_0100
 // WR1 : Write RAM Status 1 from ACC       8'b1110_0101
 // WR2 : Write RAM Status 2 from ACC       8'b1110_0110
 // WR3 : Write RAM Status 3 from ACC       8'b1110_0111
  `define WR_ 8'b1110_0???
 //--------------------------------------
 // RDM : Read RAM_CH to ACC         8'b1110_1001
 // RDR : Read ROM Input Port to ACC 8'b1110_1010
 // RD0 : Read RAM Status 0 into ACC 8'b1110_1100
 // RD1 : Read RAM Status 1 into ACC 8'b1110_1101
 // RD2 : Read RAM Status 2 into ACC 8'b1110_1110
 // RD3 : Read RAM Status 3 into ACC 8'b1110_1111
`define RD_  8'b1110_1001,8'b1110_1010,8'b1110_11??
 //--------------------------------------
 // SBM : Subtract RAM_CH from ACC
 `define SBM  8'b1110_1000
 //--------------------------------------
 // ADM : Add RAM_CH to ACC
  `define ADM 8'b1110_1011
 //--------------------------------------
 // CLB : Clear Both ACC and CY
 `define CLB 8'b1111_0000
 //--------------------------------------
 // CLC : Clear CY
 `define CLC 8'b1111_0001
 //--------------------------------------
 // IAC : Increment ACC
 `define IAC 8'b1111_0010
 //--------------------------------------
 // CMC : Complement CY
 `define CMC 8'b1111_0011
 //--------------------------------------
 // CMA : Complement ACC
 `define CMA 8'b1111_0100
 //--------------------------------------
 // RAL : Rotate Left ACC and CY
 `define RAL 8'b1111_0101
 //--------------------------------------
 // RAR : Rotate Right ACC and CY
 `define RAR 8'b1111_0110
 //--------------------------------------
 // TCC : Transmit CY to ACC and Clear CY
 `define TCC 8'b1111_0111
 //--------------------------------------
 // DAC : Decrement ACC
 `define DAC 8'b1111_1000
 //--------------------------------------
 // TCS : Transfer CY Subtract and Clear CY
 `define TCS 8'b1111_1001
 //--------------------------------------
 // STC : Set CY
 `define STC 8'b1111_1010
 //--------------------------------------
 // DAA : Decimal Adjust ACC
 `define DAA 8'b1111_1011
 //--------------------------------------
 // KBP : Keyboard Process
 `define KBP 8'b1111_1100
 //--------------------------------------
 // DCL : Designate Control Line
 `define DCL 8'b1111_1101

//===========================================================
// MCS-4 Project
//-----------------------------------------------------------
// File Name   : mcs4_rom.v
// Description : MCS-4 ROM Chip (i4001 x 16chips)
//-----------------------------------------------------------
// History :
// Rev.01 2025.05.19 M.Maruyama First Release
//-----------------------------------------------------------
// Copyright (C) 2025 M.Maruyama
//===========================================================

//---------------
// State Number
//---------------
`define A1 0
`define A2 1
`define A3 2
`define M1 3
`define M2 4
`define X1 5
`define X2 6
`define X3 7

//----------------------------------------------------------------------------------
// Assumed Configuration of Metal Option of i4001
//----------------------------------------------------------------------------------
// [1=Y] Port Output is Enabled
// [2=N] Port Input is not inverted, and not pulled up/down.
// [3=Y] Port Output is connected to Positive Q of Output F/F.
// [4=N] Port Output is not connected to Negative Q of Output F/F.
// [5=Y] Port Input is connected to Mux directly.
// [6=N] Port Input is not inverted.
// [7=N] Port Input is not pulled up/down.
// [8=N] Port Input is not connted to Mux directry with pulled up/down.
// [9=N] Port Input is nort pulled down.
// [10=N] Port Input is not pulled up.
//----------------------------------------------------------------------------------
// Note : Both Port Input and Output are enabled, that is different from real chip.
//----------------------------------------------------------------------------------

//---------------------------------
// MCS-4 ROM Chip i4001
//---------------------------------
module MCS4_ROM
(
    input  wire        CLK,     // Clock
    input  wire        RES_N,   // Reset
    //
    input  wire        SYNC_N,  // Sync Signal
    input  wire [ 3:0] DATA_I,  // Data Input
    output wire [ 3:0] DATA_O,  // Data Output
    output wire        DATA_OE, // Data Output Enable
    input  wire        CM_N,    // Memory Control
    input  wire        ROM_INIT_ENB,   // Initialization Mode of MCS4 ROM
    input  wire [11:0] ROM_INIT_ADDR,  // ROM Address during ROM_INIT_ENB
    input  wire        ROM_INIT_RE,    // Read ROM during ROM_INIT_ENB
    input  wire        ROM_INIT_WE,    // Write ROM during ROM_INIT_ENB
    input  wire [ 7:0] ROM_INIT_WDATA, // Write Data to ROM during ROM_INIT_ENB
    output wire [ 7:0] ROM_INIT_RDATA  // Read Data from ROM during ROM_INIT_ENB
);

//-----------------------------
// ROM MAT : 16chips x 256bytes
//-----------------------------
reg [7:0] rom[0:4095];
//
initial
begin
    $readmemh("/home/echoro/Documents/Courses/Senior/First_term/design_experiment/4004/FPGA/src/testbench/software/program1/4001_generate.mem", rom);
end

//---------------------------------
// Synchronization and State Count
//---------------------------------
reg [7:0] state;
//
always @(posedge CLK, negedge RES_N)
begin
    if (~RES_N)
        state <= 8'b00000000;
    else if (~SYNC_N)
        state <= 8'b00000001;
    else if (SYNC_N & state[`X3]) // if no sync at X3,
        state <= 8'b00000000;     // it must be stop state
    else
        state <= {state[6:0], state[7]}; // rotate left
end

//---------------------
// ROM Access from CPU
//---------------------
reg  [ 7:0] rom_addr_lsb;
wire [11:0] rom_addr;
wire        rom_re;
wire        rom_we;
reg  [ 7:0] rom_rdata;
wire [ 3:0] data_o_rom;
wire        data_o_rom_oe;

assign DATA_OE = data_o_rom_oe;
assign DATA_O  = data_o_rom;
//
always @(posedge CLK, negedge RES_N)
begin
    if (~RES_N)
        rom_addr_lsb <= 8'h00;
    else if (state[`A1])
        rom_addr_lsb[ 3:0] <= DATA_I;
    else if (state[`A2])
        rom_addr_lsb[ 7:4] <= DATA_I;
end
//
assign rom_addr = (ROM_INIT_ENB)? ROM_INIT_ADDR
                                : ((state[`A3] & (CM_N == 1'b0))? {DATA_I, rom_addr_lsb} : 12'h000);
assign rom_re   = (ROM_INIT_ENB)? ROM_INIT_RE
                                : state[`A3] & (CM_N == 1'b0);
assign rom_we   = (ROM_INIT_ENB)? ROM_INIT_WE : 1'b0;
//
always @(posedge CLK)
begin
    if (rom_re) rom_rdata <= rom[rom_addr];
    if (rom_we) rom[rom_addr] <= ROM_INIT_WDATA;
end
//
assign data_o_rom = (state[`M1])? rom_rdata[7:4]
                  : (state[`M2])? rom_rdata[3:0]
                  : 4'b0000;
assign data_o_rom_oe = state[`M1] | state[`M2];
//
assign ROM_INIT_RDATA = rom_rdata;





//===========================================================
endmodule
//===========================================================

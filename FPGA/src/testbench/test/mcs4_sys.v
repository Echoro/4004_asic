//===========================================================
// MCS-4 Project
//-----------------------------------------------------------
// File Name   : mcs4_sys.v
// Description : MCS-4 System (i4001 + i4002 + i4003 + 141-PF)
//-----------------------------------------------------------
// History :
// Rev.01 2025.05.25 M.Maruyama First Release
//-----------------------------------------------------------
// Copyright (C) 2025 M.Maruyama
//===========================================================
// This system includes followings.
// (1) MCS-4 Memory System: mcs4_mem.v
//       MCS-4 ROM Chip: mcs4_rom.v  (i4001 x 16chips)
//       MCS-4 RAM Chip: mcs4_ram.v (i4002 x 8banks x 4chips)
// (2) Busicom Caluculator 141-PF Model
//       MCS-4 Shift Register Chip: mcs4_shifter (i4003 x 3chips)
//
// Interface
// (1) CPU (i4004)
//    input  wire        CLK,      // clock
//    input  wire        RES_N,    // reset_n
//    //
//    input  wire        SYNC_N,   // Sync Signal
//    inout  wire [ 3:0] DATA,     // Data Input/Output
//    input  wire        CM_ROM_N, // Memory Control for ROM
//    input  wire [ 3:0] CM_RAM_N, // Memory Control for RAM
//    output wire        TEST      // Test Signal
//
// (2) Calculator Command : Host MCU (UI) --> MCS4_SYS
//     input  wire [31:0] PORT_KEYPRT_CMD
//         bit31   : Enable KEYPRT
//         bit15   : Printer FIFO POP Request
//         bit14   : Paper Feed Request
//         bit13-12: Rounding Switch
//         bit11-08: Decimal Point Switch
//         bit07-00: Key Code
//
// (3) Calculator Response : MCS4_SYS --> Host MCU (UI)
//     output wire [31:0] PORT_KEYPRT_RES
//         bit31   : Printer FIFO Data Ready
//         bit30-16: Printer Column_01_15
//         bit15-14: Printer Column_17_18
//         bit13-10: Printer Drum Count
//         bit09   : Printer Red Ribbon
//         bit08   : Printer Paper Feed
//         bit07   : Minus Sign Lamp
//         bit06   : Overflow Lamp
//         bit05   : Memory Lamp
//         bit04-01: unused
//         bit00   : Printer FIFO_POP Acknowledge

//---------------------------------------------
// MCS-4 System ROM + RAM + Key&Printer I/F
//---------------------------------------------
module MCS4_SYS (

        // CPU Interface (i4004)
        input  wire        CLK,             // clock
        input  wire        RES_N,           // reset_n
        // Initialization of ROM
        input  wire        ROM_INIT_ENB,    // Initialization Mode of MCS4 ROM
        input  wire [11:0] ROM_INIT_ADDR,   // ROM Address during ROM_INIT_ENB
        input  wire        ROM_INIT_RE,     // Read ROM during ROM_INIT_ENB
        input  wire        ROM_INIT_WE,     // Write ROM during ROM_INIT_ENB
        input  wire [ 7:0] ROM_INIT_WDATA,  // Write Data to ROM during ROM_INIT_ENB
        output wire [ 7:0] ROM_INIT_RDATA   // Read Data from ROM during ROM_INIT_ENB
    );
    wire        SYNC_N;                     // Sync Signal
    wire [ 3:0] DATA_O_peripheral;          // Data Output
    wire        DATA_OE_peripheral;         // Data Output Enable
    wire [ 3:0] DATA_O_cpu;                 // Data Output
    wire        DATA_OE_cpu;                // Data Output Enable
    wire        CM_ROM_N;                   // Memory Control for ROM
    wire [ 3:0] CM_RAM_N;                   // Memory Control for RAM
    wire        TEST;                       // Test Input
    assign TEST = 1'b1;
    wire [ 3:0] DATA;
    wire [3:0] data_drive_low;

    assign data_drive_low =
        (DATA_OE_cpu        ? ~DATA_O_cpu        : 4'b0000)
        | (DATA_OE_peripheral ? ~DATA_O_peripheral : 4'b0000);

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin
            pullup(DATA[i]);
            assign DATA[i] = data_drive_low[i] ? 1'b0 : 1'bz;
        end
    endgenerate
    // pullup(DATA[0]);
    // pullup(DATA[1]);
    // pullup(DATA[2]);
    // pullup(DATA[3]);
    // assign DATA[0]     = (DATA_OE_peripheral & ~DATA_O_peripheral[0])? 1'b0 : 1'bz;
    // assign DATA[1]     = (DATA_OE_peripheral & ~DATA_O_peripheral[1])? 1'b0 : 1'bz;
    // assign DATA[2]     = (DATA_OE_peripheral & ~DATA_O_peripheral[2])? 1'b0 : 1'bz;
    // assign DATA[3]     = (DATA_OE_peripheral & ~DATA_O_peripheral[3])? 1'b0 : 1'bz;

    // assign DATA[0]  = (DATA_OE_cpu & ~DATA_O_cpu[0])?1'b0 : 1'bz; // open drain
    // assign DATA[1]  = (DATA_OE_cpu & ~DATA_O_cpu[1])?1'b0 : 1'bz; // open drain
    // assign DATA[2]  = (DATA_OE_cpu & ~DATA_O_cpu[2])?1'b0 : 1'bz; // open drain
    // assign DATA[3]  = (DATA_OE_cpu & ~DATA_O_cpu[3])?1'b0 : 1'bz; // open drain

    //---------------------
    // Data Interface
    //---------------------
    wire [3:0]  data_o_rom;
    wire        data_o_rom_oe;
    wire [3:0]  data_o_ram;
    wire        data_o_ram_oe;
    //
    assign DATA_O_peripheral  = (data_o_rom_oe)? data_o_rom
        : (data_o_ram_oe)? data_o_ram
        : 4'b1111;
    assign DATA_OE_peripheral = data_o_rom_oe | data_o_ram_oe;

    top u_top (
        // Inputs
        .clk     (CLK              ),
        .DATA_I  (DATA[3:0]        ),
        .rst_n   (RES_N            ),
        .TEST    (TEST             ),
        // Outputs
        .CM_RAM_N(CM_RAM_N[3:0]    ),
        .CM_ROM_N(CM_ROM_N         ),
        .DATA_O  (DATA_O_cpu[3:0]  ),
        .DATA_OE (DATA_OE_cpu      ),
        .SYNC_N  (SYNC_N           )
    );
    //----------------
    // Decode CM_RAM
    //----------------
    wire [7:0]  cm_ram_n_decoded;
    //
    assign cm_ram_n_decoded
        = (CM_RAM_N == 4'b1110)? 8'b11111110                      // bank0
            : (CM_RAM_N == 4'b1101)? 8'b11111101                  // bank1
            : (CM_RAM_N == 4'b1011)? 8'b11111011                  // bank2
            : (CM_RAM_N == 4'b1001)? 8'b11110111                  // bank3
            : (CM_RAM_N == 4'b0111)? 8'b11101111                  // bank4
            : (CM_RAM_N == 4'b0101)? 8'b11011111                  // bank5
            : (CM_RAM_N == 4'b0011)? 8'b10111111                  // bank6
            : (CM_RAM_N == 4'b0001)? 8'b01111111                  // bank7
            : 8'b11111111;

    //-----------------------------
    // ROM Chips (i4001 x 16chips)
    //-----------------------------
    MCS4_ROM U_MCS4_ROM
    (
        .CLK            (CLK           ),
        .RES_N          (RES_N         ),
        .SYNC_N         (SYNC_N        ),
        .DATA_I         (DATA          ),
        .DATA_O         (data_o_rom    ),
        .DATA_OE        (data_o_rom_oe ),
        .CM_N           (CM_ROM_N      ),
        //
        .ROM_INIT_ENB   (ROM_INIT_ENB  ),
        .ROM_INIT_ADDR  (ROM_INIT_ADDR ),
        .ROM_INIT_RE    (ROM_INIT_RE   ),
        .ROM_INIT_WE    (ROM_INIT_WE   ),
        .ROM_INIT_WDATA (ROM_INIT_WDATA),
        .ROM_INIT_RDATA (ROM_INIT_RDATA)
    );

    //---------------------------------------
    // RAM Chips (i4002 x 8banks x 4chips)
    //---------------------------------------
    MCS4_RAM U_MCS4_RAM
    (
        .CLK     (CLK             ),
        .RES_N   (RES_N           ),
        .SYNC_N  (SYNC_N          ),
        .DATA_I  (DATA            ),
        .DATA_O  (data_o_ram      ),
        .DATA_OE (data_o_ram_oe   ),
        .CM_N    (cm_ram_n_decoded)
    );

endmodule

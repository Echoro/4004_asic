`default_nettype none
`timescale 1ns / 100ps

module tb ();
    reg clk;
    reg res_n;

    always #5 clk = ~clk; // 100MHz
    initial begin
        clk = 1'b0;
        res_n = 1'b0;
        #20;
        res_n = 1'b1;
    end
    initial begin
        #1000000;
        $finish;
    end
MCS4_SYS U_MCS4_SYS
(
    // CPU Interfface (i4004)
    .CLK   (clk),  // clock
    .RES_N (res_n), // reset_n
    // Initialization of ROM
    .ROM_INIT_ENB   (1'b0),    // Initialization Mode of MCS4 ROM
    .ROM_INIT_ADDR  (12'h000), // ROM Address during ROM_INIT_ENB
    .ROM_INIT_RE    (1'b0),    // Read ROM during ROM_INIT_ENB
    .ROM_INIT_WE    (1'b0),    // Write ROM during ROM_INIT_ENB
    .ROM_INIT_WDATA (8'h00),   // Write Data to ROM during ROM_INIT_ENB
    .ROM_INIT_RDATA ()         // Read Data from ROM during ROM_INIT_ENB
);
// initial begin
//     $fsdbDumpfile("wave/verdi/rtl.fsdb");
//     $fsdbDumpvars(0, tb);
// end
endmodule

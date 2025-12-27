`timescale 1ns/1ps

module regFiles (
        input  wire             CLK,
        input  wire             RES_N,
        input  wire             M1,
        input  wire             M2,
        input  wire             A1,
        input  wire             A2,
        input  wire             A3,
        // outputs
        output wire             rn_zero,
        output wire    [3:0]    rn     ,
        output wire    [7:0]    rp     ,
        output wire    [3:0]    data_o_rom_addr,
        // inputs from top
        input  wire    [3:0]    DATA_I,
        input  wire    [11:0]   pc_plus_one,
        input  wire    [11:0]   pc,
        // input from ALU
        input  wire    [4:0]    alu,
        input  wire    [3:0]    acc,
        // input from decoder
        input  wire    [7:0]    opropa0,        // for index calculation
        input  wire    [7:0]    opropa1,        // for index calculations
        input  wire             do_fin,
        input  wire             rp_fim,
        input  wire             rn_alu,
        input  wire             rn_acc
    );

    //-------------------------------
    // Index Registers
    //-------------------------------
    reg     [ 3:0] reg_files [0:15];
    wire    [3:0]  rp0;
    wire    [3:0]  rp1;

    wire    [3:0]  rn_index;
    wire    [3:0]  rn_index0;
    wire    [3:0]  rn_index1;

    assign data_o_rom_addr = (A1 & do_fin)? reg_files[1] // Lower Bits
        : (A2 & do_fin)? reg_files[0]                    // Middle Bits
        : (A3 & do_fin)? pc_plus_one[11:8]
        : (A1)? pc[ 3:0]
        : (A2)? pc[ 7:4]
        : (A3)? pc[11:8]
        : 4'b0000;
    assign rn_index  = opropa0[3:0];
    assign rn_index0 = opropa0[3:0] & 4'b1110;
    assign rn_index1 = opropa0[3:0] | 4'b0001;

    assign rn  = reg_files[rn_index];
    assign rp0 = reg_files[rn_index0];
    assign rp1 = reg_files[rn_index1];
    assign rp  = {rp0, rp1};
    assign rn_zero = (rn == 4'b0000);

    integer        i;
    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N)
            for (i = 0; i < 16; i = i + 1) reg_files[i] <= 4'b0000;
        else if (rp_fim) begin
            reg_files[rn_index0] <= opropa1[7:4];
            reg_files[rn_index1] <= opropa1[3:0];
        end else if (do_fin & M1)
            reg_files[rn_index0] <= DATA_I;
        else if (do_fin & M2)
            reg_files[rn_index1] <= DATA_I;
        else if (rn_alu)
            reg_files[rn_index]  <= alu[3:0];
        else if (rn_acc)
            reg_files[rn_index]  <= acc;
    end
    `ifdef FPGA
    ila_0 ila_reg (
	.clk(CLK), // input wire clk


	.probe0(reg_files[0]), // input wire [3:0]  probe0
	.probe1(reg_files[1]), // input wire [3:0]  probe1
	.probe2(reg_files[2]), // input wire [3:0]  probe2
	.probe3(reg_files[3]), // input wire [3:0]  probe3
	.probe4(reg_files[4]), // input wire [3:0]  probe4
	.probe5(reg_files[5]), // input wire [3:0]  probe5
	.probe6(reg_files[6]), // input wire [3:0]  probe6
	.probe7(reg_files[7]), // input wire [3:0]  probe7
	.probe8(DATA_I)        // input wire [3:0]  probe8
);


    `endif

endmodule

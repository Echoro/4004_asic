`timescale 1ns/1ps
`default_nettype none
// ALU module and Carry logic for MCS-4 CPU
module ALU (
        input  wire         CLK,
        input  wire         RES_N,
        // inputs selectors
        // from top
        input  wire  [3:0]  DATA_I,
        //input from regfile
        input  wire  [3:0]  rn,
        // input from decoder
        input  wire  [7:0]  opropa0,

        input  wire         acc_alu,
        input  wire         acc_kbp,
        input  wire         cy_set,
        input  wire         cy_inv,
        input  wire         cy_wrt,

        input  wire         alu_a_acc,
        input  wire         alu_a_rn,
        input  wire         alu_a_opropa,
        input  wire         alu_b_acc,
        input  wire         alu_b_rn,
        input  wire         alu_b_data_i,
        input  wire         alu_c_cy,
        input  wire         alu_c_set,
        input  wire         alu_thru_a,
        input  wire         alu_thru_b,
        input  wire         alu_add,
        input  wire         alu_sub,
        input  wire         alu_ral,
        input  wire         alu_rar,
        input  wire         alu_daa,
        // outputs
        output reg   [3:0]  acc,
        output reg          cy,
        output reg   [4:0]  alu,
        output wire         cy_next
    );

    //-------------------------------
    // ACC : Accumulator
    //-------------------------------

    reg  [3:0]  kbp;

    always @* begin
        casez (acc)
            4'b0000 : kbp = 4'b0000;
            4'b0001 : kbp = 4'b0001;
            4'b0010 : kbp = 4'b0010;
            4'b0100 : kbp = 4'b0011;
            4'b1000 : kbp = 4'b0100;
            default : kbp = 4'b1111;
        endcase
    end

    reg  [3:0]  alu_a;
    reg  [3:0]  alu_b;
    reg         alu_c;

    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N)
            acc <= 4'b0000;
        else if (acc_alu)
            acc <= alu[3:0];
        else if (acc_kbp)
            acc <= kbp;
    end

    assign cy_next = alu[4];
    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N)
            cy <= 1'b0;
        else if (cy_set)
            cy <= 1'b1;
        else if (cy_inv)
            cy <= ~cy;
        else if (cy_wrt)
            cy <= cy_next;
    end

    // alu operations (combinational): follow original priority
    always @* begin
        casez({alu_thru_a, alu_thru_b, alu_add, alu_sub, alu_ral, alu_rar, alu_daa})
            7'b1?????? : alu = {1'b0, alu_a};
            7'b?1????? : alu = {1'b0, alu_b};
            7'b??1???? : alu = {1'b0, alu_a} + {1'b0,  alu_b} + {4'b0000,  alu_c};
            7'b???1??? : alu = {1'b0, alu_a} + {1'b0, ~alu_b} + {4'b0000, ~alu_c};
            7'b????1?? : alu = {alu_a[3], alu_a[2:0], cy};
            7'b?????1? : alu = {alu_a[0], cy, alu_a[3:1]};
            7'b??????1 : alu = {1'b0, alu_a} + 5'b00110;
            default    : alu = 5'b0_0000;
        endcase
    end

    always @* begin
        casez({alu_a_acc, alu_a_rn, alu_a_opropa})
            3'b1??  : alu_a = acc;
            3'b?1?  : alu_a = rn;
            3'b??1  : alu_a = opropa0[3:0];
            default : alu_a = 4'b0000;
        endcase
    end

    always @* begin
        casez({alu_b_acc, alu_b_rn, alu_b_data_i})
            3'b1??  : alu_b = acc;
            3'b?1?  : alu_b = rn;
            3'b??1  : alu_b = DATA_I;
            default : alu_b = 4'b0000;
        endcase
    end

    always @* begin
        casez({alu_c_cy, alu_c_set})
            2'b1?   : alu_c = cy;
            2'b?1   : alu_c = 1'b1;
            default : alu_c = 1'b0;
        endcase
    end
endmodule

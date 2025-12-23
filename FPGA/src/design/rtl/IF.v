`timescale 1ns/1ps

module IF (
        input    wire             CLK,
        input    wire             RES_N,
        // outputs
        output   wire    [11:0]   pc_plus_one,
        output   wire    [11:0]   pc,
        // inputs from top
        // input from ALU

        // input from regFiles
        input    wire    [7:0]    rp,
        // input from decoder
        input    wire    [7:0]    opropa1,
        input    wire    [7:0]    opropa0,
        input    wire             pc_inc,
        input    wire             pc_set,
        input    wire             pc_push,
        input    wire             pc_pop,
        input    wire             pc_target_jin,
        input    wire             pc_target_jun,
        input    wire             pc_target_jcn
    );

    //----------------------------
    // Program Counter and Stack
    //----------------------------
    reg  [11:0] stack           [0:3];
    reg  [ 1:0] sp;
    wire [11:0] pc_next;              // Next PC

    assign pc = stack[sp];
    assign pc_plus_one = pc + 12'h001;

    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N) begin
            stack[0]  <= 12'h000;
            stack[1]  <= 12'h000;
            stack[2]  <= 12'h000;
            stack[3]  <= 12'h000;
        end else if (pc_inc | pc_set)
            stack[sp] <= pc_next; // PC
    end

    assign pc_next = (pc_inc       )?  pc_plus_one
        : (pc_target_jcn)? {pc_plus_one[11:8], opropa1[7:0]}
        : (pc_target_jun)? {opropa0[3:0]     , opropa1[7:0]}
        : (pc_target_jin)? {pc_plus_one[11:8], rp}
        : pc;

    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N)
            sp <= 2'b00;
        else if (pc_push)
            sp <= sp + 2'b01;
        else if (pc_pop)
            sp <= sp + 2'b11; // minus one
    end

endmodule

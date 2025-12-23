`timescale 1ns/1ps
`default_nettype none

module gen_phase (
        input  wire        CLK,
        input  wire        RES_N,
        // outputs
        output wire        A1,
        output wire        A2,
        output wire        A3,
        output wire        M1,
        output wire        M2,
        output wire        X1,
        output wire        X2,
        output wire        X3,
        output wire        SYNC_N
    );
    reg  [7:0] state;
    reg  [7:0] state_next;
    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N)
            state <= 8'b00000000;
        else
            state <= state_next;
    end
    //
    always @* begin
        casez(state)
            8'b00000000 : state_next = 8'b00000001;
            8'b10000000 : state_next = 8'b00000001;
            default     : state_next = {state[6:0], state[7]}; // rotate left
        endcase
    end
assign SYNC_N = ~state_next[`A1];
    assign A1 = state[`A1];
    assign A2 = state[`A2];
    assign A3 = state[`A3];
    assign M1 = state[`M1];
    assign M2 = state[`M2];
    assign X1 = state[`X1];
    assign X2 = state[`X2];
    assign X3 = state[`X3];

endmodule

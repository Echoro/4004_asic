`timescale 1ns/1ps
`default_nettype none

module decoder (
        input  wire              CLK,
        input  wire              RES_N,
        // micro-phase
        input  wire              M1,
        input  wire              M2,
        input  wire              X1,
        input  wire              X2,
        input  wire              X3,
        // multi-cycle / fetch control outputs
        output reg  [7:0]        opropa0,
        output reg  [7:0]        opropa1,
        output reg               do_fin,          // indicates FIN active (for register_file writes)
        // Control outputs (subset example; extend as needed)
        output reg               pc_inc,
        output reg               pc_set,
        output reg               pc_push,
        output reg               pc_pop,
        output reg               rp_fim,          // write rp (FIM)
        output reg               acc_alu,
        output reg               acc_kbp,
        output reg               cy_set,
        output reg               cy_inv,
        output reg               cy_wrt,
        output reg               alu_a_acc,
        output reg               alu_a_rn,
        output reg               alu_a_opropa,
        output reg               alu_b_acc,
        output reg               alu_b_rn,
        output reg               alu_b_data_i,
        output reg               alu_add,
        output reg               alu_sub,
        output reg               alu_ral,
        output reg               alu_rar,
        output reg               alu_daa,
        output reg               dcl_set,
        output reg               src_set,
        output reg               rn_alu ,
        output reg               rn_acc ,
        output reg               alu_c_cy     ,
        output reg               alu_c_set    ,
        output reg               alu_thru_a   ,
        output reg               alu_thru_b   ,
        output reg               cm_rom_at_x2 ,
        output reg               cm_ram_at_x2 ,
        output reg               data_o_src_at_x2 ,
        output reg               data_o_src_at_x3 ,
        output reg               data_o_acc_at_x2 ,
        output reg               pc_target_jcn ,
        output reg               pc_target_jun ,
        output reg               pc_target_jin ,
        // bus IO
        input  wire [3:0]        DATA_I,
        // pc target outputs for pc module
        input  wire              test_sync,
        input  wire              cy,
        input  wire [3:0]        acc,
        input  wire              rn_zero,
        input  wire              cy_next
    );

    wire       c1, c2, c3, c4;
    wire       jcn;
    reg        multi_cycle;
    reg        multi_cycle_inc;
    assign c1 = opropa0[3]; // C1: Invert Jump Condition
    assign c2 = opropa0[2]; // C2: Jump if ACC==0
    assign c3 = opropa0[1]; // C3: Jump if CY==1
    assign c4 = opropa0[0]; // C4: Jump if TEST==0

    assign jcn = c1 ^ (c2 & (acc == 4'b0000) | c3 & cy | c4 & ~test_sync);
    wire       daa;

    assign daa = cy | (acc > 4'b1001);

    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N) begin
            opropa0      <= 8'h00;
            opropa1      <= 8'h00;
        end else if ((M1) & ~multi_cycle & ~do_fin)
            opropa0[7:4] <= DATA_I; // OPR
        else if ((M2) & ~multi_cycle & ~do_fin)
            opropa0[3:0] <= DATA_I; // OPA
        else if ((M1) &  multi_cycle & ~do_fin)
            opropa1[7:4] <= DATA_I; // OPR
        else if ((M2) &  multi_cycle & ~do_fin)
            opropa1[3:0] <= DATA_I; // OPA
    end

    //----------------------------------
    // Control of 2-Cycle Instruction
    //----------------------------------
    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N)
            multi_cycle <= 1'b0;
        else if (multi_cycle_inc)
            multi_cycle <= ~multi_cycle;
    end

    //-------------------------
    // Instruction Control
    //-------------------------
    always @* begin
        // Default Control Signal Level
        rn_alu  = 1'b0;
        rn_acc  = 1'b0;
        alu_c_cy     = 1'b0;
        alu_c_set    = 1'b0;
        alu_thru_a   = 1'b0;
        alu_thru_b   = 1'b0;
        cm_rom_at_x2 = 1'b0;
        cm_ram_at_x2 = 1'b0;
        data_o_src_at_x2 = 1'b0;
        data_o_src_at_x3 = 1'b0;
        data_o_acc_at_x2 = 1'b0;
        pc_target_jcn = 1'b0;
        pc_target_jun = 1'b0;
        pc_target_jin = 1'b0;
        pc_inc  = 1'b0;
        pc_set  = 1'b0;
        pc_push = 1'b0;
        pc_pop  = 1'b0;
        multi_cycle_inc = 1'b0;
        dcl_set = 1'b0;
        src_set = 1'b0;
        rp_fim  = 1'b0;
        acc_alu = 1'b0;
        acc_kbp = 1'b0;
        alu_a_acc    = 1'b0;
        alu_a_rn     = 1'b0;
        alu_a_opropa = 1'b0;
        alu_b_acc    = 1'b0;
        alu_b_rn     = 1'b0;
        alu_b_data_i = 1'b0;
        alu_add      = 1'b0;
        alu_sub      = 1'b0;
        alu_ral      = 1'b0;
        alu_rar      = 1'b0;
        alu_daa      = 1'b0;
        cy_set = 1'b0;
        cy_inv = 1'b0;
        cy_wrt = 1'b0;

        do_fin = 1'b0;
        // Set Contol Signals for each Instruction Sequence
        casez(opropa0)
            //--------------------------------------
            // NOP : No Operation
            `NOP : begin
                pc_inc  = X3;
            end
            //--------------------------------------
            // JCN : Jump Conditional
            `JCN : begin
                if (~multi_cycle | ~jcn) begin
                    pc_inc = X3;
                end else begin //  if (multi_cycle & jcn)
                    pc_target_jcn = X3;
                    pc_set        = X3;
                end
                //
                multi_cycle_inc = X3;
            end
            //--------------------------------------
            // FIM : Fetch Immediate from ROM
            `FIM : begin
                if (~multi_cycle) begin
                    // do nothing
                end else begin
                    rp_fim = X3;
                end
                //
                multi_cycle_inc = X3;
                pc_inc  = X3;
            end
            //--------------------------------------
            // SRC : Send Register Control
            `SRC : begin
                src_set          = X1;
                cm_rom_at_x2     = X2;
                cm_ram_at_x2     = X2;
                data_o_src_at_x2 = X2;
                data_o_src_at_x3 = X3;
                pc_inc           = X3;
            end
            //--------------------------------------
            // FIN : Fetch Indirect from ROM
            `FIN : begin
                if (~multi_cycle) begin
                    // do nothing
                end else begin
                    do_fin = 1'b1;
                end
                //
                multi_cycle_inc = X3;
                pc_inc  = X3 & multi_cycle;
            end
            //--------------------------------------
            // JIN : Jump Indirect
            `JIN : begin
                pc_target_jin = X3;
                pc_set        = X3;
            end
            //--------------------------------------
            // JUN : Jump Unconditional
            `JUN : begin
                if (~multi_cycle) begin
                    pc_inc = X3;
                end else begin // if (multi_cycle)
                    pc_target_jun = X3;
                    pc_set        = X3;
                end
                //
                multi_cycle_inc = X3;
            end
            //--------------------------------------
            // JMS : Jump to Subroutine
            `JMS : begin
                if (~multi_cycle) begin
                    pc_inc = X3;
                end else begin // if (multi_cycle)
                    pc_inc        = X2;
                    pc_push       = X2;
                    //
                    pc_target_jun = X3;
                    pc_set        = X3;
                end
                //
                multi_cycle_inc = X3;
            end
            //--------------------------------------
            // INC : Increment Index Register
            `INC : begin
                alu_a_rn  = X3;
                alu_c_set = X3;
                alu_add   = X3;
                rn_alu    = X3;
                pc_inc    = X3;
            end
            //--------------------------------------
            // ISZ : Increment Index Register, Skip if Zero
            `ISZ : begin
                if (~multi_cycle) begin
                    alu_a_rn  = X3;
                    alu_c_set = X3;
                    alu_add   = X3;
                    rn_alu    = X3;
                    pc_inc    = X3;
                end else begin
                    pc_target_jcn = (~rn_zero)? X3 : 1'b0;
                    pc_set        = (~rn_zero)? X3 : 1'b0;
                    //
                    pc_inc        = ( rn_zero)? X3 : 1'b0;
                end
                //
                multi_cycle_inc = X3;
            end
            //--------------------------------------
            // ADD : Add Index Register to ACC
            `ADD : begin
                alu_a_acc = X3;
                alu_b_rn  = X3;
                alu_c_cy  = X3;
                alu_add   = X3;
                acc_alu   = X3;
                cy_wrt    = X3;
                pc_inc    = X3;
            end
            //--------------------------------------
            // SUB : Subtract Index Register from ACC
            `SUB : begin
                alu_a_acc = X3;
                alu_b_rn  = X3;
                alu_c_cy  = X3;
                alu_sub   = X3;
                acc_alu   = X3;
                cy_wrt    = X3;
                pc_inc    = X3;
            end
            //--------------------------------------
            // LD : Load Index Register to ACC
            `LD : begin
                alu_a_rn   = X3;
                alu_thru_a = X3;
                acc_alu    = X3;
                pc_inc     = X3;
            end
            //--------------------------------------
            // XCH : Exchange Load Index Register and ACC
            `XCH : begin
                rn_acc     = X3;
                alu_a_rn   = X3;
                alu_thru_a = X3;
                acc_alu    = X3;
                pc_inc     = X3;
            end
            //--------------------------------------
            // BBL : Branch Back and Load to ACC
            `BBL : begin
                pc_pop       = X2;
                alu_a_opropa = X3;
                alu_thru_a   = X3;
                acc_alu      = X3;
                pc_set       = X3;
            end
            //--------------------------------------
            // LDM : Load Imm4 to ACC
            `LDM : begin
                alu_a_opropa = X3;
                alu_thru_a   = X3;
                acc_alu      = X3;
                pc_inc       = X3;
            end
            //--------------------------------------
            // WRM : Write RAM_CH from ACC             8'b1110_0000
            // WMP : Write RAM Output Port from ACC    8'b1110_0001
            // WRR : Write ROM Output Port from ACC    8'b1110_0010
            // WPM : Write R/W Program Memory from ACC 8'b1110_0011
            // WR0 : Write RAM Status 0 from ACC       8'b1110_0100
            // WR1 : Write RAM Status 1 from ACC       8'b1110_0101
            // WR2 : Write RAM Status 2 from ACC       8'b1110_0110
            // WR3 : Write RAM Status 3 from ACC       8'b1110_0111
            `WR_ : begin
                data_o_acc_at_x2 = X2;
                pc_inc           = X3;
            end
            //--------------------------------------
            // RDM : Read RAM_CH to ACC         8'b1110_1001
            // RDR : Read ROM Input Port to ACC 8'b1110_1010
            // RD0 : Read RAM Status 0 into ACC 8'b1110_1100
            // RD1 : Read RAM Status 1 into ACC 8'b1110_1101
            // RD2 : Read RAM Status 2 into ACC 8'b1110_1110
            // RD3 : Read RAM Status 3 into ACC 8'b1110_1111
            `RD_ : begin
                alu_b_data_i = 1'b1;
                alu_thru_b   = 1'b1;
                acc_alu      = X2;
                pc_inc       = X3;
            end
            //--------------------------------------
            // SBM : Subtract RAM_CH from ACC
            `SBM : begin
                alu_a_acc    = X2;
                alu_b_data_i = X2;
                alu_c_cy     = X2;
                alu_sub      = X2;
                acc_alu      = X2;
                cy_wrt       = X2;
                pc_inc       = X3;
            end
            //--------------------------------------
            // ADM : Add RAM_CH to ACC
            `ADM : begin
                alu_a_acc    = X2;
                alu_b_data_i = X2;
                alu_c_cy     = X2;
                alu_add      = X2;
                acc_alu      = X2;
                cy_wrt       = X2;
                pc_inc       = X3;
            end
            //--------------------------------------
            // CLB : Clear Both ACC and CY
            `CLB : begin
                acc_alu = X3;
                cy_wrt  = X3;
                pc_inc  = X3;
            end
            //--------------------------------------
            // CLC : Clear CY
            `CLC: begin
                cy_wrt = X3;
                pc_inc = X3;
            end
            //--------------------------------------
            // IAC : Increment ACC
            `IAC: begin
                alu_a_acc = X3;
                alu_c_set = X3;
                alu_add   = X3;
                acc_alu   = X3;
                cy_wrt    = X3;
                pc_inc    = X3;
            end
            //--------------------------------------
            // CMC : Complement CY
            `CMC: begin
                cy_inv = X3;
                pc_inc = X3;
            end
            //--------------------------------------
            // CMA : Complement ACC
            `CMA : begin
                alu_b_acc = X3;
                alu_c_set = X3;
                alu_sub   = X3;
                acc_alu   = X3;
                pc_inc    = X3;
            end
            //--------------------------------------
            // RAL : Rotate Left ACC and CY
            `RAL : begin
                alu_a_acc = X3;
                alu_ral   = X3;
                acc_alu   = X3;
                cy_wrt    = X3;
                pc_inc    = X3;
            end
            //--------------------------------------
            // RAR : Rotate Right ACC and CY
            `RAR : begin
                alu_a_acc = X3;
                alu_rar   = X3;
                acc_alu   = X3;
                cy_wrt    = X3;
                pc_inc    = X3;
            end
            //--------------------------------------
            // TCC : Transmit CY to ACC and Clear CY
            `TCC : begin
                alu_c_cy = X3;
                alu_add  = X3;            // add only CY
                acc_alu  = X3;
                cy_wrt   = X3;
                pc_inc   = X3;
            end
            //--------------------------------------
            // DAC : Decrement ACC
            `DAC : begin
                alu_a_acc = X3;
                alu_c_set = X3;
                alu_sub   = X3;
                acc_alu   = X3;
                cy_wrt    = X3;
                pc_inc    = X3;
            end
            //--------------------------------------
            // TCS : Transfer CY Subtract and Clear CY
            `TCS : begin
                alu_a_opropa = X3;
                alu_c_cy     = X3;
                alu_add      = X3;
                acc_alu      = X3;
                cy_wrt       = X3;
                pc_inc       = X3;
            end
            //--------------------------------------
            // STC : Set CY
            `STC : begin
                cy_set = X3;
                pc_inc = X3;
            end
            //--------------------------------------
            // DAA : Decimal Adjust ACC
            `DAA: begin
                alu_a_acc = X3;
                alu_daa   = X3;
                acc_alu   = X3 & daa;
                cy_wrt    = X3 & cy_next; // if non carry, do not affect
                pc_inc    = X3;
            end
            //--------------------------------------
            // KBP : Keyboard Process
            `KBP: begin
                acc_kbp = X3;
                pc_inc  = X3;
            end
            //--------------------------------------
            // DCL : Designate Control Line
            `DCL: begin
                dcl_set = X3;
                pc_inc  = X3;
            end
            //--------------------------------------
            // Others : Same as NOP
            default : begin
                pc_inc = X3;
            end
            //--------------------------------------
        endcase
    end
endmodule

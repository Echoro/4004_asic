`timescale 1ns/1ps

module top (
        input  wire       clk,
        input  wire       rst_n,
        output wire       SYNC_N,
        input  wire [3:0] DATA_I,
        output wire [3:0] DATA_O,
        output wire       DATA_OE,
        output wire       CM_ROM_N,
        output wire [3:0] CM_RAM_N,
        input  wire       TEST
    );

    wire CLK = clk;
    wire RES_N = rst_n;

    // instantiate state machine
    wire                 A1, A2, A3, M1, M2, X1, X2, X3;

    gen_phase u_state (
        .CLK(CLK), .RES_N(RES_N),
        .A1(A1), .A2(A2), .A3(A3), .M1(M1), .M2(M2), .X1(X1), .X2(X2), .X3(X3),.SYNC_N(SYNC_N)
    );

    // TEST Input
    reg                  test_sync;
    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N)
            test_sync <= 1'b0;
        else
            test_sync <= TEST;
    end

    // outputs from IF
    wire    [11:0]       pc_plus_one;
    wire    [11:0]       pc;
    // outputs from RegFiles
    wire                 rn_zero;
    wire    [ 3:0]       rn     ;
    wire    [7:0]        rp;
    wire    [3:0]        data_o_rom_addr;
    // outputs from ALU
    wire                 cy_next;
    wire    [3:0]        acc;
    wire                 cy;
    wire    [4:0]        alu;
    // outputs from Decoder
    wire    [7:0]        opropa0;
    wire    [7:0]        opropa1;
    wire                 do_fin;
    wire                 pc_inc;
    wire                 pc_set;
    wire                 pc_push;
    wire                 pc_pop;
    wire                 rp_fim;
    wire                 acc_alu;
    wire                 acc_kbp;
    wire                 cy_set;
    wire                 cy_inv;
    wire                 cy_wrt;
    wire                 alu_a_acc;
    wire                 alu_a_rn;
    wire                 alu_a_opropa;
    wire                 alu_b_acc;
    wire                 alu_b_rn;
    wire                 alu_b_data_i;
    wire                 alu_add;
    wire                 alu_sub;
    wire                 alu_ral;
    wire                 alu_rar;
    wire                 alu_daa;
    wire                 dcl_set;
    wire                 src_set;
    wire                 rn_alu ;
    wire                 rn_acc ;
    wire                 alu_c_cy     ;
    wire                 alu_c_set    ;
    wire                 alu_thru_a   ;
    wire                 alu_thru_b   ;
    wire                 cm_rom_at_x2 ;
    wire                 cm_ram_at_x2 ;
    wire                 data_o_src_at_x2 ;
    wire                 data_o_src_at_x3 ;
    wire                 data_o_acc_at_x2 ;
    wire                 pc_target_jcn ;
    wire                 pc_target_jun ;
    wire                 pc_target_jin ;

    // use for top

    //-------------------------------
    // DCL : Designate Command Line
    //-------------------------------
    reg  [ 2:0] dcl;     // Designate Comand Line
    wire [3:0] dcl_convert;
    //
    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N)
            dcl <= 3'b000;
        else if (dcl_set)
            dcl <= acc[2:0];
    end
    //
    assign dcl_convert[0] = (dcl == 3'b000);
    assign dcl_convert[1] = dcl[0];
    assign dcl_convert[2] = dcl[1];
    assign dcl_convert[3] = dcl[2];

    reg     [ 7:0]       src;                           // Send Register Control
    always @(posedge CLK, negedge RES_N) begin
        if (~RES_N)
            src <= 8'h00;
        else if (src_set)
            src <= rp;
    end
    // taest
    wire    [3:0]        data_o_src;
    wire    [3:0]        data_o_acc;

    assign data_o_src = (data_o_src_at_x2)? src[7:4]
        : (data_o_src_at_x3)? src[3:0]
        : 4'b0000;
    assign data_o_acc = (data_o_acc_at_x2)? acc : 4'b0000;
    assign DATA_O = data_o_rom_addr
        | data_o_src
        | data_o_acc;
    //
    assign DATA_OE = A1 | A2 | A3
        | data_o_src_at_x2 | data_o_src_at_x3
        | data_o_acc_at_x2;
    //-------------------
    // CM_ROM Output
    //-------------------
    wire                 cm_rom_at_a3; // Assert at A3 always
    wire                 cm_rom_at_m2; // Assert at M2 of I/O and RAM Access Instruction
    assign cm_rom_at_a3 = A3;
    assign cm_rom_at_m2 = M2 & (opropa0[7:4] == 4'b1110);
    assign CM_ROM_N = ~cm_rom_at_a3  // NOR
        & ~cm_rom_at_m2
        & ~cm_rom_at_x2;
    //-------------------
    // CM_RAM Output
    //-------------------
    wire [3:0] cm_ram_at_a3; // Assert at A3 always
    wire       cm_ram_at_m2; // Assert at M2 of I/O and RAM Access Instruction
    assign cm_ram_at_a3 = {4{A3}} & dcl_convert;
    assign cm_ram_at_m2 = M2 & (opropa0[7:4] == 4'b1110);
    assign CM_RAM_N = ~cm_ram_at_a3 // NOR
        & ~({4{cm_ram_at_m2}} & dcl_convert)
        & ~({4{cm_ram_at_x2}} & dcl_convert);


    IF u_IF (
        // Inputs
        .CLK          (CLK              ),
        .RES_N        (RES_N            ),
        .opropa0      (opropa0[7:0]     ),
        // input from decoder
        .opropa1      (opropa1[7:0]     ),
        .pc_inc       (pc_inc           ),
        .pc_pop       (pc_pop           ),
        .pc_push      (pc_push          ),
        .pc_set       (pc_set           ),
        .pc_target_jcn(pc_target_jcn    ),
        .pc_target_jin(pc_target_jin    ),
        .pc_target_jun(pc_target_jun    ),
        // input from regFiles
        .rp           (rp[7:0]          ),
        // Outputs
        .pc           (pc[11:0]         ),
        // outputs
        .pc_plus_one  (pc_plus_one[11:0])
    );



    decoder u_decoder (
        // inputs
        .DATA_I          (     DATA_I          ),
        .test_sync       (     test_sync       ),
        .cy              (     cy              ),
        .acc             (     acc             ),
        .rn_zero         (     rn_zero         ),
        .cy_next         (     cy_next         ),
        // Inputs
        .CLK             (     CLK             ),
        .RES_N           (     RES_N           ),
        // micro-phase
        .M1              (     M1              ),
        .M2              (     M2              ),
        .X1              (     X1              ),
        .X2              (     X2              ),
        .X3              (     X3              ),
        // Outputs
        .acc_alu         (     acc_alu         ),
        .acc_kbp         (     acc_kbp         ),
        .alu_a_acc       (     alu_a_acc       ),
        .alu_a_opropa    (     alu_a_opropa    ),
        .alu_a_rn        (     alu_a_rn        ),
        .alu_add         (     alu_add         ),
        .alu_b_acc       (     alu_b_acc       ),
        .alu_b_data_i    (     alu_b_data_i    ),
        .alu_b_rn        (     alu_b_rn        ),
        .alu_c_cy        (     alu_c_cy        ),
        .alu_c_set       (     alu_c_set       ),
        .alu_daa         (     alu_daa         ),
        .alu_ral         (     alu_ral         ),
        .alu_rar         (     alu_rar         ),
        .alu_sub         (     alu_sub         ),
        .alu_thru_a      (     alu_thru_a      ),
        .alu_thru_b      (     alu_thru_b      ),
        .cm_ram_at_x2    (     cm_ram_at_x2    ),
        .cm_rom_at_x2    (     cm_rom_at_x2    ),
        .cy_inv          (     cy_inv          ),
        .cy_set          (     cy_set          ),
        .cy_wrt          (     cy_wrt          ),
        .data_o_acc_at_x2(     data_o_acc_at_x2),
        .data_o_src_at_x2(     data_o_src_at_x2),
        .data_o_src_at_x3(     data_o_src_at_x3),
        .dcl_set         (     dcl_set         ),
        .do_fin          (     do_fin          ),
        .opropa0         (     opropa0[7:0]    ),
        .opropa1         (     opropa1[7:0]    ),
        .pc_inc          (     pc_inc          ),
        .pc_pop          (     pc_pop          ),
        .pc_push         (     pc_push         ),
        .pc_set          (     pc_set          ),
        .pc_target_jcn   (     pc_target_jcn   ),
        .pc_target_jin   (     pc_target_jin   ),
        .pc_target_jun   (     pc_target_jun   ),
        .rn_acc          (     rn_acc          ),
        .rn_alu          (     rn_alu          ),
        .rp_fim          (     rp_fim          ),
        .src_set         (     src_set         )
    );

    regFiles u_regFiles (
        // Inputs
        .CLK            (CLK                 ),
        // inputs from top
        .DATA_I         (DATA_I[3:0]         ),
        .M1             (M1                  ),
        .M2             (M2                  ),
        .A1             (A1                  ),
        .A2             (A2                  ),
        .A3             (A3                  ),
        .RES_N          (RES_N               ),
        .acc            (acc[3:0]            ),
        // input from ALU
        .alu            (alu[4:0]            ),
        .do_fin         (do_fin              ),
        // input from decoder
        .opropa0        (opropa0[7:0]        ), //for index calculation
        .opropa1        (opropa1[7:0]        ), //for index calculations
        .pc             (pc[11:0]            ),
        .pc_plus_one    (pc_plus_one[11:0]   ),
        .rn_acc         (rn_acc              ),
        .rn_alu         (rn_alu              ),
        .rp_fim         (rp_fim              ),
        // Outputs
        .data_o_rom_addr(data_o_rom_addr[3:0]),
        .rn             (rn[3:0]             ),
        .rp             (rp[7:0]             ),
        .rn_zero        (rn_zero             )
    );

    ALU u_ALU (
        // Inputs
        .CLK         (CLK          ),
        // inputs selectors
        // from top
        .DATA_I      (DATA_I[3:0]  ),
        .RES_N       (RES_N        ),
        .acc_alu     (acc_alu      ),
        .acc_kbp     (acc_kbp      ),
        .alu_a_acc   (alu_a_acc    ),
        .alu_a_opropa(alu_a_opropa ),
        .alu_a_rn    (alu_a_rn     ),
        .alu_add     (alu_add      ),
        .alu_b_acc   (alu_b_acc    ),
        .alu_b_data_i(alu_b_data_i ),
        .alu_b_rn    (alu_b_rn     ),
        .alu_c_cy    (alu_c_cy     ),
        .alu_c_set   (alu_c_set    ),
        .alu_daa     (alu_daa      ),
        .alu_ral     (alu_ral      ),
        .alu_rar     (alu_rar      ),
        .alu_sub     (alu_sub      ),
        .alu_thru_a  (alu_thru_a   ),
        .alu_thru_b  (alu_thru_b   ),
        .cy_inv      (cy_inv       ),
        .cy_set      (cy_set       ),
        .cy_wrt      (cy_wrt       ),
        // input from decoder
        .opropa0     (opropa0[7:0] ),
        // input from regfile
        .rn          (rn[3:0]      ),
        // outputs
        .acc         (acc[3:0]     ),
        .alu         (alu[4:0]     ),
        .cy          (cy           ),
        .cy_next     (cy_next      )
    );

endmodule

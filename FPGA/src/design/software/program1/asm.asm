; four bit "AND" routine on the Intel 4004
; direct A/B assignment version (no I/O wait)
        LDM  1          ; 指示
        XCH  4          ; R4 = 1
        LDM  1          ; A = 1
        XCH  0          ; R0 = A
        LDM  5          ; B = 5
        XCH  1          ; R1 = B

START
        ; -----------------------------
        ; Directly set operand A and B
        ; -----------------------------
        LDM  2          ; 指示
        XCH  4          ; R4 = 2
        ; CLC             ;清除进位状态
        ; LDM  1          ;acc = 1
        ; XCH  5          ; R5 = 1
        ; LD 2            ; acc = R2
        ; ADD 5           ; acc = R2 + R5(即1)
        ; XCH  1          ; R1 = R2+1(new B)

        CLC ;清除进位状态
        INC R0
        INC R1
        ; CLC
        ; LDM  1          ;acc = 1
        ; XCH  5          ; R5 = 1
        ; LD 0            ; acc = R0
        ; ADD 5           ; acc = R0 + R5(即1)
        ; XCH  0          ; R0 = R0+1(new B)

        ; ---------------------------------
        ; IF (R1 == 3) THEN R1 = 0xA
        ; ---------------------------------

        CLB             ; 清 ACC 和 C，保证比较干净
        LDM  1         ;acc = 1
        XCH  5          ; R5 = 1
        LD   0          ; ACC = R0
        ADD  5           ; ACC = R0 + R5[检测是否为0xf 0b1111]
        JCN  ANZ, R0_NOT_3   ; 若结果不为 0，则 R0 ≠ 3，跳过

        ; --- R1 == 3 的分支 ---
        LDM  10         ; ACC = 0xA
        XCH  0          ; R0 = 0xA

R0_NOT_3:
        ; 后续代码继续执行
        ; -----------------------------
        ; Execute AND subroutine
        ; -----------------------------
        JMS  AND        ; R2 <- A AND B
        ; XCH  2          ;ACC is 0
        LDM  3          ; 指示
        XCH  4          ; R4 = 3
        JUN  START      ; Repeat forever

        NOP

*=104
;=====================================
; "AND" SUBROUTINE (unchanged)
;=====================================
AND     CLB             ; Clear accumulator and carry
        XCH  2          ; Clear register 2 (result)
        LDM  4          ; Load loop count (4 bits)

AND_3   XCH  0           ; Load A
        RAR              ; A LSB -> Carry
        XCH  0           ; Store rotated A back
        JCN  CZ, ROTR1   ; If A bit = 0, skip B test

        XCH  1           ; Load B
        RAR              ; B LSB -> Carry
        XCH  1           ; Store rotated B back

ROTR2   XCH  2           ; Load partial result
        RAR              ; Carry -> MSB of result
        XCH  2           ; Store result
        DAC              ; Decrement loop counter
        JCN  ANZ, AND_3  ; Loop until done
        BBL  0           ; Return

ROTR1   XCH  1           ; Rotate B to keep alignment
        RAR
        XCH  1
        CLC              ; Force Carry = 0
        JUN  ROTR2       ; Continue loop


CZ  = 10
ANZ = 12
$

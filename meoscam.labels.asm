.set noreorder /* we dont need no stinking reordering. */
.set noat

.data
meosCamFlag0:
    .byte 0
meosCamFlag1:
    .byte 0
meosCamPauseFlag:
    .byte 0
meosCamDisableHudFlag:
    .byte 0
meosCamFlag4:
    .byte 0

.text
/* main update routine for the freecam when enabled */
meosCamMain:
    addiu       $sp, $sp, -0x1A0 /* C stack prologue */
    sq          $s0, 0x140($sp)
    sq          $s1, 0x130($sp)
    sq          $s2, 0x120($sp)
    sq          $s3, 0x110($sp)
    sq          $s4, 0x100($sp)
    sq          $s5, 0xF0($sp)
    sq          $s6, 0xE0($sp)
    sq          $s7, 0xD0($sp)
    sq          $fp, 0xC0($sp)
    sd          $ra, 0xB0($sp)
    swc1        $f29, 0x198($sp)
    swc1        $f28, 0x190($sp)
    swc1        $f27, 0x188($sp)
    swc1        $f26, 0x180($sp)
    swc1        $f25, 0x178($sp)
    swc1        $f24, 0x170($sp)
    swc1        $f23, 0x168($sp)
    swc1        $f22, 0x160($sp)
    swc1        $f21, 0x158($sp)
    swc1        $f20, 0x150($sp)

    daddu       $s4, $a2, $zero
    mtc1        $zero, $f26
    lwc1        $f3, 0x1070($s4)
    lwc1        $f1, 0x1074($s4)
    abs.s       $f2, $f3
    daddu       $a0, $s4, $zero
    abs.s       $f0, $f1
    /* do buttons */
    addiu       $a1, $zero, 0x2
    mov.s       $f27, $f26
    mov.s       $f28, $f26
    mul.s       $f23, $f3, $f2
    jal         UBtnpJoy_LocalCopy
    mul.s       $f24, $f1, $f0
    mov.s       $f20, $f0
    daddu       $a0, $s4, $zero
    jal         UBtnpJoy_LocalCopy
    addiu       $a1, $zero, 0x3
    sub.s       $f20, $f20, $f0
    daddu       $a0, $s4, $zero
    addiu       $a1, $zero, 0x1
    abs.s       $f0, $f20
    jal         UBtnpJoy_LocalCopy
    mul.s       $f25, $f20, $f0
    mov.s       $f20, $f0
    daddu       $a0, $s4, $zero
    jal         UBtnpJoy_LocalCopy
    daddu       $a1, $zero, $zero
    sub.s       $f20, $f20, $f0
    daddu       $a0, $s4, $zero
    addiu       $a1, $zero, 0x8
    abs.s       $f0, $f20
    jal         UBtnpJoy_LocalCopy
    mul.s       $f22, $f20, $f0
    mov.s       $f20, $f0
    daddu       $a0, $s4, $zero
    jal         UBtnpJoy_LocalCopy
    addiu       $a1, $zero, 0xA
    sub.s       $f20, $f20, $f0
    daddu       $a0, $s4, $zero
    addiu       $a1, $zero, 0x9
    abs.s       $f0, $f20
    jal         UBtnpJoy_LocalCopy
    mul.s       $f21, $f20, $f0
    mov.s       $f20, $f0
    daddu       $a0, $s4, $zero
    jal         UBtnpJoy_LocalCopy
    addiu       $a1, $zero, 0xB
    sub.s       $f20, $f20, $f0
    abs.s       $f0, $f20
    mul.s       $f29, $f20, $f0
    lw          $v0, 0x10B4($s4)
    swc1        $f25, 0x0($sp)
    swc1        $f22, 0x4($sp)
    andi        $v0, $v0, 0x400
    beqz        $v0, .negate
    swc1        $f21, 0x8($sp)
    b           .dontNegate
    mov.s       $f28, $f23

.negate:
    neg.s       $f26, $f23
    mov.s       $f27, $f24

.dontNegate:
    lui         $s7, %hi(CameraMatrix)
    daddu       $s1, $zero, $zero
    addiu       $v0, $s7, %lo(CameraMatrix)

    /* a1 is the first row of the matrix
       a0 is the second row
       v1 is the third row
       a2 is the fourth row */
    lq          $a2, 0x30($v0)
    lq          $a1, 0x0($v0)

    daddu       $s3, $zero, $zero

    lq          $a0, 0x10($v0)
    mtc1        $s1, $f12

    lq          $v1, 0x20($v0)

    lq          $s0, 0x0($sp)

    lui         $at, 0x38D1
    ori         $at, $at, 0xB717

    mtc1        $at, $f14
    mtc1        $s0, $f13

    /* copy the matrix to the stack */
    sq          $a1, 0x10($sp)
    sq          $a0, 0x20($sp)
    sq          $v1, 0x30($sp)

    jal         FFloatsNear
    sq          $a2, 0x40($sp)
    beqz        $v0, .floatNotNear
    nop

    prot3w      $v0, $s0

    jal         FFloatsNear
    mtc1        $v0, $f13

    beqz        $v0, .floatNotNear
    nop

    pextuw      $v0, $zero, $s0

    jal         FFloatsNear
    mtc1        $v0, $f13
    sltu        $s3, $zero, $v0

.floatNotNear:
    bnez        $s3, .L1
    addiu       $s2, $sp, 0x10
    addiu       $v0, $s7, 0x52D0
    lwc1        $f1, 0x10($v0)
    lqc2        $vf6, 0x40($sp)
    lui         $at, 0x44C8
    mtc1        $at, $f0
    mul.s       $f0, $f1, $f0
    daddu       $s0, $s2, $zero
    mfc1        $v0, $f0
    lqc2        $vf1, 0x20($s0)
    qmtc2.ni    $v0, $vf4
    lqc2        $vf3, 0x10($s0)
    lqc2        $vf2, 0x0($sp)
    lqc2        $vf5, 0x10($sp)
    addiu       $a0, $sp, 0x40
    vmulax.xyz  $ACC, $vf5, $vf2x
    vmadday.xyz $ACC, $vf3, $vf2y
    vmaddz.xyz  $vf2, $vf1, $vf2z
    sqc2        $vf4, 0x50($sp)
    vadda.xyzw  $ACC, $vf6, $vf0
    vmaddx.xyzw $vf1, $vf2, $vf4x
    qmfc2.ni    $a1, $vf1
    daddu       $v0, $a0, $zero
    sq          $a1, 0x0($v0)

.L1:
    mtc1        $zero, $f0
    c.eq.s      $f27, $f0
    nop
    bc1f        .L2
    c.eq.s      $f28, $f0
    c.eq.s      $f28, $f0
    nop
    bc1f        .L3
    daddu       $a0, $s2, $zero
    c.eq.s      $f26, $f0
    nop
    bc1t        .L6
    addiu       $s0, $fp, 0x5340

.L2:
    daddu       $a0, $s2, $zero

.L3:
    jal         DecomposeRotateMatrixEuler
    sq          $v0, 0x50($sp)
    sq          $v0, 0x50($sp)
    addiu       $v1, $s7, 0x52D0
    lwc1        $f20, 0x10($v1)
    lwc1        $f0, 0x50($sp)
    mul.s       $f12, $f20, $f28
    jal         RadNormalize
    add.s       $f12, $f0, $f12
    mul.s       $f1, $f20, $f27
    lwc1        $f12, 0x54($sp)
    swc1        $f0, 0x50($sp)
    jal         RadNormalize
    add.s       $f12, $f12, $f1
    lui         $at, 0xBFC7
    ori         $at, $at, 0xC82D
    mtc1        $at, $f1
    lui         $at, 0x3FC7
    ori         $at, $at, 0xC82D
    mtc1        $at, $f3
    c.lt.s      $f0, $f1
    nop
    bc1f        .L4
    swc1        $f0, 0x54($sp)
    b           .L5
    mov.s       $f2, $f1

.L4:
    c.lt.s      $f3, $f0
    nop
    bc1f        .L5
    mov.s       $f2, $f0
    mov.s       $f2, $f3

.L5:
    mul.s       $f0, $f20, $f26
    lwc1        $f12, 0x58($sp)
    swc1        $f2, 0x54($sp)
    jal         RadNormalize
    add.s       $f12, $f12, $f0
    swc1        $f0, 0x58($sp)
    addiu       $a0, $sp, 0x60
    jal         LoadRotateMatrixEuler
    lq          $a1, 0x50($sp)
    lq          $v1, 0x60($sp)
    lq          $a0, 0x70($sp)
    sq          $v1, 0x10($sp)
    sq          $a0, 0x10($s2)
    lq          $v0, 0x80($sp)
    sq          $v0, 0x20($s2)
    sw          $zero, 0x3C($sp)
    sw          $zero, 0x2C($sp)
    sw          $zero, 0x1C($sp)
    addiu       $s0, $fp, 0x5340

.L6:
    daddu       $a1, $s2, $zero
    jal         SetCmMat
    daddu       $a0, $s0, $zero
    neg.s       $f1, $f29
    lui         $at, 0x3E80
    mtc1        $at, $f2
    addiu       $v0, $s7, 0x52D0
    lwc1        $f3, 0x20($s0)
    lwc1        $f0, 0x10($v0)
    mul.s       $f1, $f1, $f2
    lui         $at, 0x3C23
    ori         $at, $at, 0xD70A
    mtc1        $at, $f4
    lui         $at, 0x4040
    mtc1        $at, $f5
    mul.s       $f0, $f0, $f1
    add.s       $f12, $f3, $f0
    c.lt.s      $f12, $f4
    bc1f        .L7
    nop
    b           .L8
    mov.s       $f12, $f4

.L7:
    c.lt.s      $f5, $f12
    nop
    bc1tl       .L8
    mov.s       $f12, $f5

.L8:
    jal         UnkFunc
    addiu       $a0, $fp, 0x5340

    lq          $s0, 0x140($sp) /* C stack epilogue */
    lq          $s1, 0x130($sp)
    lq          $s2, 0x120($sp)
    lq          $s3, 0x110($sp)
    lq          $s4, 0x100($sp)
    lq          $s5, 0xF0($sp)
    lq          $s6, 0xE0($sp)
    lq          $s7, 0xD0($sp)
    lq          $fp, 0xC0($sp)
    ld          $ra, 0xB0($sp)
    lwc1        $f29, 0x198($sp)
    lwc1        $f28, 0x190($sp)
    lwc1        $f27, 0x188($sp)
    lwc1        $f26, 0x180($sp)
    lwc1        $f25, 0x178($sp)
    lwc1        $f24, 0x170($sp)
    lwc1        $f23, 0x168($sp)
    lwc1        $f22, 0x160($sp)
    lwc1        $f21, 0x158($sp)
    lwc1        $f20, 0x150($sp)
    jr          $ra
    addiu       $sp, $sp, 0x1A0

/* Local copy of UBtnpJoy() function */
UBtnpJoy_LocalCopy:
    lui         $v0, %hi(ControllerButtonMaskLUT)
    /* index button mask table */
    sll         $v1, $a1, 1
    addiu       $v0, $v0, %lo(ControllerButtonMaskLUT)
    daddu       $a2, $a0, $zero
    addu        $v1, $v1, $v0
    lhu         $a0, 0x0($v1)

    /* check if the button was pressed */
    lw          $v0, 0x10B4($a2)
    and         $v0, $v0, $a0
    beqz        $v0, .notPressed    /* button wasn't pressed */
    nop

    /* the button was pressed */
    addu        $v1, $a2, $a1
    addiu       $v0, $zero, 0x1
    lbu         $a0, 0x10C0($v1)

    /* load float constant */
    lui         $at, 0x3B80
    ori         $at, $at, 0x8081
    mtc1        $at, $f1

    slt         $v1, $v0, $a0
    movn        $v0, $a0, $v1
    mtc1        $v0, $f0
    cvt.s.w     $f0, $f0
    jr          $ra
    mul.s       $f0, $f0, $f1

.notPressed:
    /* clear $f0 and return. */
    mtc1        $zero, $f0
    jr          $ra
    nop

.macro checkPadButton mask trueLabel flagName
    /* Get controller button bitset */
    lw $v1, %lo(ControllerButtons)($t6)
    addiu $t0, $zero, \mask
    /* do (ControllerButtons & mask) */
    and $v1, $v1, $t0
    /* if the AND results in mask, then branch to true label
        $t0 will contain the current value of the flag for you */
    beq $v1, $t0, \trueLabel
    lb $t0, %lo(\flagName)($t3)

    /* it wasn't pressed. */
    sb $zero, %lo(\flagName)($t3)
.endm

/* This function is patched into a vtable lookup, and both processes some
   freecam inputs, and also injects the main function pointer */
meosFreecamEntryHook:
    lui         $t2, %hi(UnkVar)
    lui         $t3, %hi(meosCamFlag0)
    lui         $t4, 0x3F80
    addiu       $t5, $zero, 0x1
    lui         $t6, %hi(ControllerButtons)
    lui         $t7, %hi(HUDScaleX)

    checkPadButton 0x200, .button0x200Pressed, meosCamFlag1
    /* Move on to checking the disable hud button. */
    b           .checkDisableHud
    nop

.button0x200Pressed:
    bgtz        $t0, .checkDisableHud
    nop
    lb          $t0, %lo(meosCamFlag4)($t3)
    blez        $t0, .setFlag4
    sb          $t5, %lo(meosCamFlag1)($t3)
    sb          $zero, %lo(meosCamFlag4)($t3)
    b           .checkDisableHud
    nop

.setFlag4:
    sb          $t5, %lo(meosCamFlag4)($t3)

.checkDisableHud:
    lb          $t1, %lo(meosCamFlag4)($t3)
    blez        $t1, .bailRestoreVtable

    /* Point $v0 to the freecam main function. When we return,
       the game code will execute us instead of the vtable function
       that would normally be called. */
    addiu       $v0, $t3, %lo(meosCamMain)

    addiu       $t0, $zero, 0x7
    sb          $zero, %lo(meosCamFlag0)($t3)
    sw          $t0, %lo(UnkVar)($t2)

    /* Check the disable HUD button */
    checkPadButton 0x100, .disableHudPressed, meosCamDisableHudFlag
    b           .checkPauseButton
    nop

.disableHudPressed:
    bgtz        $t0, .checkPauseButton
    nop
    lw          $t1, %lo(HUDScaleX)($t7)
    blez        $t1, .resetHud
    sb          $t5, %lo(meosCamDisableHudFlag)($t3)
    sw          $zero, %lo(HUDScaleX)($t7)
    sw          $zero, %lo(HUDScaleY)($t7)
    b           .checkPauseButton
    nop

.resetHud:
    sw          $t4, %lo(HUDScaleX)($t7)
    sw          $t4, %lo(HUDScaleY)($t7)

.checkPauseButton:
    checkPadButton 0x800, .pausePressed, meosCamPauseFlag
    jr          $ra
    nop

.pausePressed:
    bgtz        $t0, .justRet
    nop
    /* if game speed isn't 1.0, reset it */
    lw          $t1, %lo(GameClockSpeed)($t2)
    bne         $t1, $t4, .resetClockSpeed
    sb          $t5, %lo(meosCamPauseFlag)($t3)

    /* 0.001 */
    lui         $v1, 0x38D1
    ori         $v1, $v1, 0xB717
    sw          $v1, %lo(GameClockSpeed)($t2)
    sw          $v1, %lo(EngineClockSpeed)($t2)
    jr          $ra
    nop

.resetClockSpeed:
    sw          $t4, %lo(GameClockSpeed)($t2)
    sw          $t4, %lo(EngineClockSpeed)($t2)

.justRet:
    jr          $ra
    nop

    /* like bail, but restores the original, unhooked, vtable lookup */
.bailRestoreVtable:
    lb          $t0, %lo(meosCamFlag0)($t3)
    blez        $t0, .bail
    lw          $v0, 0x4($a1)
    jr          $ra
    nop

.bail:
    sw          $t4, %lo(HUDScaleX)($t7)
    sw          $t4, %lo(HUDScaleY)($t7)
    sw          $t4, %lo(GameClockSpeed)($t2)
    sw          $t4, %lo(EngineClockSpeed)($t2)
    sw          $t4, %lo(CameraZoom)($t2)
    sb          $t5, %lo(meosCamFlag0)($t3)
    jr          $ra
    nop

/* these functions replace some of the game functions */

meosFreecamFunc1:
    lui         $t0, %hi(meosCamFlag4)
    lb          $t0, %lo(meosCamFlag4)($t0)
    lw          $v1, 0x314($v0)
    blez        $t0, .flag4Unset
    addiu       $v0, $v0, 0x3A0
    jr          $ra
    addu        $v0, $v1, $zero
.flag4Unset:
    jr          $ra
    nop

meosFreecamFunc2:
    lui         $t0, %hi(meosCamFlag4)
    lb          $t0, %lo(meosCamFlag4)($t0)
    blez        $t0, .flag4Unset2
    lw          $a0, 0x30($a1)
    addiu       $t1, $zero, 0x400
    and         $a0, $a0, $t1
    beq         $a0, $t1, .andFailed
    lw          $a0, 0x30($a1)
.flag4Unset2:
    j           UnkFunc2
    nop
.andFailed:
    j           UnkFunc2
    addu        $a0, $zero, $zero

meosFreecamFunc3:
    lui         $t0, %hi(meosCamFlag4)
    lb          $t0, %lo(meosCamFlag4)($t0)
    bgtz        $t0, .flag4Unset3
    addu        $v0, $zero, $zero
    lui         $v1, %hi(UnkVar2)
    lw          $v0, %lo(UnkVar2)($v1)
    xor         $v0, $v0, $a0
.flag4Unset3:
    jr          $ra
    sltiu       $v0, $v0, 0x1

meosFreecamFunc4:
    lui         $t0, %hi(meosCamFlag4)
    lb          $t0, %lo(meosCamFlag4)($t0)
    blez        $t0, .exit
    lw          $v0, 0x10B8($a0)
    addiu       $t0, $zero, 0x800
    and         $v0, $v0, $t0
    bne         $v0, $t0, .exit
    nop
    addu        $v0, $zero, $zero
.exit:
    jr          $ra
    and         $v0, $v0, $a1

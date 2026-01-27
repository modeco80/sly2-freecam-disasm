.set noreorder /* we dont need no stinking reordering. */
.set noat

.text

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
    /* Trampoline back into the game code. */
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

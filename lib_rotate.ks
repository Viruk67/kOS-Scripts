// ---------------------------------------------------------------------------------
// SYNOPSIS
// 		A library of routines to help manage the rotation of a craft from it's current facing direction to the target facing direction.
//
//COMPATABILITY
//		KSP 1.4+
//		kOS 1.1.5 (https://ksp-kos.github.io/KOS/)
//
// PARAMETERS
//		dir:	The new facing direction. Steering will be locked to this to permit a smooth, linear rotation.
//
// COMMENTS
//		The embedded SAS functions have a smooth rotation when switch to a new direction.
//		However the kOS functions swing as fast as possible, leading to over-swing and yo-yo-ing.
//		This script by u/rybec overcomes this.
//
//	SUGGESTED MODS
//		None.
//
// CREDITS
//		Viruk67 (Author)
//		Credit for this script goes to u/rybec on reddit https://www.reddit.com/user/Rybec
// 			https://www.reddit.com/r/Kos/comments/3ivlz9/cooked_steering_flailing_your_craft_wildly_pids/
//		
// ---------------------------------------------------------------------------------

declare FUNCTION smoothRotate {
    PARAMETER dir.
    LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
    LOCAL curF IS SHIP:FACING:FOREVECTOR.
    LOCAL curR IS SHIP:FACING:TOPVECTOR.
    LOCAL dirF IS dir:FOREVECTOR.
    LOCAL dirR IS dir:TOPVECTOR.
    LOCAL axis IS VCRS(curF,dirF).
    LOCAL axisR IS VCRS(curR,dirR).
    LOCAL rotAng IS VANG(dirF,curF)/spd.
    LOCAL rotRAng IS VANG(dirR,curR)/spd.
    LOCAL rot IS ANGLEAXIS(min(2,rotAng),axis).
    LOCAL rotR IS R(0,0,0).
    IF VANG(dirF,curF) < 90 {
        SET rotR TO ANGLEAXIS(min(0.5,rotRAng),axisR).
    }
    RETURN LOOKDIRUP(rot*curF,rotR*curR).
}
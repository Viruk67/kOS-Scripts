// Credit for this script goes to u/rybec on reddit https://www.reddit.com/user/Rybec
// https://www.reddit.com/r/Kos/comments/3ivlz9/cooked_steering_flailing_your_craft_wildly_pids/

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
// Credit for the bulk of this script goes to Bradley Hammond
// https://github.com/mrbradleyjh/KOS-Hoverslam/blob/master/hoverslam.ks

@LAZYGLOBAL off.

PARAMETER radarOffset.										// The distance between the probe core and the bottom of the gear
IF radarOffset <= 0 { SET radarOffset TO 10. }				// Check for a suitable, default value

run lib_rotate.

clearscreen.
//set radarOffset to 9.184.	 								// The value of alt:radar when landed (on gear)
lock trueRadar to alt:radar - radarOffset.					// Offset radar to get distance from gear to ground
lock g to constant:g * body:mass / body:radius^2.			// Gravity (m/s^2)
lock maxDecel to (ship:availablethrust / ship:mass) - g.	// Maximum deceleration possible (m/s^2)
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		// The distance the burn will require
lock idealThrottle to stopDist / trueRadar.					// Throttle required for perfect hoverslam
lock impactTime to trueRadar / abs(ship:verticalspeed).		// Time until impact, used for landing gear

PRINT "Hard stopping in space...".
	lock steering to smoothRotate(LOOKDIRUP(SHIP:SRFRETROGRADE:VECTOR, SHIP:FACING:UPVECTOR)).	// Point surface retrograde, facing up
	lock throttle to 1.																			// Come to a very hard stop in space, not very efficient
	wait until ship:groundspeed < 1.															// Wait until we are going almost vertically down (no horizontal speed)
		lock throttle to 0.

WAIT UNTIL ship:verticalspeed < -1.																// Wait until we are going down (vertically or otherwise)
	print "Preparing for hoverslam...".
	rcs on.
	brakes on.
	lock steering to smoothRotate(LOOKDIRUP(SHIP:SRFRETROGRADE:VECTOR, SHIP:FACING:UPVECTOR)).	// Point surface retrograde, facing up
	when impactTime < 3 then {gear on.}															// Put the gear on when we are about 3 seconds from touchdown

WAIT UNTIL trueRadar < stopDist.
	print "Performing hoverslam".
	lock throttle to idealThrottle.																// Perfom suicide burn

WAIT UNTIL ship:verticalspeed > -0.01.															// When we come to a stop, drift to the surface (better be close to the ground at this point!)
	print "Hoverslam completed".
	unlock throttle.
	set ship:control:pilotmainthrottle to 0.
	rcs off.
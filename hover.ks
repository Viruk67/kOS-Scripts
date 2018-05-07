// ---------------------------------------------------------------------------------
// SYNOPSIS
// 		Script to manage a craft in "hover", controlling throttle, even if the craft is pitched over
//
//COMPATABILITY
//		KSP 1.4+
//		kOS 1.1.5 (https://ksp-kos.github.io/KOS/)
//
// PARAMETERS
//		dAltitude: Desired altitue in meters above the surface. There is no default value.
//					Should be more than the height off the ground with gear extended.
//					For most simple landers 10m is sufficient.
//
//		e.g. to hover at 10m
//
//				run hover(10).
//
// COMMENTS
//		Can yo-yo a lot if initial altitude is significantly different from target altitude.
//		So, try to start nearly hovering at near the desired altitude.
//		Obviously you need a TWR of at least 1!
//		Lower the gear to end the hover in the current state. Assumes the gear was raised to start with.
//
//	SUGGESTED MODS
//		None.
//
// CREDITS
//		Viruk67 (Author)
//		
// ---------------------------------------------------------------------------------

@LAZYGLOBAL off.
RUN lib_physics.

PARAMETER dAltitude.	// The desired altitude of hover

CLEARSCREEN.

// Initialise throttle variables
LOCAL thOffset		IS 0.
LOCAL midThrottle	IS 0.

// Initialise the PID variables
LOCAL aPID		IS PIDLOOP().

// Create the PID object
SET aPID to PIDLOOP( 0.02, 0.01, 0.25, -0.1, 0.1 ). 	// Kp, Ki, Kd, Min / Max Throttle deviation from balanced

// Enable SAS
SAS ON.

// Set the "real" throttle to zero
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

// Hit "stage" until there's an active engine. If we are already flying this will do nothing
// We did just set the throttle to zero though!
UNTIL SHIP:AVAILABLETHRUST > 0 
{
	WAIT 0.5.
	STAGE.
}

// midThrottle is the throttle setting that would exactly hover against gravity
// at the point we are at right now, with the thrust available right now
LOCK midThrottle TO Fg_here()/SHIP:AVAILABLETHRUST.

// Lock the total throttle to the perfect throttle plus the bit to bring us to perfection
// To begin with this will be "hover" + offset
LOCK THROTTLE TO midThrottle + thOffset.
WAIT 1.	// Lift off a bit, if we are on the surface

// Ensure gear is stowed	
GEAR OFF.

// Loop until the pilot opens the gear (we could use any trigger here if we want to of course)
UNTIL GEAR
{
	// Very simple PID controller for throttle setting
	SET aPID:SETPOINT TO dAltitude.
	SET thOffset TO aPID:UPDATE(TIME:SECONDS, ALT:RADAR).
	
	// Display telemetry
	PRINT "Desired Altitude: " 	+ ROUND(dAltitude,2) 	+ "     " AT (1,1).
	PRINT "Actual  Altitude: " 	+ ROUND(ALT:RADAR,2) 	+ "     " AT (1,2).
	PRINT "Hover throttle  : " 	+ ROUND(midThrottle,2) 	+ "     " AT (1,3).
	PRINT "Offset throttle : " 	+ ROUND(thOffset,2) 	+ "     " AT (1,4).
	
	// See if we are just about hovering (nearly at the desired altitude and moving very slowly)
	// This ignores any lateral velocity
	// We might also be moving up/down a slope, but still perfectly hovering at the desired altitude
	IF (ABS(dAltitude - ALT:RADAR)< 0.5 AND ABS(SHIP:VERTICALSPEED) < 0.5)
	{
		PRINT "Hovering    " AT (1,6).
	}
	ELSE
	{
		PRINT "Not Hovering" AT (1,6).
	}
	
	// Wait before computing another loop to give KSP time to do something else
	WAIT 0.01.
}

CLEARSCREEN.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO THROTTLE.
PRINT "------------------------------".
PRINT "Releasing control back to you.".
PRINT "------------------------------".
CLEARSCREEN.

PARAMETER finalAlt.			// Target altitude. Should be mid-range
PARAMETER finalSpeed. 		// Target speed. Should be mid-range
PARAMETER finalPitch. 		// Target pitch. Any reasonable pitch will do

IF finalAlt  	<= 0 	{ SET finalAlt 		TO 100000. 	}	// Check for a suitable, default value
IF finalSpeed  	<= 0 	{ SET finalSpeed 	TO 500.  	}	// Check for a suitable, default value
IF finalPitch  	<= 0 	{ SET finalPitch 	TO 45.  	}	// Check for a suitable, default value

LOCAL tPID IS PIDLOOP().

// Initialise
SET startSeek	TO FALSE.									// Don't start seeking immediately

SAS ON.														// Switch SAS ON as kOS can now work with stability assist

// Set our pitch controller to a gentle curve
LOCK Pt TO MAX(90-(finalPitch*(SHIP:ALTITUDE/finalAlt)),0).	// Set a linear change of pitch above the horizon, completing when "finalAlt =  SHIP:ALTITUDE"
LOCK STEERING TO HEADING(90,Pt) + R(0,0,-90).				// Lock the steering to East and the calculated pitch. Lock in a suitable rotation as well to prevent unwinding at launch

// Launch!
// Hit "stage" until there's an active engine
UNTIL SHIP:AVAILABLETHRUST > 0
{
	WAIT 0.2.
	STAGE.
}

// Compute when we have a sudden drop in thrust, we must then need to stage
SET oldAvailableThrust TO SHIP:AVAILABLETHRUST.				// There will be no available thrust until after launch!
WHEN SHIP:AVAILABLETHRUST < oldAvailableThrust THEN
{
	STAGE.
	SET oldAvailableThrust TO SHIP:AVAILABLETHRUST.			// Remember the new available thrust
	PRESERVE.												// We may need to do this again!
}

// Initialise the PID controller
// Kp is the "P" gain. This is how "aggressive" we want the throttle to be
// Ki is the "I" gain. This is how errors over time are managed
// Kd is the "D" gain. This is how fast we want to respond to changes in the level of error
SET tPID to PIDLOOP( 0.25, 0.20, 0.00, 0, 1 ). 	// Kp, Ki, Kd, Min Throttle, Max Throttle values

// thSetting is the value I'll be letting the PID controller adjust for me
SET thSetting TO 1.
LOCK THROTTLE TO MIN(1,MAX(0,thSetting)).

// Only start seeking when we hit the right speed
WHEN SHIP:AIRSPEED > finalSpeed THEN { SET startSeek TO TRUE. }

// Repeat until we reach our target altitude. Our speed should be set correctly!
UNTIL SHIP:ALTITUDE > finalAlt
{
	// Try to reach our target speed. We may well reach it very early in ascent
	IF startSeek = TRUE 
	{
		SET tPID:SETPOINT TO finalSpeed.
		SET thSetting TO tPID:UPDATE(TIME:SECONDS, SHIP:AIRSPEED).
	}
	
	PRINT "Airspeed:        " + ROUND(SHIP:AIRSPEED				,0) + "  " 		AT (0,0).
	PRINT "Target Speed:    " + ROUND(finalSpeed   				,0) + "  " 		AT (0,1).
	PRINT "Throttle:        " + ROUND(thSetting					,2) + "    " 	AT (0,3).
	PRINT "Altitude:        " + ROUND(SHIP:ALTITUDE				,0) + "  " 		AT (0,5).
	PRINT "Target Altitude: " + ROUND(finalAlt   				,0) + "  " 		AT (0,6).
	
	WAIT 0.01.
}

// Set the pilot's (player's) throttle to 0 and coast
//LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO THROTTLE.
SAS ON.
//UNLOCK STEERING.
//UNLOCK THROTTLE.
CLEARSCREEN.

// The player can now test away!
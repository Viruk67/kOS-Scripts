// ---------------------------------------------------------------------------------
// SYNOPSIS
// 		Launch and ascension script, managing pitch, throttle and staging. Does not circularise the orbit
//
//COMPATABILITY
//		KSP 1.4+
//		kOS 1.1.5 (https://ksp-kos.github.io/KOS/)
//
// PARAMETERS
//		finalAlt:	The target apoapsis altitude in meters. defailt is 100,000
//		incl:		The target inclination of the resulting orbit, above (+ve) or below east (-ve) in degrees. Default is 0 (due East)
//
//		e.g. Launch to an apoapsis of 200km, 30 degress to the North of due East
//
//				run ascend(200000,30).
//
// COMMENTS
//		When in the VAB, try to balance the TWR of each stage to about 1.6. Otherwise, the PID loop might have a hard time managing the throttle at the extremes
//		Script is entirely automated, just run the script and the craft will launch, throttle and stage until the desired apoapsis and inclination are obtained.
//		Craft will always end with a pitch of 30 degress to the horizon (see turnpitch). Does not circularise the orbit
//
//	SUGGESTED MODS
//		Kerbal Engineer Redux: https://github.com/jrbudda/KerbalEngineer
//
// CREDITS
//		Viruk67 (Author)
//		
// ---------------------------------------------------------------------------------

@LAZYGLOBAL off.

//RUN lib_pid.
RUN lib_ship.

PARAMETER finalAlt.											// Target final altitude
PARAMETER incl.												// Target inclination

IF finalAlt  <= 0 	{ SET finalAlt TO 100000. }				// Check for a suitable, default value
IF ABS(incl) >= 360	{ SET incl TO 0. }						// Check for a suitable, default value

CLEARSCREEN.

// Initialise
//LOCAL finalAlt			IS 100000.						// Target final altitude
//LOCAL incl				IS 0.							// Target inclination

LOCAL tTWR					IS 2.0.							// Target TWR

LOCAL turnPitch				IS 30.							// Target pitch to the horizon (90 is stright up and 0 is parallel to the horizon/ground)
LOCAL turnAlt				IS 35000.						// End pitching over by the time we reach 35km
LOCAL incAlt				IS 5000.						// Stay pointing stright up until we reach 5km, then start pitching over

LOCAL Ps					IS 0.
LOCAL Is					IS 0.
LOCAL oldAvailableThrust	IS 0.
LOCAL aPID					IS PIDLOOP().
LOCAL th					IS 1.
LOCAL aTWR					IS 0.
LOCAL towerAlt				IS 5000.						// Stay at maximum throttle until we have cleared the tower (no longer in game), then kick in the PID loop

SAS ON.														// Switch SAS ON as kOS can now work with stability assist
LOCK THROTTLE TO 1.											// Initially, lock the throttle to maximum

LOCK Ps TO 90-((90-turnPitch)*(SHIP:ALTITUDE/turnAlt)).		// Set a linear change of pitch above the horizon
LOCK Is TO incl*(MIN(SHIP:ALTITUDE,incAlt)/incAlt).			// Slowly increase inclination, to complete by the time we get to incAlt
LOCK STEERING TO HEADING(90-Is,Ps) + R(0,0,-90).			// Lock the steering to East (+ or - inclination) and the calculated pitch. Lock in a suitable rotation as well to prevent unwinding at launch

// Launch!
// Hit "stage" until there's an active engine
UNTIL SHIP:AVAILABLETHRUST > 0
{
	WAIT 0.1.
	STAGE.
}

// Compute when we have a sudden drop in thrust, we must then need to stage [This is redundant if Smart Parts are included for staging]
SET oldAvailableThrust TO SHIP:AVAILABLETHRUST.			// There will be no available thrust until after launch!
WHEN SHIP:AVAILABLETHRUST < oldAvailableThrust THEN
{
	STAGE.

	SET oldAvailableThrust TO SHIP:AVAILABLETHRUST.		// Remember the new available thrust
	PRESERVE.											// We may need to do this again!
}

// Use a PID controller to lock TWR to about 2.0
// Initialise the PID controller
// Kp is the "P" gain. This is how "aggressive" we want the throttle to be, the magnitude of any response
// Ki is the "I" gain. This is how strongly errors over time are managed
// Kd is the "D" gain. This is how fast we want to respond to changes in the level of error
SET aPID to PIDLOOP( 0.25, 0.20, 0.00, 0, 1 ). 	// Kp, Ki, Kd, Min Throttle, Max Throttle values

// Calculate the current, actual TWR
LOCK aTWR TO CurAvailableTWR().

// Lock the throttle to the PID controller, once we cleared the tower. In the meantime, its locked to 1 (maximum). See above
// This will also give time for the PID controller to seek and settle. There still might be a kick in "th" though
WHEN (SHIP:ALTITUDE > towerAlt) THEN { LOCK THROTTLE TO MIN(1,MAX(0,th)). } 

// Repeat until we at the end of turn altitude
UNTIL SHIP:ALTITUDE > turnAlt
{
	// Very simple PID controller for throttle setting
	SET aPID:SETPOINT TO tTWR.
	SET th TO aPID:UPDATE(TIME:SECONDS, aTWR).
	
	PRINT "Target altitude        is "	+ finalAlt		+ "m"					AT (0,0).	// Target final altitude passed in
	PRINT "Target inclination     is "	+ incl			+ " "					AT (0,1).	// Target inclination passed in
	PRINT "Calculated pitch       is " 	+ ROUND(Ps,2) 	+ " above horizon   " 	AT (0,3). 	// Print calculated pitch to two decimal places
	PRINT "Calculated inclination is " 	+ ROUND(Is,2) 	+ " from East       " 	AT (0,4). 	// Print calculated inclination to two decimal places
	PRINT "Calculated throttle    is " 	+ ROUND(th,2) 	+ "   "					AT (0,6).	// Print calculated throttle to two decimal places 
	PRINT "Target TWR             is "	+ ROUND(tTWR,2) + "   "					AT (0,7).	// Print target TWR
	PRINT "Actual TWR             is "	+ ROUND(aTWR,2) + "   "					AT (0,8).	// Print actual TWR
	
	WAIT 0.05.
}

CLEARSCREEN.
PRINT "Cruising to set apoapsis of " + finalAlt + "m" AT (1,1).
LOCK THROTTLE TO 1.
UNLOCK STEERING.							// Release control of the steering back to the pilot at whatever pitch we find ourselves at
SAS ON.										// Enable SAS
//LIGHTS ON.								// Open extendible items which must have been bound in the VAB to the Lights Action Group or this will do nothing

WAIT UNTIL SHIP:APOAPSIS > finalAlt.		// Wait until we will be well out of the atmosphere

UNLOCK THROTTLE.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.	// Kill the "real" throttle. This is a special command to control the user (pilot) throttle, to ensure we coast even after the script ends

CLEARSCREEN.
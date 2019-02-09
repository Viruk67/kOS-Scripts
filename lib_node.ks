// ---------------------------------------------------------------------------------
// SYNOPSIS
// 		A library of functions to execute node related tasks
//
//COMPATABILITY
//		KSP 1.6.1
//		kOS 1.1.6.1 (https://ksp-kos.github.io/KOS/)
//
// PARAMETERS
//		None.
//
// COMMENTS
//		None.
//
//	SUGGESTED MODS
//		None.
//
// CREDITS
//		Viruk67 (Author)
//		The function exnode is taken from http://ksp-kos.github.io/KOS_DOC/tutorials/exenode.html
//		
// ---------------------------------------------------------------------------------

@LAZYGLOBAL off.

// Timewarp to the next node, give or take a number of seconds (default 180)
declare function warpnode
{
    PARAMETER sec.

    // Set a default number of seconds if none are supplied
    IF (sec <=0)
    {
        SET sec TO 180.
    }

	// Get a copy of the next node in line
	SET nd TO NEXTNODE.

	// Calculate ship's max acceleration
	IF (SHIP:AVAILABLETHRUST <= 0)
	{
		PRINT "No available trust. Check engines are activated.".
	}
	ELSE
	{
		// Acceleration is Force * Mass
		SET max_acc TO SHIP:AVAILABLETHRUST/SHIP:MASS.

		// Calculate time to warp to (3 minutes before start of burn)
		SET burn_duration TO nd:deltav:mag/max_acc.
		SET warp_time TO time:seconds + nd:ETA - (burn_duration/2) - (sec).

		// Now warp!
		kuniverse:timewarp:warpto(warp_time).
	}
}

// ----------------------------------------------------------------------------------

// Execute the next node in sequence, even if there are more than one planned
function exnode 
{
	// Get a copy of the next node in line
	SET nd TO NEXTNODE.

	// Print out node's basic parameters - ETA and deltaV
	PRINT "Node in: " + ROUND(nd:eta,1) + "s, DeltaV: " + ROUND(nd:deltav:mag,1) + "m/s".
	PRINT "Available Thrust: " + ROUND(SHIP:AVAILABLETHRUST,1) + "kN".

	// Calculate ship's max acceleration
	IF (SHIP:AVAILABLETHRUST <= 0)
	{
		PRINT "No available trust. Check engines are activated.".
		RETURN.
	}
	ELSE
	{
		// Acceleration is Force * Mass
		//LOCK max_acc TO SHIP:AVAILABLETHRUST/SHIP:MASS.
		SET max_acc TO SHIP:AVAILABLETHRUST/SHIP:MASS.
	}
	
	// Now we just need to divide deltav:mag by our ship's max acceleration
	SET burn_duration TO nd:deltav:mag/max_acc.
	PRINT "Estimated burn duration: " + ROUND(burn_duration,1) + "s".

	// Wait until we are near the node, with 60 seconds grace
	// This way we can wait in the current orientation, e.g. panels facing sun, until the last moment
	PRINT "Waiting to align at T- " + ROUND(burn_duration/2 + 60).
	WAIT UNTIL nd:eta <= (burn_duration/2 + 60).

	// Point to node, keeping roll the same. We have about 60 seconds to do this
	// Large, unwieldy craft may fail without RCS, oscillating either side of the node
	PRINT "Rotating towards node".
	SET np TO LOOKDIRUP(nd:deltav, SHIP:FACING:TOPVECTOR). 
	LOCK STEERING TO np.

	// Now we need to wait until the burn vector and ship's facing are aligned
	// Note that we may swing past this point, back and forth several times
	// WAIT UNTIL ABS(np:pitch - facing:pitch) < 0.15 and ABS(np:yaw - facing:yaw) < 0.15
	LOCK align TO ABS( COS(FACING:PITCH) 	- COS(np:PITCH) )
			    + ABS( SIN(FACING:PITCH) 	- SIN(np:PITCH) )
			    + ABS( COS(FACING:YAW)   	- COS(np:YAW)   )
			    + ABS( SIN(FACING:YAW) 		- SIN(np:YAW)   ).
	UNTIL align < 0.1
	{
		//PRINT "Facing Pitch:" + ROUND(FACING:PITCH,2)  + "  " AT (0,5).
		//PRINT "Facing Yaw  :" + ROUND(FACING:YAW,2)    + "  " AT (0,6).
		//PRINT "Target Pitch:" + ROUND(np:PITCH,2)      + "  " AT (0,7).
		//PRINT "Target Yaw  :" + ROUND(np:YAW,2)        + "  " AT (0,8).
		//PRINT "Alignment   :" + ROUND(align,2)         + "  " AT (0,9).
	
		WAIT 0.05.
	}

	// The ship is facing the right direction so let's wait for our burn time
	PRINT "Waiting for burn at T- " + ROUND(burn_duration/2).
	WAIT UNTIL nd:eta <= (burn_duration/2).

	// We only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it
	PRINT "Executing node".

	// Record initial deltav
	SET dv0 TO nd:deltav.
	
	// Recalculate current max_acceleration, as it changes while we burn through fuel, using event driven code
	LOCK tset TO MIN(1,MAX(0,nd:deltav:mag/max_acc)).
	LOCK THROTTLE TO tset.
	
	SET done TO False.
	SET oldShipAvMaxThrust TO SHIP:AVAILABLETHRUST.
	
	UNTIL done
	{
		// Check if we need to stage. If we've run out of stages this could be very bad for the Kerbal!
		IF SHIP:AVAILABLETHRUST < oldShipAvMaxThrust 	{ STAGE. }	// Assume we stage only once, if there are inter-stages, oh well...
		SET oldShipAvMaxThrust TO SHIP:AVAILABLETHRUST.				// Keep a track of SHIP:AVAILABLETHRUST for the next loop
		IF SHIP:AVAILABLETHRUST = 0 								// If SHIP:AVAILABLETHRUST is zero, abort!
		{
			PRINT "Aborting burn (no thrust)".
			LOCK throttle TO 0.
			SET done TO True.
		}
		ELSE
		{
			// "Set" the maximum available acceleration, rather than lock it, to avoid the tiny chance the stage hasn't kicked in yet
			// Prevents divide by zero errors from event driven code
			SET max_acc TO SHIP:AVAILABLETHRUST/SHIP:MASS.
		}		
		
		// Here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
		// This check is done via checking the dot product of those 2 vectors
		if VDOT(dv0, nd:deltav) < 0 AND done = False
		{
			PRINT "Aborting burn (facing opposite)".
			LOCK throttle TO 0.
			SET done TO True.
		}

		// Alternatively, we have very little left to burn, less then 0.1m/s, but are still pointing in the right direction
		if nd:deltav:mag < 0.1 AND done = False
		{
			PRINT "Finalizing burn, remain dv " + ROUND(nd:deltav:mag,1) + "m/s, vdot: " + ROUND(VDOT(dv0, nd:deltav),1).
			
			// We burn slowly until our node vector starts to drift significantly from initial vector
			// This usually means we are on point
			// Or we have so little throttle we may as well stop
			WAIT UNTIL (VDOT(dv0, nd:deltav) < 0.5) OR (tset < 0.01).
			LOCK THROTTLE TO 0.
			SET done TO True.
		}
		
		// Give KSP a chance to do something else
		WAIT 0.01.
	}

	PRINT "End of burn, remain dv " + ROUND(nd:deltav:mag,1) + "m/s, vdot: " + ROUND(VDOT(dv0, nd:deltav),1).
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	WAIT 1.

	// We no longer need the manoeuvre node
	REMOVE nd.

	// Set throttle TO 0 just in case.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}

// ----------------------------------------------------------------------------------

// Creating a Circularisation Node by being clever
function circle 
{
	LOCAL ov TO 0.
	LOCAL av TO 0.
	
	// Calculate Orbital Velocity
	SET ov TO Orbital_velocity().
	
	// Get the predicted orbital velocity at apoapsis. This will be the MAGnitude of our orbital vector
	SET av TO VELOCITYAT(SHIP, TIME:SECONDS+ETA:APOAPSIS):ORBIT:MAG.
	
	// Calculate how much more velocity we need based on the required speed and our predicted speed
	LOCAL dv TO ov - av.
	
	// Create a node and add it to the flight plan
	// Add the required deltaV to prograde (assume all we want to do is go faster in our current direction)
	LOCAL cnode TO NODE(TIME:SECONDS+ETA:APOAPSIS,0,0,dv).
	ADD cnode.
}
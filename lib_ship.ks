// ---------------------------------------------------------------------------------
// SYNOPSIS
// 		A library of routines for ship/vessel based functions
//
//COMPATABILITY
//		KSP 1.4+
//		kOS 1.1.5 (https://ksp-kos.github.io/KOS/)
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
//		

@LAZYGLOBAL off.

RUN lib_physics.

// Return the current total engine thrust
declare function current_thrust {

	LOCAL cThrust IS 0.
	LOCAL engList IS LIST().
	
	// Iterate over all engines to get their current thrust
	// (includes throttle setting and solid rocket boosters)
	LIST ENGINES IN engList.
	FOR eng in engList { SET cThrust TO cThrust + eng:THRUST. }
	
	return cThrust. // Return current ship's total current thrust
}


// Return the current ship's current available Thrust to Weight Ratio
declare function CurAvailableTWR {
	return current_thrust() / Fg_here().
}


// Return the current ship's maximum available Thrust to Weight Ratio
// (ignores throttle)
declare function MaxAvailableTWR {
	return SHIP:AVAILABLETHRUST / Fg_here().
}


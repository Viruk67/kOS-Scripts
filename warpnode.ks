// ---------------------------------------------------------------------------------
// SYNOPSIS
// 		A library of functions to execute node related tasks
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
//		The function exnode is taken from http://ksp-kos.github.io/KOS_DOC/tutorials/exenode.html
//		
// ---------------------------------------------------------------------------------

// ------------------------------------------------------------------------------------------------

function warpnode
{
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
		SET warp_time TO time:seconds + nd:ETA - (burn_duration/2) - (3*60).

		// Now warp!
		kuniverse:timewarp:warpto(warp_time).
	}
}

warpnode().
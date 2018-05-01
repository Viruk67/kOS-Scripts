// ---------------------------------------------------------------------------------
// SYNOPSIS
// 		A library of routines to help do basic physics calculations
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
//		The function Orbital_velocity taken from http://wiki.kerbalspaceprogram.com/wiki/Tutorial:_Basic_Orbiting_(Math)
//		
// ---------------------------------------------------------------------------------

@LAZYGLOBAL off.

// Return the gravity acceleration at a given height (altitude)
declare function g_height {
	declare parameter height.
	return constant():G * ((SHIP:BODY:MASS)/((height + BODY:RADIUS)^2)).
}

// Return the gravity acceleration at SHIP's current location.
declare function g_here {
  return g_height(SHIP:ALTITUDE).
}.

// Return the force on SHIP due to gravity acceleration at SHIP's current location.
declare function Fg_here {
  return SHIP:MASS*g_here().
}.

// Calculate our orbital velocity around the current ship's body
declare function Orbital_velocity {
	LOCAL R to SHIP:BODY:RADIUS.
	LOCAL g to g_height(0).
	LOCAL h to SHIP:APOAPSIS.
	return R * SQRT ( g / (R + h)).
}.
// ---------------------------------------------------------------------------------
// SYNOPSIS
// 		Convenience script to run a complete launch, ascend and circularise cycle.
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
// ---------------------------------------------------------------------------------

run init.
run lib_node.

run ascend(0,0).

CLEARSCREEN.
circle().

CLEARSCREEN.
exnode().
// ---------------------------------------------------------------------------------
// SYNOPSIS
// 		Convenience script to copy the local archive to the current craft.
//
//COMPATABILITY
//		KSP 1.6.1+
//		kOS 1.1.6.1 (https://ksp-kos.github.io/KOS/)
//
// PARAMETERS
//		None.
//
// COMMENTS
//		Run this script before any others to prime the local CPU
//		Increase the CPU's memory to 20kb while still in the VAB/SPH, otherwise the copied code might not fit.
//		To do so, right click the CPU and increase the memory value in the properties pane
//
//	SUGGESTED MODS
//		None.
//
// CREDITS
//		Viruk67 (Author)
//		
// ---------------------------------------------------------------------------------

switch to 0.

copypath(lib_physics.ks,"1:").
copypath(lib_node.ks,"1:").
copypath(lib_ship.ks,"1:").
copypath(lib_rotate.ks,"1:").

copypath(node.ks,"1:").
copypath(circ.ks,"1:").
copypath(ascend.ks,"1:").
copypath(warpnode.ks,"1:").

copypath(hover.ks,"1:").
copypath(slam.ks,"1:").

switch to 1.
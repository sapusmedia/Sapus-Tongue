//
// Sapus Tongue configuration file
//

/**TIP: (See GameNode.m)
 Use Experimental physics stepper to gain some FPS and have an smoother physics simulation
 
 To enable, set it to 1. Disabled by default.
 */
#define ST_EXPERIMENTAL_PHYSICS_STEP 0


/** For debugging purposes.
 It will draw the physics shapes
 
 To enable, set it to 1. Disabled by default.
 In order to see the shapes you will need to 
 */
#define ST_DRAW_SHAPES 0

/**
 There are 2 ways to rotate
 With the Director or with the ViewController.
 
 * Director:
   + Faster
   - All UIKit objects needs to be rotated manually
 * ViewController:
   - A little bit slower
   + All the UIKit objects are placed correctly, even when the EAGLView is rotated
 
 By default Sapus Tongue uses:
	- "Root View Controller" on the iPad version
	- No auto rotation on the iPhone version
 */

#define kSTAutorotationNone 0
#define kSTAutorotationCCDirector 1
#define kSTAutorotationUIViewController 2

// autorotate using UIViewController
#if defined(__ARM_NEON__) || TARGET_IPHONE_SIMULATOR

#define ST_AUTOROTATE kSTAutorotationUIViewController

#else

// Don't use UIViewController on old devices
#define ST_AUTOROTATE kSTAutorotationNone

#endif

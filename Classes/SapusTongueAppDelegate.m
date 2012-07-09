/*
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011-2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

//
// Main File. The Entry Point is here
//

#import "cocos2d.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"
#import "SimpleAudioEngine.h"

#import "SapusConfig.h"

#import "SapusTongueAppDelegate.h"
#import "SapusIntroNode.h"
#import "ScoreManager.h"

#if defined(__CC_PLATFORM_MAC)
#import "BDSKOverlayWindow.h"
#endif

//
// "private" methods in objective-c can be coded using an "extension" with the random name,
// like Private.
//
@interface SapusTongueAppDelegate ()

#ifdef __CC_PLATFORM_IOS
-(void) setupDirectorIOS;
-(void) setupRootViewController;

#elif defined( __CC_PLATFORM_MAC)
-(void) setupDirectorMac;
#endif // __CC_PLATFORM_MAC

@end


//
// AppDelegate, the main class.
// Basic initializations and "cache" code is done here
//
@implementation SapusTongueAppDelegate

@synthesize isPaused=isPaused_;
@synthesize isPlaying=isPlaying_;

#ifdef __CC_PLATFORM_IOS
@synthesize window=window_, navController=navController_, director=director_;

#elif defined(__CC_PLATFORM_MAC)
@synthesize glView=glView_, window=window_, director=director_;
@synthesize saveScoreWindow=saveScoreWindow_;
@synthesize saveScoreButton=saveScoreButton_;
@synthesize playerNameTextField=playerNameTextField_;
@synthesize displayScoresTableView=displayScoresTableView_;
@synthesize overlayWindow=overlayWindow_;

#endif // __CC_PLATFORM_MAC


#ifdef __CC_PLATFORM_IOS
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
#elif defined(__CC_PLATFORM_MAC)
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
#endif
{
	// TIP:
	// AppDelegate can be accessed from anywhere using [UIApplication delegate]
	// so it is practical to store "global" variables in this class
	//
	// TIP: But you should not abuse of it, otherwise your code might be difficult to maintain!! 
	
	isPaused_ = NO;
	isPlaying_ = NO;

	// random initialization
	[self initRandom];
	
	//
	// CCDirector / OpenGL initialization
	//
#ifdef __CC_PLATFORM_IOS
	[self setupDirectorIOS];
#elif __CC_PLATFORM_MAC
	[self setupDirectorMac];
#endif
	
	// turn this feature On when testing the speed
	[director_ setDisplayStats:YES];	

	// TIP:
	// Sapus Tongue uses almost all of the images with gradients.
	// They look good in 32 bit mode (RGBA8888) but the consume lot of memory.
	// If your game doesn't need such precision in the images, use 16-bit textures.
	// RGBA4444 or RGB5_A1
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// This will initialize the score manager
	[[ScoreManager sharedManager] initScores];

	// music initialization
	[self preLoadSounds];
		
#ifdef __CC_PLATFORM_IOS
	// Run the intro Scene
	[director_ pushScene: [SapusIntroNode scene] ];

	[self setupRootViewController];

	return YES;

#elif defined(__CC_PLATFORM_MAC)

	[director_ runWithScene:[SapusIntroNode scene] ];
#endif
}


#pragma mark AppDelegate - iOS Callbacks

#if defined(__CC_PLATFORM_IOS)

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
	
	[[CDAudioManager sharedManager] pauseBackgroundMusic];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ ) {
		if( !isPaused_ && isPlaying_) {
			// Dialog
			UIAlertView *pauseAlert = [[UIAlertView alloc]
									   initWithTitle:@"Game Paused"
									   message:nil
									   delegate:self
									   cancelButtonTitle:nil
									   otherButtonTitles:@"Resume",nil];	
			[pauseAlert show];
			[pauseAlert release];
		} else
			[director_ resume];
	}

	[[CDAudioManager sharedManager] resumeBackgroundMusic];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
	
	[director_ purgeCachedData];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[director_ purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[director_ setNextDeltaTimeZero:YES];
}


#pragma mark AppDelegate - UIAlertView delegate (iOS)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[[CCDirector sharedDirector] resume];
	return;
}

#elif defined(__CC_PLATFORM_MAC)

#pragma mark AppDelegate - Window callbacks (Mac)

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

#endif

#pragma mark AppDelegate - Shared method between iOS and Mac
- (void)dealloc
{
	[window_ release];
	[super dealloc];
}

-(void) initRandom
{
	struct timeval t;
	gettimeofday(&t, nil);
	NSUInteger i = t.tv_sec;
	i += t.tv_usec;
	srandom((unsigned int)i);
}
#pragma mark AppDelegate - Setup Director

#ifdef __CC_PLATFORM_IOS

-(void) setupRootViewController
{
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];	
}

-(void) setupDirectorIOS
{
	// Don't call super
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// Create an CCGLView with a RGB8 color buffer without a depth buffer
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0			// GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
	
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director_ setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		if( ! [director_ enableRetinaDisplay:YES] )
			CCLOG(@"Retina Display Not supported");
	}
	
	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
//	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"		
}

// Support only landscape mode
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if( ! isPlaying_ )
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	return NO;
}

#elif defined(__CC_PLATFORM_MAC)

-(void) setupDirectorMac
{
	director_ = (CCDirectorMac*)[CCDirector sharedDirector];
	
	[director_ setView:glView_];
	
	[director_ setResizeMode:kCCDirectorResize_AutoScale];
	
	[window_ center];
		
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];	
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}


#endif // __CC_PLATFORM_MAC

#pragma mark AppDelegate - Init Sound
// pre load sounds... this prevent a small delay when the sound is played for the 1st time
-(void) preLoadSounds
{
	SimpleAudioEngine *soundEngine = [SimpleAudioEngine sharedEngine];
	
	[soundEngine preloadEffect:@"snd-tap-button.caf"];
	[soundEngine preloadEffect:@"snd-select-monus.caf"];
	[soundEngine preloadEffect:@"snd-select-sapus.caf"];
	[soundEngine preloadEffect:@"snd-select-sapus-burp.caf"];
	[soundEngine preloadEffect:@"snd-gameplay-boing.caf"];
	[soundEngine preloadEffect:@"snd-gameplay-yupi.caf"];
	[soundEngine preloadEffect:@"snd-gameplay-yaaa.caf"];
	[soundEngine preloadEffect:@"snd-gameplay-mama.caf"];
	[soundEngine preloadEffect:@"snd-gameplay-geronimo.caf"];
	[soundEngine preloadEffect:@"snd-gameplay-argh.caf"];
	[soundEngine preloadEffect:@"snd-gameplay-waka.caf"];
	[soundEngine preloadEffect:@"snd-gameplay-ohno.caf"];
}

@end

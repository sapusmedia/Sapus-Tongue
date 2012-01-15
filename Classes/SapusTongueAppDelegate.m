//
//  SapusTongueAppDelegate.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright Sapus Media 2008 - 2011. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

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
@interface SapusTongueAppDelegate (Private)
-(void) setupDirectorIOS;
-(void) setupDirectorMac;
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
- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
	
	CCDirector *director = [CCDirector sharedDirector];
	CGSize size = [director winSize];
	CCSprite *sprite = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		sprite = [CCSprite spriteWithFile:@"Default-Portrait.png"];
	else
		sprite = [CCSprite spriteWithFile:@"Default.png"];
	sprite.position = ccp(size.width/2, size.height/2);
	sprite.rotation = -90;
	[sprite visit];
	[(CCGLView*)[director view] swapBuffers];
}
#endif // __CC_PLATFORM_IOS


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
	// CCDirector / OpenGLview initialization
	//
#ifdef __CC_PLATFORM_IOS
	[self setupDirectorIOS];
#elif __CC_PLATFORM_MAC
	[self setupDirectorMac];
#endif
	
	// This will initialize the score manager
	[[ScoreManager sharedManager] initScores];
		
	// TIP:
	// Sapus Tongue uses almost all of the images with gradients.
	// They look good in 32 bit mode (RGBA8888) but the consume lot of memory.
	// If your game doesn't need such precision in the images, use 16-bit textures.
	// RGBA4444 or RGB5_A1
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// music initialization
	[self preLoadSounds];
		
	CCDirector *director = [CCDirector sharedDirector];
	
	// turn this feature On when testing the speed
//	[director setDisplayFPS:YES];
	
#ifdef __CC_PLATFORM_IOS
	// Removes the startup flicker
	[self removeStartupFlicker];

	// Run the intro Scene
	[director pushScene: [SapusIntroNode scene] ];
	return YES;
#elif defined(__CC_PLATFORM_MAC)
	[director runWithScene:[SapusIntroNode scene] ];
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

#pragma mark SapusTongueAppDelegate - Window callbacks (Mac)

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

#endif

#pragma mark SapusTongueAppDelegate - Shared method between iOS and Mac
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

	// Display Milliseconds Per Frame
	[director_ setDisplayStats:YES];
	
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
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	//	[window_ setRootViewController:rootViewController_];
	[window_ addSubview:navController_.view];
	
	// make main window visible
	[window_ makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];	
}

// Support only landscape mode
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#elif defined(__CC_PLATFORM_MAC)

-(void) setupDirectorMac
{
	CCDirectorMac *director = (CCDirectorMac*)[CCDirector sharedDirector];
	
	[director setView:glView_];
	
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
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

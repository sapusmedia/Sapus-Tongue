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
#import "stiPadHelper.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "RootViewController.h"
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
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
@synthesize isLandscapeLeft=isLandscapeLeft_;
@synthesize window=window_;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@synthesize viewController=viewController_;

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@synthesize glView=glView_;
@synthesize saveScoreWindow=saveScoreWindow_;
@synthesize saveScoreButton=saveScoreButton_;
@synthesize playerNameTextField=playerNameTextField_;
@synthesize displayScoresTableView=displayScoresTableView_;
@synthesize overlayWindow=overlayWindow_;

#endif


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if ST_AUTOROTATE == kSTAutorotationUIViewController
	
	CC_ENABLE_DEFAULT_GL_STATES();
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
	[[director openGLView] swapBuffers];
	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
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
	isLandscapeLeft_ = YES;

	// random initialization
	[self initRandom];
	
	//
	// CCDirector / OpenGLview initialization
	//
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	[self setupDirectorIOS];
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
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
	
	// Removes the startup flicker
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	[self removeStartupFlicker];
#endif //

	// Run the intro Scene
	[director runWithScene: [SapusIntroNode scene] ];
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	return YES;
#endif
}


#pragma mark AppDelegate - iOS Callbacks

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

// Called when an SMS, call or 'turn off' event is executed
// So pause the music & code. This will save energy consuption
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
	[[CDAudioManager sharedManager] pauseBackgroundMusic];
}

//
// Resume everything
// If we were playing the show the "Resume dialog".
//
-(void) applicationDidBecomeActive:(UIApplication *)application
{
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
		[[CCDirector sharedDirector] resume];
	[[CDAudioManager sharedManager] resumeBackgroundMusic];

}

//
// Purge memory, else the application will be shut down
//
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	//
	// Before going background do:
	// 1. removed unused memory
	// 2. Stop animation
	//
	CCDirector *director = [CCDirector sharedDirector];
	[director purgeCachedData];
	[director stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CCDirector *director = [CCDirector sharedDirector];	
	[[director openGLView] removeFromSuperview];
	
	[viewController_ release];
	viewController_ = nil;

	[window_ release];
	window_ = nil;
	
	[director end];		
}

#pragma mark AppDelegate - UIAlertView delegate (iOS)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[[CCDirector sharedDirector] resume];
	return;
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

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

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

-(void) setupDirectorIOS
{
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController_ = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController_.wantsFullScreenLayout = YES;
	
	// Create the EAGLView manually
	EAGLView *glView = [EAGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
#if ST_AUTOROTATE == kSTAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	
//	[director setDisplayFPS:YES];
	
	// make the OpenGLView a child of the view controller
//	[viewController_ setView:glView];
	[viewController_.view addSubview:glView];
	
	// make the View Controller a child of the main window
	[window_ addSubview: viewController_.view];
	
	[window_ makeKeyAndVisible];	
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

-(void) setupDirectorMac
{
	CCDirectorMac *director = (CCDirectorMac*)[CCDirector sharedDirector];
	
	[director setOpenGLView:glView_];
	
	[director setResizeMode:kCCDirectorResize_AutoScale];
		
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];	
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}


#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

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

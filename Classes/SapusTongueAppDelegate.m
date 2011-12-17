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
@synthesize viewController=viewController_, navigationController=navigationController_;

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
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	// Removes the startup flicker
	[self removeStartupFlicker];

	// Run the intro Scene
	[director pushScene: [SapusIntroNode scene] ];
	return YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	[director runWithScene:[SapusIntroNode scene] ];
#endif
}


#pragma mark AppDelegate - iOS Callbacks

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	SapusTongueAppDelegate *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];
	
	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] pause];
	
	[[CDAudioManager sharedManager] pauseBackgroundMusic];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	SapusTongueAppDelegate *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];	
	
	if( [nav visibleViewController] == viewController_ ) {
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
	}
	
	[[CDAudioManager sharedManager] resumeBackgroundMusic];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	SapusTongueAppDelegate *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];	
	
	if( [nav visibleViewController] == viewController_ ) {
		[[CCDirector sharedDirector] stopAnimation];
	}
	
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	SapusTongueAppDelegate *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];	
	
	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] startAnimation];
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

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CCDirector *director = [CCDirector sharedDirector];	
	[[director openGLView] removeFromSuperview];
	
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

	[director setAnimationInterval:1.0/60];
	
	[director setDisplayStats:kCCDirectorStatsFPS];
	
	// Init the View Controller
	viewController_ = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController_.wantsFullScreenLayout = YES;
	
	// make the OpenGLView a child of the view controller
	[viewController_ setView:glView];
	
	navigationController_ = [[UINavigationController alloc] initWithRootViewController:viewController_];
	navigationController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navigationController_];
	
	[viewController_ release];
	[navigationController_ release];
	
	[window_ makeKeyAndVisible];	
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
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

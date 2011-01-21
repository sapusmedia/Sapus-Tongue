//
//  SapusTongueAppDelegate.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright Sapus Media 2008 - 2011. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import "cocos2d.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

@class RootViewController;

@interface SapusTongueAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow			*window_;
	
	RootViewController	*viewController_;
	
	// is paused
	BOOL				isPaused_;
	BOOL				isPlaying_;
	
	// Needed by the accelerometer
	BOOL				isLandscapeLeft_;
	
}

@property (nonatomic, readwrite) BOOL isPaused, isPlaying;
@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, readwrite) BOOL isLandscapeLeft;
@property (nonatomic, readwrite, retain) RootViewController *viewController;

-(void) initRandom;
-(void) preLoadSounds;

@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@class BDSKOverlayWindow;

@interface SapusTongueAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow			*window_;	// Main Window
	MacGLView			*glView_;	// MacGLView
	
	// Save Score Window
	NSWindow			*saveScoreWindow_;
	NSButton			*saveScoreButton_;
	NSTextField			*playerNameTextField_;
	
	// Display Scores
	BDSKOverlayWindow	*overlayWindow_;
	NSTableView			*displayScoresTableView_;

	// is paused
	BOOL				isPaused_;
	BOOL				isPlaying_;
	
	// Needed by the accelerometer
	BOOL				isLandscapeLeft_;
	
	
}

/** main window */
@property (assign) IBOutlet NSWindow	*window;

/** opengl view */
@property (assign) IBOutlet MacGLView	*glView;

/* Save Score Window properties */
@property (assign) IBOutlet NSWindow	*saveScoreWindow;
@property (assign) IBOutlet NSButton	*saveScoreButton;
@property (assign) IBOutlet NSTextField	*playerNameTextField;

/* display score table view */
@property (assign) IBOutlet BDSKOverlayWindow	*overlayWindow;
@property (assign) IBOutlet NSTableView	*displayScoresTableView;

@property (nonatomic, readwrite) BOOL isPaused, isPlaying;
@property (nonatomic, readwrite) BOOL isLandscapeLeft;

// Callback from IB
- (IBAction)toggleFullScreen:(id)sender;

-(void) initRandom;
-(void) preLoadSounds;

@end

#endif


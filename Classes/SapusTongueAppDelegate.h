//
//  SapusTongueAppDelegate.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright Sapus Media 2008 - 2011. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import "cocos2d.h"

#if defined(__CC_PLATFORM_IOS)

@class RootViewController;

@interface SapusTongueAppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow				*window_;
	UINavigationController	*navController_;
	CCDirectorIOS			*director_;							// weak ref

	// is paused
	BOOL				isPaused_;
	BOOL				isPlaying_;	
}

@property (nonatomic, readwrite) BOOL isPaused, isPlaying;
@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

-(void) initRandom;
-(void) preLoadSounds;

@end

#elif defined(__CC_PLATFORM_MAC)

@class BDSKOverlayWindow;

@interface SapusTongueAppDelegate : NSObject <NSApplicationDelegate, CCDirectorDelegate>
{
	NSWindow		*window_;
	CCGLView		*glView_;
	CCDirectorMac	*director_;							// weak ref
	
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
}

/** main window */
@property (assign) IBOutlet NSWindow	*window;

/** opengl view */
@property (assign) IBOutlet CCGLView	*glView;

/** director */
@property (nonatomic, readonly) CCDirectorMac	*director;

/* Save Score Window properties */
@property (assign) IBOutlet NSWindow	*saveScoreWindow;
@property (assign) IBOutlet NSButton	*saveScoreButton;
@property (assign) IBOutlet NSTextField	*playerNameTextField;

/* display score table view */
@property (assign) IBOutlet BDSKOverlayWindow	*overlayWindow;
@property (assign) IBOutlet NSTableView	*displayScoresTableView;

@property (nonatomic, readwrite) BOOL isPaused, isPlaying;

// Callback from IB
- (IBAction)toggleFullScreen:(id)sender;

-(void) initRandom;
-(void) preLoadSounds;

@end

#endif // __CC_PLATFORM_MAC


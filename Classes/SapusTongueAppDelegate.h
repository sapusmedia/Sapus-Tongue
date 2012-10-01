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

#import "cocos2d.h"

#if defined(__CC_PLATFORM_IOS)

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface SapusTongueAppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow				*window_;
	MyNavigationController	*navController_;
	CCDirectorIOS			*director_;							// weak ref

	// is paused
	BOOL				isPaused_;
	BOOL				isPlaying_;	
}

@property (nonatomic, readwrite) BOOL isPaused, isPlaying;
@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
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


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
// This file contains a "SaveScoreExtesion" of GameHUD
//
// TIP:
// In objective-c it is possible to extend a class without subclassing.
// "extend" means that you can add methods to a certain class. It is not necessary to
// have the source code of the class that you wish to extend. A single class can have multiple
// source code files.
// You can extend any class, even NSString or NSObject.
//

#import "SapusConfig.h"
#import "GameHUDSaveScore.h"
#import "GameHUDAlertDialog.h"
#import "SapusTongueAppDelegate.h"
#import "LocalScore.h"
#import "GameNode.h"
#import "SelectCharNode.h"
#import "HiScoresNode.h"
#import "ScoreManager.h"
#import "cocos2d.h"



// global variable that remembers the entered name.
static NSString *_oldName = @"";

@implementation GameHUD (SaveScoreExtension)

#pragma mark Scores Submitting

#pragma mark -
#pragma mark GameHUD SaveScoreExtension - Common to iOS and Mac

-(void) gotoHiScores
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFlipY transitionWithDuration:1.0f scene:[HiScoresNode sceneWithPlayAgain:YES] ] ];
}

-(void) submitLocalScoreWithName:(NSString*) playername
{
	ScoreManager *scoreMgr = [ScoreManager sharedManager];

	int a = game_->throwAngle_ + 180;
	if( a < 0 )
		a += 360;	
	
	LocalScore *score = [[LocalScore alloc] init];
	score.playername = playername;
	score.score = [NSNumber numberWithInt: [GameNode score]] ;
	score.angle = [NSNumber numberWithInt: a];
	score.speed = [NSNumber numberWithInt: game_->throwVelocity_];
	score.playerType = [NSNumber numberWithInt: [SelectCharNode selectedChar]];
	
	[score insertIntoDatabase: [scoreMgr database]];
	
	[score release];
	
	[scoreMgr loadScoresFromDB];	
}

#pragma mark -
#pragma mark GameHUD SaveScoreExtension - iOS

#ifdef __CC_PLATFORM_IOS

-(void) saveScoreButtonPressed
{
	// UIKit text field
	//
	// TIP:
	//  UIKit controls are "incompatible" with cocos2d Scenes,
	//  they must be treaded independentely.
	//  You can't add them to an Scene, Layer or Node.
	//  The recommended way is to add them as a subView of the RootViewController
	
	state = kHUDRemoveMenu;
	nameField_ = [self newTextField_Rounded];
	
	CGRect frame;

	CGSize s = [[CCDirector sharedDirector] winSize];
	frame = CGRectMake(s.width/2-100, 80, 200, 36);
	nameField_.frame = frame;
	
	if( [_oldName length] > 0 )
		nameField_.text = _oldName;
	
	// Add the control to "cocos2d"... this is the only way to add them
	SapusTongueAppDelegate *app = (SapusTongueAppDelegate*)[[UIApplication sharedApplication] delegate];
	UIViewController *viewController = [app navController];
	
	[viewController.view addSubview:nameField_];

	[nameField_ becomeFirstResponder];
	
	// TIP:
	//   Disable all cocos2d events when dealing ONLY with UIKit objects
	//   eg: The "pause" button can't be touched now
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] setDispatchEvents: NO];
}

-(void) submitScore
{
	NSString *playername = nameField_.text;
	if( playername == nil )
		playername = @"Anonymous";
	else {
		if( [_oldName length] > 0 )
			[_oldName release];
		_oldName = [playername copy];
	}
	
	// Always post score to local DB
	[self submitLocalScoreWithName: playername];	
}

//
// text field related
//

#pragma mark UILabel, UISwitch & UITextField creation
- (UITextField *)newTextField_Rounded
{
	UITextField *returnTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	
	returnTextField.borderStyle = UITextBorderStyleRoundedRect;
	returnTextField.textColor = [UIColor blackColor];
	returnTextField.font = [UIFont fontWithName:@"Marker Felt" size:22];
	returnTextField.placeholder = @"<enter your name>";
	returnTextField.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
	
	returnTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	returnTextField.textAlignment = UITextAlignmentCenter;
	
	returnTextField.keyboardType = UIKeyboardTypeDefault;
	returnTextField.returnKeyType = UIReturnKeyDone;
	
	returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	returnTextField.delegate = self;
	return [returnTextField autorelease];
}

#pragma mark TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
	name_ = tf.text;
	[name_ retain];
	[tf resignFirstResponder];
	
	// re-enable cocos2d events
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] setDispatchEvents: YES];
	
	[self submitScore];
	
	[self gotoHiScores];
	
	[nameField_ removeFromSuperview];
	
	return NO;
}

#elif defined(__CC_PLATFORM_MAC)

#pragma mark -
#pragma mark GameHUD SaveScoreExtension - Mac

-(void) saveScoreButtonPressed
{
	SapusTongueAppDelegate *appDelegate = [NSApp delegate];
	NSWindow *win = [appDelegate saveScoreWindow];
	[win makeKeyAndOrderFront:nil]; // to show it
	
	NSButton *saveScore = [appDelegate saveScoreButton];
	[saveScore setTarget:self];
	[saveScore setAction:@selector(saveButtonPressed:)];
	[NSApp runModalForWindow:win];
}

-(void) saveButtonPressed:(id)sender
{
	SapusTongueAppDelegate *appDelegate = [NSApp delegate];

	_oldName= [[appDelegate playerNameTextField] stringValue];
	
	[self submitLocalScoreWithName:_oldName];

	NSWindow *win = [appDelegate saveScoreWindow];
	[win orderOut:nil]; // hide it	
	[NSApp stopModalWithCode:NSOKButton];
	
	[self gotoHiScores];
}

#endif // __CC_PLATFORM_MAC


@end

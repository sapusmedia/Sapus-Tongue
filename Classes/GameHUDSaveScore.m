//
//  GameHUDSaveScore.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 8/28/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


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

#ifdef __CC_PLATFORM_IOS
#import "cocoslive.h"
#import "RootViewController.h"
#endif



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

-(void) submitGlobalScoreWithName:(NSString*) playername
{
	[activityIndicator_ startAnimating];
	
	int a = game_->throwAngle_ + 180;
	if( a < 0 )
		a += 360;	
	
	//
	// using cocoslive to submit the score
	//
	CLScoreServerPost *server = [[CLScoreServerPost alloc] initWithGameName:@"SapusTongue2" gameKey:@"538654d0bffedd90d626c6d77f48b18c" delegate:self];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
	
	NSString *category;
	
	// TIP: If you are going to do an Universal application (iPad + iPhone)
	// then you should do runtime checks, like the following:
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		category = @"iPad";
	else
		category = @"iPhone";
	
	// usr_ are fields that can be modified. user fields
	[dict setObject: [NSNumber numberWithInt:[GameNode score]] forKey:@"cc_score"];	
	[dict setObject: [NSNumber numberWithInt:(int)game_->throwVelocity_] forKey:@"usr_speed"];
	[dict setObject: [NSNumber numberWithInt:a] forKey:@"usr_angle"];
	[dict setObject: playername forKey:@"cc_playername"];	
	[dict setObject: [NSNumber numberWithInt:[SelectCharNode selectedChar]] forKey:@"usr_playertype"];
	[dict setObject: category forKey:@"cc_category"];
	
	// "update score" is the recommend way since it can be treated like a profile
	// It also supports "world ranking". eg: "What's my ranking ?"
	BOOL ok = [server updateScore:dict];	
	
	if( ! ok ) {
		[activityIndicator_ stopAnimating];
	}
	
	[server release];
}
-(void) scorePostOk: (id) sender
{
	[activityIndicator_ stopAnimating];
	[self gotoHiScores];
}

-(void) scorePostFail: (id) sender
{
	// Score Post Failed. Show Dialog.
	[self scorePostFailedShowAlert];
}

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
	
	
	//	[nameField release];
	
	//
	// create the UItoolbar_ at the bottom of the view controller
	// Only in the paid version
	// The toolbar_ sais: "Submit score to global server: YES/NO?"
	//
	// TIP:
	//   If you are going to submit data to the internet you must inform the user
	//   otherwise the game will be rejected by Apple
	//
#if ! LITE_VERSION	
	
	toolbar_ = [UIToolbar new];
	toolbar_.barStyle = UIBarStyleDefault;
	
	switchCtl_ = [[UISwitch alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 94, 27) ];
	ScoreManager *scoreMgr = [ScoreManager sharedManager];
	switchCtl_.on = scoreMgr.sendGlobalScores;
	[switchCtl_ addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
	switchCtl_.backgroundColor = [UIColor clearColor];
	UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:switchCtl_];
	[switchCtl_ release];
	
	frame = CGRectMake(0, 0.0f, 290.0f, 20);
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.textAlignment = UITextAlignmentRight;
	label.text = @"Submit score to global server:";
	label.font = [UIFont boldSystemFontOfSize:14.0f];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor colorWithRed:76.0f/255.0f green:86.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
	UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:label];
	[label release];
	
	NSArray *items = [NSArray arrayWithObjects: labelItem, customItem, nil];
	toolbar_.items = items;
	[customItem release];
	[labelItem release];
	
	// size up the toolbar_ and set its frame
	[toolbar_ sizeToFit];
	CGFloat toolbarHeight = [toolbar_ frame].size.height;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		toolbar_.frame = CGRectMake(0, s.height/2-12, s.width, toolbarHeight);
	else 
		toolbar_.frame = CGRectMake(0, s.height/2-34, s.width, toolbarHeight);
	
	[viewController.view addSubview:toolbar_];
	
#else // LITE_VERSION
	switchCtl_ = nil;
	toolbar_ = nil;
#endif // LITE_VERSION
	
	
	//	[toolbar_ release];
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
	
	// Only post it if "submit score" is enabled.
	// TIP:
	//   nil objects can receive selectors.
	//   switchCtl is nil in the Lite version
	//   and it will return False.
	//   It is OK to deal with nil objects in obj-c.
	if( switchCtl_.on )
		[self submitGlobalScoreWithName: playername];
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
	
	if( ! switchCtl_.on )
		[self gotoHiScores];
	
	[nameField_ removeFromSuperview];
	[toolbar_ removeFromSuperview];
	
	return NO;
}

//
- (void)switchAction:(id)sender
{
	[[ScoreManager sharedManager] setSendGlobalScores:switchCtl_.on];
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

//
//  GameHUDAlertDialog.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 8/28/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "GameHUDAlertDialog.h"
#import "GameHUDSaveScore.h"
#import "SapusTongueAppDelegate.h"
#import "GameNode.h"
#import "MainMenuNode.h"

@implementation GameHUD (AlertExtension)


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#pragma mark GameHUD - AlertExtension iOS

-(void) pauseButtonPressedShowAlert
{
	[[CCDirector sharedDirector] pause];	
	SapusTongueAppDelegate *appDelegate = (SapusTongueAppDelegate*) [[UIApplication sharedApplication] delegate];	
	
	appDelegate.isPaused = YES;
	
	// Dialog
	UIAlertView *alert = [[UIAlertView alloc] init];
	alert.tag = kTagPauseAlert;
	[alert setDelegate:self];
	[alert setTitle:@"Game Paused"];
	//	[alert setMessage:@"Game Paused"];
	[alert addButtonWithTitle:@"Resume"];
	[alert addButtonWithTitle:@"Restart"];
	[alert addButtonWithTitle:@"Menu"];
	[alert show];
	[alert release];
}

//
// This is the delegate of all possible AlertViews
//
// Possible alert views:
//    Game is paused (by pressing the pause button)
//    Score Post Failed (only non-lite version)
//
// TIP:
//   UIKit object as well as cocos2d objects has a tag attribute.
//   Use it. It is your friend.

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch( alert.tag ) {
		case kTagPauseAlert:
			[[CCDirector sharedDirector] resume];
			SapusTongueAppDelegate *appDelegate = (SapusTongueAppDelegate*) [[UIApplication sharedApplication] delegate];	
			appDelegate.isPaused = NO;
			
			if(buttonIndex == 0) { // go back to game. resume
				return;
			} else if(buttonIndex == 1) { // restart
				game->state_ = kGameIsBeingReplaced;
				[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene: [GameNode scene] ]];
				
			} else if(buttonIndex == 2) { // go to main menu
				[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene: [MainMenuNode scene]]];
			}
			break;
		case kTagConnectionFailedAlert:
			// Connection Failed -> User ACK -> Then display the high score scene
			[self gotoHiScores];
			break;
		default:
			NSLog(@"GameHud: Invalid alert tag");
	}
}

-(void) scorePostFailedShowAlert
{	
	[activityIndicator stopAnimating];	

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection failed"
														message:@"Make sure that you have an active cellular or WiFi connection."
													   delegate:self
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	alertView.tag = kTagConnectionFailedAlert;
	[alertView show];
	[alertView release];	
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#pragma mark GameHUD - AlertExtension MAC

-(void) scorePostFailedShowAlert
{
}
-(void) pauseButtonPressedShowAlert
{
	[[CCDirector sharedDirector] pause];	
	SapusTongueAppDelegate *appDelegate = [NSApp delegate];	
	
	appDelegate.isPaused = YES;
		
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Resume"];
	[alert addButtonWithTitle:@"Restart"];
	[alert addButtonWithTitle:@"Menu"];
	[alert setMessageText:@"Game Paused"];
	[alert setAlertStyle:NSInformationalAlertStyle];
	
	NSInteger ret = [alert runModal];

	[[CCDirector sharedDirector] resume];

	switch (ret) {
		case NSAlertFirstButtonReturn:
			// resume
			break;
		case NSAlertSecondButtonReturn:
			// Restart
			game->state_ = kGameIsBeingReplaced;
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene: [GameNode scene] ]];
			break;
		case NSAlertThirdButtonReturn:
			// Main Menu
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene: [MainMenuNode scene]]];
			break;
	} 
}

#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

@end

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


#import "GameHUDAlertDialog.h"
#import "GameHUDSaveScore.h"
#import "SapusTongueAppDelegate.h"
#import "GameNode.h"
#import "MainMenuNode.h"

@implementation GameHUD (AlertExtension)


#ifdef __CC_PLATFORM_IOS

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
				game_->state_ = kGameIsBeingReplaced;
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
	[activityIndicator_ stopAnimating];	

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection failed"
														message:@"Make sure that you have an active cellular or WiFi connection."
													   delegate:self
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	alertView.tag = kTagConnectionFailedAlert;
	[alertView show];
	[alertView release];	
}

#elif defined(__CC_PLATFORM_MAC)

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
			game_->state_ = kGameIsBeingReplaced;
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene: [GameNode scene] ]];
			break;
		case NSAlertThirdButtonReturn:
			// Main Menu
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene: [MainMenuNode scene]]];
			break;
	} 
}

#endif // __CC_PLATFORM_MAC

@end

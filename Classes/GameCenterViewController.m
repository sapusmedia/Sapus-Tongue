    //
//  GameCenterViewController.m
//  SapusTongue-iOS
//
//  Created by Ricardo Quesada on 10/8/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import "GameCenterViewController.h"
#import "SapusTongueAppDelegate.h"
#import "CCScheduler.h"

@implementation GameCenterViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

// TIP:
// If you want to support multitple orientations on the Game Center dialog,
// then return YES for the supported orientations.
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark GameCenterViewController - Leaderboard
-(void) showLeaderboard
{	
	// TIP:
	// You can't reuse the RootViewController since it is used to rotate the cocos2d view.
	// To prevent any possible issue with autorotation, a new ViewController should be used 
	
	// TIP 2:
	// If the view controller is added at "init" time, then no touches will be propagated to the
	// cocos2d view controller. So we should only add this new view controller when we want
	// to display the game center panel, and we must destroy it after using it.
	
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != nil) 
	{		
		// Obtain the Main Window
		SapusTongueAppDelegate *appDelegate = (SapusTongueAppDelegate*) [[UIApplication sharedApplication] delegate];

		UIWindow *window = [appDelegate window];
		[window addSubview:self.view];

//		leaderboardController.category = self.currentLeaderBoard;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self;
				
		[self presentModalViewController:leaderboardController animated: YES];
		
		[[CCDirector sharedDirector] stopAnimation];
		
	}	
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self dismissModalViewControllerAnimated:YES];
	[viewController release];

	[NSTimer scheduledTimerWithTimeInterval:0.4f
									 target:self
								   selector:@selector(removeGameCenterView:)
								   userInfo:nil
									repeats:NO];
}

#pragma mark GameCenterViewController - Achievements

-(void) showAchievements
{
	// TIP:
	// You can't reuse the RootViewController since it is used to rotate the cocos2d view.
	// To prevent any possible issue with autorotation, a new ViewController should be used 
	
	// TIP 2:
	// If the view controller is added at "init" time, then no touches will be propagated to the
	// cocos2d view controller. So we should only add this new view controller when we want
	// to display the game center panel, and we must destroy it after using it.
	
	GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
	if (achivementViewController != nil) 
	{		
		// Obtain the Main Window
		SapusTongueAppDelegate *appDelegate = (SapusTongueAppDelegate*) [[UIApplication sharedApplication] delegate];
		
		UIWindow *window = [appDelegate window];
		[window addSubview:self.view];
		
		achivementViewController.achievementDelegate = self;
		[self presentModalViewController:achivementViewController animated: YES];
		
		[[CCDirector sharedDirector] stopAnimation];
	}	
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[self dismissModalViewControllerAnimated:YES];
	[viewController release];
	
	[NSTimer scheduledTimerWithTimeInterval:0.4f
									 target:self
								   selector:@selector(removeGameCenterView:)
								   userInfo:nil
									repeats:NO];	
}


#pragma mark GameCenterViewController - Helper

-(void) removeGameCenterView:(id)userInfo
{
	[self.view removeFromSuperview];

	[[CCDirector sharedDirector] startAnimation];
	
	// Obtain the Main Window
	SapusTongueAppDelegate *appDelegate = (SapusTongueAppDelegate*) [[UIApplication sharedApplication] delegate];	
	UIWindow *mainWindow = [appDelegate window];
	RootViewController *rootViewController = [appDelegate viewController];

	[rootViewController retain];
	[[rootViewController view] removeFromSuperview];
	[mainWindow addSubview: [rootViewController view]];
	[rootViewController release];
	
	// In case the orientation has been changed:
//	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
}

@end

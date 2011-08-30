//
//  HiScoresNode.m
//  Sapus Tongue
//
//  Created by Ricardo Quesada on 18/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

//
// Code that shows the "high score" scene
//   * display world wide scores
//   * display scores by country
//   * display local scores
//
//  uses cocoslive to obtain the scores


#import "SapusConfig.h"
#import "HiScoresNode.h"
#import "MainMenuNode.h"
#import "SoundMenuItem.h"
#import "SapusTongueAppDelegate.h"
#import "LocalScore.h"
#import "GameNode.h"
#import "FloorNode.h"
#import "MountainNode.h"
#import "ScoreManager.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "cocoslive.h"
#import "GameCenterManager.h"
#import "GameCenterViewController.h"
#import "RootViewController.h"
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import "BDSKOverlayWindow.h"
#endif


#define kCellHeight (30)
#define kMaxScoresToFetch (50)

#pragma mark -
#pragma mark HiScoresNode - Shared code between iOS and Mac

@interface HiScoresNode (Private)
-(void) setupBackground;
@end

@implementation HiScoresNode

+(id) sceneWithPlayAgain: (BOOL) again
{
	CCScene *s = [CCScene node];
	id node = [[HiScoresNode alloc] initWithPlayAgain:again];
	[s addChild:node];
	[node release];
	return s;
}

-(id) initWithPlayAgain: (BOOL) again
{
	if( (self=[super init]) ) {
	
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCSprite *back = [CCSprite spriteWithFile:@"SapusScores.png"];
		back.anchorPoint = ccp(0.5f, 0.5f);
		back.position = ccp(s.width/2, s.height/2);
		[self addChild:back z:0];

		// CocosLive server is only supported on iOS
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		// local Scores
		displayLocalScores_ = YES;

		CCMenuItem *worldScores = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-world-normal.png" selectedSpriteFrameName:@"btn-world-selected.png" target:self selector:@selector(globalScoresCB:)];
		CCMenuItem *countryScores = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-country-normal.png" selectedSpriteFrameName:@"btn-country-selected.png" target:self selector:@selector(countryScoresCB:)];
		CCMenuItem *myScores = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-my_scores-normal.png" selectedSpriteFrameName:@"btn-my_scores-selected.png" target:self selector:@selector(localScoresCB:)];

		CCMenuItem *gameCenter = nil;
		if( [GameCenterManager isGameCenterAvailable] ) {
			gameCenter = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-game_center-normal.png" selectedSpriteFrameName:@"btn-game_center-selected.png" target:self selector:@selector(gameCenterCB:)];
		}
		
		CCMenu *menuV = nil;
		if ( gameCenter )
			menuV = [CCMenu menuWithItems: gameCenter, worldScores, countryScores, myScores, nil];
		else
			menuV = [CCMenu menuWithItems: worldScores, countryScores, myScores, nil];

		[menuV alignItemsVertically];
		if( gameCenter )
			menuV.position = ccp(s.width/2+192,s.height/2+20);
		else
			menuV.position = ccp(s.width/2+192,s.height/2+40);

		
		[self addChild: menuV z:0];
		
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED

		CCMenu *menuH;
		CCMenuItem* menuItem = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-menumed-normal.png" selectedSpriteFrameName:@"btn-menumed-selected.png" target:self selector:@selector(menuCB:)];

		// Menu
		if( ! again ) {
			menuH = [CCMenu menuWithItems: menuItem, nil];
		}
		else {
			CCMenuItem* itemAgain = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-playagain-normal.png" selectedSpriteFrameName:@"btn-playagain-selected.png" target:self selector:@selector(playAgainCB:)];
			menuH = [CCMenu menuWithItems: itemAgain, menuItem, nil];
		}
		
		[menuH alignItemsHorizontally];
		if( ! again )
			menuH.position = ccp(s.width/2+180,s.height/2-143);
		else
			menuH.position = ccp(s.width/2+120,s.height/2-143);


		[self addChild: menuH z:0];
		
		[self setupBackground];

	}

	return self;
}

-(void) setupBackground
{	
	// Only iPad version
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#endif
	{
		// tree
		CCSprite *tree = [CCSprite spriteWithFile:@"tree1.png"];
		tree.anchorPoint = CGPointZero;
		[self addChild:tree z:-1];
		
		// tile map
		CCTMXTiledMap *tilemap = [CCTMXTiledMap tiledMapWithTMXFile:@"tilemap.tmx"];
		
		[self addChild:tilemap z:-5];
		
		//
		// TIP #1:release the internal map. Only needed if you are going
		// to read it or write it
		//
		// TIP #2: Since the tilemap was preprocessed using cocos2d's spritesheet-artifact-fixer.py
		// there is no need to use aliased textures, we can use antialiased textures.
		//
		
		for( CCTMXLayer *layer in [tilemap children] ) {
			[layer releaseMap];
			[[layer texture] setAntiAliasTexParameters];
		}
		
		// floor
		FloorNode *floor = [FloorNode node];
		[self addChild:floor z:-6];
		
		// mountains	
		MountainNode *mountain = [MountainNode node];
		CCParallaxNode *parallax = [CCParallaxNode node];
		[parallax addChild:mountain z:0 parallaxRatio:ccp(0.3f, 0.3f) positionOffset:ccp(0,0)];
		[self addChild:parallax z:-7];
	}

	
	// gradient
	CCLayerGradient *g = [CCLayerGradient layerWithColor:ccc4(0,0,0,255) fadingTo:ccc4(0,0,0,255) alongVector:ccp(0,1)];
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[g setStartColor:ccc3(0xb3, 0xe2, 0xe6)];
		[g setEndColor:ccc3(0,0,0)];
	} else {
		[g setStartColor:ccc3(0xb3, 0xe2, 0xe6)];
		[g setEndColor:ccc3(0x93,0xc2,0xc6)];
	}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	[g setStartColor:ccc3(0xb3, 0xe2, 0xe6)];
#endif
	
	[self addChild: g z:-10];	
}

-(void) dealloc
{
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];	

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	[activityIndicator_ release];
	[myTableView_ release];	
	[gameCenterViewController_ release];
#endif

	[super dealloc];
}

-(void) menuCB:(id) sender
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	if( activityIndicator_ ) {
		[activityIndicator_ removeFromSuperview];
		[activityIndicator_ release];
		activityIndicator_ = nil;
	}
	
	if( myTableView_ ) {
		[myTableView_ removeFromSuperview];
		[myTableView_ release];
		myTableView_ = nil;
	}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	SapusTongueAppDelegate *delegate = [NSApp delegate];
	[[delegate overlayWindow] remove];
#endif
//	[[CCDirector sharedDirector] replaceScene: [CCTransitionSplitRows transitionWithDuration:1.0f scene: [MainMenuNode scene]]];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionRadialCW transitionWithDuration:1.0f scene: [MainMenuNode scene]]];

}

-(void) playAgainCB:(id) sender
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	if( activityIndicator_ ) {
		[activityIndicator_ removeFromSuperview];
		[activityIndicator_ release];
		activityIndicator_ = nil;
	}
	
	if( myTableView_ ) {
		[myTableView_ removeFromSuperview];
		[myTableView_ release];
		myTableView_ = nil;
	}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	SapusTongueAppDelegate *delegate = [NSApp delegate];
	[[delegate overlayWindow] remove];
#endif
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene: [GameNode scene]]];
}


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#pragma mark -
#pragma mark HiScoresNode - iOS Only

// table view
-(UITableView*) newTableView
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
	tv.delegate = self;
	tv.dataSource = self;
	
	tv.opaque = YES;
	tv.frame = CGRectMake( s.width/2-234, s.height/2-86, 380, 210 );
		
	return tv;
}

//
// TIP:
// The heavy part of init and the UIKit controls are initialized after the transition is finished.
// This trick is used to:
//    * create a smooth transition (load heavy resources after the transition is finished)
//    * show UIKit controls after the transition to simulate that they transition like any other control
//
-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];

	SapusTongueAppDelegate *app = [[UIApplication sharedApplication] delegate];
	UIViewController *ctl = [app viewController];		

	// activity indicator
	if( ! activityIndicator_ ) {
		activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
		
//		CGSize s = [[CCDirector sharedDirector] winSize];
		activityIndicator_.frame = CGRectMake(10, 10, 40, 40);
		
		[ctl.view addSubview: activityIndicator_];

		activityIndicator_.hidesWhenStopped = YES;
		activityIndicator_.opaque = YES;
	}
	
	// table
	if( !myTableView_ )
		myTableView_ = [self newTableView];

	[ctl.view addSubview: myTableView_];	
}

// menu callbacks
-(void) globalScoresCB: (id) sender
{	
	CLScoreServerRequest *request = [[CLScoreServerRequest alloc] initWithGameName:@"SapusTongue2" delegate:self];

	NSString *category;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		category = @"iPad";
	else
		category = @"iPhone";

	if( [request requestScores:kQueryAllTime limit:kMaxScoresToFetch offset:0 flags:kQueryFlagIgnore category:category] )
		[activityIndicator_ startAnimating];
	[request release];
}

-(void) countryScoresCB: (id) sender
{	
	CLScoreServerRequest *request = [[CLScoreServerRequest alloc] initWithGameName:@"SapusTongue2" delegate:self];
	
	NSString *category;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		category = @"iPad";
	else
		category = @"iPhone";
	
	if( [request requestScores:kQueryAllTime limit:kMaxScoresToFetch offset:0 flags:kQueryFlagByCountry category:category] )
		[activityIndicator_ startAnimating];
	[request release];
}


-(void) localScoresCB: (id) sender
{	
	displayLocalScores_ = YES;
	[myTableView_ reloadData];
}

-(void) gameCenterCB:(id) sender
{
	if( ! gameCenterViewController_ )
		gameCenterViewController_ = [[GameCenterViewController alloc] init];
	
	[gameCenterViewController_ showAchievements];
}


#pragma mark HiScoresNode - GlobalScore Delegate (iOS)
-(void) scoreRequestOk: (id) sender
{
	displayLocalScores_ = NO;

	// scores shall is autoreleased... I guess
	NSArray *scores = [sender parseScores];
	
	NSMutableArray *mutable = [NSMutableArray arrayWithArray:scores];
	[[ScoreManager sharedManager] setGlobalScores:mutable];
	
	[activityIndicator_ stopAnimating];
	[myTableView_ reloadData];	
}

-(void) scoreRequestFail: (id) sender
{
	[activityIndicator_ stopAnimating];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection failed"
														message:@"Make sure that you have an active cellular or WiFi connection."
														delegate:self
														cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];	
}


#pragma mark HiScoresNode - UITableViewDataSouce (iOS)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	ScoreManager *scoreMgr = [ScoreManager sharedManager];
	if( displayLocalScores_ )
		return [[scoreMgr scores] count];
	else
		return [[scoreMgr globalScores] count];
}

-(void) setImage:(UIImage*)image inTableViewCell:(UITableViewCell*)cell
{
	cell.imageView.image = image;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *MyIdentifier = @"HighScoreCell";
	
	UILabel *name, *score, *idx, *speed, *angle;
	UIView *view;
	UIImageView *imageView;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
//		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
		cell.opaque = YES;

		// Position
		idx = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24, kCellHeight-2)];
		idx.tag = 3;
		//		name.font = [UIFont boldSystemFontOfSize:16.0f];
		idx.font = [UIFont fontWithName:@"Marker Felt" size:16.0f];
		idx.adjustsFontSizeToFitWidth = YES;
		idx.textAlignment = UITextAlignmentRight;
		idx.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
		idx.autoresizingMask = UIViewAutoresizingFlexibleRightMargin; 
		[cell.contentView addSubview:idx];
		[idx release];
		
		// Name
		name = [[UILabel alloc] initWithFrame:CGRectMake(65.0f, 0.0f, 150, kCellHeight-2)];
		name.tag = 1;
//		name.font = [UIFont boldSystemFontOfSize:16.0];
		name.font = [UIFont fontWithName:@"Marker Felt" size:16.0f];
		name.adjustsFontSizeToFitWidth = YES;
		name.textAlignment = UITextAlignmentLeft;
		name.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
		name.autoresizingMask = UIViewAutoresizingFlexibleRightMargin; 
		[cell.contentView addSubview:name];
		[name release];
		
		// Score
		score = [[UILabel alloc] initWithFrame:CGRectMake(200, 0.0f, 70.0f, kCellHeight-2)];
		score.tag = 2;
		score.font = [UIFont systemFontOfSize:16.0f];
		score.textColor = [UIColor darkGrayColor];
		score.adjustsFontSizeToFitWidth = YES;
		score.textAlignment = UITextAlignmentRight;
		score.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:score];
		[score release];

		// Speed
		speed = [[UILabel alloc] initWithFrame:CGRectMake(275, 0.0f, 40.0f, kCellHeight-2)];
		speed.tag = 5;
		speed.font = [UIFont systemFontOfSize:16.0f];
		speed.textColor = [UIColor darkGrayColor];
		speed.adjustsFontSizeToFitWidth = YES;
		speed.textAlignment = UITextAlignmentRight;
		speed.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:speed];
		[speed release];
		
		// Angle
		angle = [[UILabel alloc] initWithFrame:CGRectMake(315, 0.0f, 35.0f, kCellHeight-2)];
		angle.tag = 6;
		angle.font = [UIFont systemFontOfSize:16.0f];
		angle.textColor = [UIColor darkGrayColor];
		angle.adjustsFontSizeToFitWidth = YES;
		angle.textAlignment = UITextAlignmentRight;
		angle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:angle];
		[angle release];
				
		// Flag
		view = [[UIImageView alloc] initWithFrame:CGRectMake(360, 10.0f, 16, kCellHeight-2)];
		view.opaque = YES;
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fam.png"]];
		imageView.opaque = YES;
		imageView.tag = 1;
		[view addSubview:imageView];
		[cell.contentView addSubview:view];		
		view.tag = 4;
		[view release];
		[imageView release];
		
	} else {
		name = (UILabel *)[cell.contentView viewWithTag:1];
		score = (UILabel *)[cell.contentView viewWithTag:2];
		idx = (UILabel *)[cell.contentView viewWithTag:3];
		view = (UIView*)[cell.contentView viewWithTag:4];
		imageView = (UIImageView*)[view viewWithTag:1];
		speed = (UILabel *)[cell.contentView viewWithTag:5];
		angle = (UILabel *)[cell.contentView viewWithTag:6];

	}
	
	int i = indexPath.row;
	ScoreManager *scoreMgr = [ScoreManager sharedManager];
	idx.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];

	if(displayLocalScores_) {
		
		LocalScore *s = [[scoreMgr scores] objectAtIndex: i];
		name.text = s.playername;
		score.text = [s.score stringValue];
		speed.text = [s.speed stringValue];
		angle.text = [s.angle stringValue];

		if( [s.playerType intValue] == 1 )
			[self setImage:[UIImage imageNamed:@"MonusHead.png"] inTableViewCell:cell];
		else
			[self setImage:[UIImage imageNamed:@"SapusHead.png"] inTableViewCell:cell];

		imageView.image = nil;	
	} else {
		NSDictionary *s = [[scoreMgr globalScores] objectAtIndex:i];
		name.text = [s objectForKey:@"cc_playername"];
		// this is an NSNumber... convert it to string
		score.text = [[s objectForKey:@"cc_score"] stringValue];
		speed.text = [[s objectForKey:@"usr_speed"] stringValue];
		angle.text = [[s objectForKey:@"usr_angle"] stringValue];

		NSNumber *type = [s objectForKey:@"usr_playertype"];
		if( [type intValue] == 1 )
			[self setImage:[UIImage imageNamed:@"MonusHead.png"] inTableViewCell:cell];

		else
			[self setImage:[UIImage imageNamed:@"SapusHead.png"] inTableViewCell:cell];
		
		NSString *flag = [[s objectForKey:@"cc_country"] lowercaseString];
		UIImage *image;
		image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", flag]];
		if(! image )
			image = [UIImage imageNamed:@"fam.png"];
		imageView.image = image;		
	}
	return cell;
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}


#pragma mark -
#pragma mark HiScoresNode - Mac Only

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	
	SapusTongueAppDelegate *delegate = [NSApp delegate];
	
	// Overlay Window
	[[delegate overlayWindow] overlayView:[[CCDirector sharedDirector] openGLView] ];

	NSTableView *tv = [delegate displayScoresTableView];
	tv.delegate = self;
	tv.dataSource = self;
	
	[tv reloadData];

}

#pragma mark HiScoresNode - NSTableViewDelegate (Mac)


#pragma mark HiScoresNode - NSTableViewDataSource (Mac)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[[ScoreManager sharedManager] scores] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSCell *cell = nil;

	LocalScore *s = [[[ScoreManager sharedManager] scores] objectAtIndex: rowIndex];
	
	NSString *type = [aTableColumn identifier];
	
	if( [type isEqualToString:@"position"] ) {
		cell = [[NSCell alloc] initTextCell: [NSString stringWithFormat:@"%d", rowIndex]];
		
	} else if( [type isEqualToString:@"image"] ) {

		NSString *imageName = @"MonusHead.png";
		if( [s.playerType intValue] == 1 )
			imageName = @"SapusHead.png";

		NSImage *image = [NSImage imageNamed:imageName];
		cell = [[NSCell alloc] initImageCell:image];
		
	} else if( [type isEqualToString:@"name"] ) {
		
		cell = [[NSCell alloc] initTextCell: s.playername];


	} else if( [type isEqualToString:@"score"] ) {
		cell = [[NSCell alloc] initTextCell: [s.score stringValue]];
		
	} else if( [type isEqualToString:@"speed"] ) {
		cell = [[NSCell alloc] initTextCell: [s.speed stringValue]];

	} else if( [type isEqualToString:@"angle"] ) {
		cell = [[NSCell alloc] initTextCell: [s.angle stringValue]];

	}
	
	[cell autorelease];
	return cell;
}


#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

@end

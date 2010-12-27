//
//  GameHUD.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 04/08/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

//
// HUD: Heads Up Display
//   shows Angle, Speed, Score, "Menu game over", and "enter name"
//
// Scores are saved locally (SQLite using the LocalScore class) and in a server using CocosLive service
//

#import "cocos2d.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"

#import "GameHUD.h"
#import "GameHUDSaveScore.h"
#import "GameHUDAlertDialog.h"

#import "SapusConfig.h"
#import "GameNode.h"
#import "SoundMenuItem.h"
#import "MainMenuNode.h"
#import "GradientLayer.h"
#import "SapusTongueAppDelegate.h"
#import "SelectCharNode.h"


#define kProgressBarHeight 30
#define kFontSize 20

// Nodes' tags
enum {
	kTagMenu = 0x1,
};

//
// private methods
//
@interface GameHUD (Private)
-(void) loadPauseButton;
-(void) showTryAgain;
-(void) showViewScores;
-(void) createScore;
-(void) createAngle;
-(void) createSpeed;
-(void) createGlobalScoresVars;
@end

@implementation GameHUD


// Init
- (id) initWithGame: (GameNode*) g
{
	if((self=[super init]) ) {

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
		self.isMouseEnabled = YES;
#endif
		
		// Reference to GameNode
		game = [g retain];
		
		//
		// Initialization
		//
		
		[self createScore];
		[self createAngle];
		[self createSpeed];
		[self createGlobalScoresVars];

		[self loadPauseButton];
		

		[self scheduleUpdate];
		
		state = kHUDGame;
	}
	return self;
}

-(void) dealloc
{
	[game release];
	[scoreAtlas release];
	[arrowSprite release];
	[angleAtlas release];
	[speedAtlas release];
	[speedSprite release];
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED
	[activityIndicator release];
#endif
	
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];	
	
	[super dealloc];
}

#pragma mark HUD - Initialization

-(void) createScore
{	
	CGSize s = [[CCDirector sharedDirector] winSize];

	// TIP:
	// Score is a number is udpated too often. It can't be rendered using normal Label since they are very slow.
	// The only solution to render numbers (or characters) that are updated very often (like scores, times, etc) is
	// to use a CCLabelAtlas or CCBitmapFontAtlas
	scoreAtlas = [[CCLabelAtlas labelWithString:@":::0" charMapFile:@"number_fonts.png" itemWidth:32 itemHeight:48 startCharMap:'0'] retain];
	scoreAtlas.anchorPoint = ccp( 0.5f, 0.5f );

	[self addChild:scoreAtlas z:1];
	scoreAtlas.position = ccp(s.width/2, s.height-32);
	
	CCSprite *score = [CCSprite spriteWithFile:@"score.png"];
	score.position = ccp(s.width/2, s.height-7);
	[self addChild:score];
}

-(void) createGlobalScoresVars
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
	activityIndicator.frame = CGRectMake(20, 20, 20, 20);
	[[[CCDirector sharedDirector] openGLView] addSubview:activityIndicator];
	activityIndicator.hidesWhenStopped = YES;
#endif
}

-(void) createAngle
{
	CGSize s = [[CCDirector sharedDirector] winSize];

	CCSprite *circle = [CCSprite spriteWithFile:@"circle_angle.png"];
	circle.position = ccp(s.width-45,s.height-45);
	[self addChild:circle];
	
	arrowSprite = [[CCSprite spriteWithFile:@"arrow.png"] retain];
	CGSize size = [arrowSprite contentSize];
	arrowSprite.anchorPoint = ccp(2/size.width,2/size.height);
	arrowSprite.position = ccp(s.width-45-1, s.height-45-1);
	[self addChild:arrowSprite z:1];
	
	// Again, a CCLabelAtlas is used to display the angle value
	angleAtlas = [[CCLabelAtlas labelWithString:@"::0" charMapFile:@"number_fonts_small.png" itemWidth:16 itemHeight:24 startCharMap:'0'] retain];
	angleAtlas.anchorPoint = ccp( 0.5f, 0.5f );
	[self addChild:angleAtlas];
	angleAtlas.position = ccp(s.width-45,s.height-88);
}

-(void) createSpeed
{	
	CGSize s = [[CCDirector sharedDirector] winSize];

#define speedY (s.height-150)
	CCSprite *circle = [CCSprite spriteWithFile:@"speed_angle.png"];
	circle.position = ccp(s.width-45,speedY);
	[self addChild:circle];
	
	speedSprite = [[CCSprite spriteWithFile:@"arrow.png"] retain];
	CGSize speedcs = [speedSprite contentSize];
	speedSprite.anchorPoint = ccp(2/speedcs.width,2/speedcs.height);
	speedSprite.position = ccp(s.width-45-1, speedY-10);
	[self addChild:speedSprite z:1];
	
	// Again, a CCLabelAtlas is used to display the speed value
	speedAtlas = [[CCLabelAtlas labelWithString:@"::0" charMapFile:@"number_fonts_small.png" itemWidth:16 itemHeight:24 startCharMap:'0'] retain];
	speedAtlas.anchorPoint = ccp( 0.5f, 0.5f);
	[self addChild:speedAtlas];
	speedAtlas.position = ccp(s.width-45,speedY-40);	
}

-(void) loadPauseButton
{	
	CGSize s = [[CCDirector sharedDirector] winSize];

	// TIP: 
	//   Menu / MenuItem are useful also to display buttons (or any other thing that is clickeable)
	CCMenuItemImage *item = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-pause-normal.png" selectedSpriteFrameName:@"btn-pause-selected.png" target:self selector:@selector(pauseCallback:)];
	CCMenu *menu = [CCMenu menuWithItems:item,nil];
	menu.position = CGPointZero;
	item.position = ccp(20,s.height-20);
	[self addChild: menu];
}

#pragma mark HUD - Main Loop

// called every frame
-(void) update: (ccTime) delta
{	
	// TIP: CCLabelAtas again
	//  Try to avoid updating Labels in main loops, instead use CCLabelAtlas or CCBitmapFontAtlas
	NSString *val = [NSString stringWithFormat:@"%4d", [GameNode score] ];
	val = [val stringByReplacingOccurrencesOfString:@" " withString:(NSString *)@":"];
	[scoreAtlas setString:val];

	// display / hide menu according to the state machine
	if( game->state_ == kGameOver )
		[self showTryAgain];
		
	if ( state == kHUDRemoveMenu ) {
		[self removeChildByTag:kTagMenu cleanup:YES];
 		state = kHUDGame;
	}

	
	{ // angle
		int a = -game->throwAngle_ + 180;
		arrowSprite.rotation = a;

		a = game->throwAngle_ + 180;
		if( a < 0 )
			a += 360;
		val = [NSString stringWithFormat:@"%3d", a ];
		val = [val stringByReplacingOccurrencesOfString:@" " withString:(NSString *)@":"];
		// update angle CCLabelAtlas
		[angleAtlas setString:val];
		
	}

	{ // speed
		speedSprite.rotation = 170 + (200.0f / 1000.0f) * game->throwVelocity_;

		val = [NSString stringWithFormat:@"%3d", (int)game->throwVelocity_ ];
		val = [val stringByReplacingOccurrencesOfString:@" " withString:(NSString *)@":"];
		// update speed CCLabelAtlas
		[speedAtlas setString:val];		
	}
}

#pragma mark HUD - Menu
-(void) showTryAgain
{
	game->state_ = kGameTryAgain;

	SoundMenuItem *item1 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-tryagain-normal.png" selectedSpriteFrameName:@"btn-tryagain-selected.png" target:self selector:@selector(tryAgainCallback:)];
	SoundMenuItem *item2 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-save-normal.png" selectedSpriteFrameName:@"btn-save-selected.png" target:self selector:@selector(saveScoreCallback:)];
	SoundMenuItem *item3 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-menubig-normal.png" selectedSpriteFrameName:@"btn-menubig-selected.png" target:self selector:@selector(menuCallback:)];
	
	CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
	[menu alignItemsVertically];
	[self addChild:menu z:10 tag:kTagMenu];
}

-(void) tryAgainCallback: (id) sender
{
	state = kHUDRemoveMenu;
	[[SimpleAudioEngine sharedEngine] playEffect:@"snd-gameplay-ohno.caf"];

	game->state_ = kGameDrawTongue;
	[self schedule:@selector(addJoint:) interval:0.8f];
	
	// BUG FIX: Pause the monus while it is revolving. This avoids cheating.
	// Only 1.0 seconds after the joint is added
	[self schedule:@selector(pauseRevolutions:) interval:1.0f];
	
	// monus
	if( [SelectCharNode selectedChar] == 1 )
		[game->sapusSprite_ setDisplayFrameWithAnimationName:@"notail" index: game->displayFrame_];
}

// Attach the tongue to the tree
-(void) addJoint:(ccTime) dt
{
	[self unschedule:_cmd];
	[game addJoint];
}

-(void) pauseRevolutions:(ccTime)dt
{
	[self unschedule:_cmd];
	cpBodySetVel( game->sapusBody_, cpvzero);
}

-(void) menuCallback: (id) sender
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene: [MainMenuNode scene] ]];
}

-(void) saveScoreCallback: (id) sender
{
	[self saveScoreButtonPressed];
}

// Displays an AlertView that says "Game Paused. Resume, Restart, Menu"
-(void) pauseCallback: (id) sender
{
	[self pauseButtonPressedShowAlert];
}

@end

//
//  MainMenuNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 06/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

// Main Menu Node
// A simple menu that let's you choose between:
//   * start
//   * instructions
//   * credits
//   * high scores
//   You can turn sound off/on from here
//	It will display ads in the "lite" version


#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"

#import "cocos2d.h"

#import "MainMenuNode.h"
#import "SoundMenuItem.h"
#import "SelectCharNode.h"
#import "CreditsNode.h"
#import "FastGrid.h"
#import "InstructionsNode.h"
#import "HiScoresNode.h"

//
// Only in Sapus Tongue Lite
//
#ifdef LITE_VERSION
#import "BuyNode.h"
#import "SapusTongueAppDelegate.h"
#endif

#ifdef LITE_VERSION
static BOOL firstTime = YES;
#endif

#ifdef LITE_VERSION
#define BACKGROUND_IMAGE @"SapusMenuLite.png"
#else
#define BACKGROUND_IMAGE @"SapusMenu.png"
#endif

@interface MainMenuNode ()
-(void) removeAd;
@end

@implementation MainMenuNode

+(id) scene
{
	// In Lite version it will return 4 times out of 10, the "Buy Node" scene, instead of
	// the Main Menu scene
#ifdef LITE_VERSION
	float r = CCRANDOM_0_1();
	
	if( firstTime ) {
		firstTime = NO;
		r = 1.0f;
	}
	
	if( r < 0.4 ) {
		return [BuyNode scene];
	} else {
#endif
		CCScene *s = [CCScene node];	
		MainMenuNode *node = [MainMenuNode node];
		[s addChild:node];
		return s;
#ifdef LITE_VERSION
	}
#endif
}

+(NSArray*) textureNames
{
			
	return [NSArray arrayWithObjects:
#ifdef LITE_VERSION
			@"SapusMenuLite.png", 
#else
			@"SapusMenu.png", 
#endif
			@"sapus-buttons.png",
			nil];
						
}

-(id) init
{
	if( (self=[super init] )) {
	
		CGSize s = [[CCDirector sharedDirector] winSize];

	// background
		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:BACKGROUND_IMAGE];
		FastGrid *background = [FastGrid gridWithTexture:texture];

//		[background runAction: [CCSequence actions:
//								[CCLiquid actionWithWaves:80 amplitude:2 grid:ccg(20,15) duration:200],
//								[CCStopGrid action],
//								nil] ];

		background.anchorPoint = CGPointZero;
		[self addChild:background z:-1];

		// Menu Items
		CCMenuItemImage *item1 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-play-normal.png" selectedSpriteFrameName:@"btn-play-selected.png" target:self selector:@selector(startCallback:)];
		CCMenuItemImage *item2 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-instructions-normal.png" selectedSpriteFrameName:@"btn-instructions-selected.png" target:self selector:@selector(instructionsCallback:)];
		CCMenuItemImage *item3 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-highscores-normal.png" selectedSpriteFrameName:@"btn-highscores-selected.png" target:self selector:@selector(highScoresCallback:)];
		CCMenuItemImage *item4 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-about-normal.png" selectedSpriteFrameName:@"btn-about-selected.png" target:self selector:@selector(creditsCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, item4, nil];
		[menu alignItemsVertically];
		[self addChild: menu z:2];
		menu.position = ccp(s.width/2,s.height/2-20);

		// Sound ON/OFF button
		SoundMenuItem *soundButton = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-music-on.png" selectedSpriteFrameName:@"btn-music-pressed.png" target:self selector:@selector(musicCallback:)];
		CCAnimation *sounds = [CCAnimation animationWithFrames:nil delay:0.1f];
		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[sounds addFrame:[cache spriteFrameByName:@"btn-music-on.png"]];
		[sounds addFrame:[cache spriteFrameByName:@"btn-music-off.png"]];
		[[CCAnimationCache sharedAnimationCache] addAnimation:sounds name:@"sound"];

		BOOL m = [[SimpleAudioEngine  sharedEngine] mute];
		[(CCSprite*)[soundButton normalImage] setDisplayFrameWithAnimationName:@"sound" index: m ? 1 : 0];

		menu = [CCMenu menuWithItems:soundButton, nil];
		[self addChild: menu z:2];
		menu.position = ccp(20,s.height-20);

		// Buy Sapus Sources
		SoundMenuItem *buyButton = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-buy-normal.png" selectedSpriteFrameName:@"btn-buy-selected.png" target:self selector:@selector(buyCallback:)];	
		menu = [CCMenu menuWithItems:buyButton, nil];
		[self addChild: menu z:0];

#ifdef LITE_VERSION
		// Avoid collision with iAd view
//		menu.position = ccp(427,70);
		menu.position = ccp(s.width-85,170);

		// TIP:
		// runtime check of iAd support.
		// If the iOS suports it (iOS >= 4), then display iAds
		// otherwise, don't display them
		supportsAds_ = NSClassFromString(@"ADBannerView") != nil;

#else
		menu.position = ccp(s.width-50,40);
#endif
	}
	
	return self;
}

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
#ifdef LITE_VERSION

	if( supportsAds_ ) {
		SapusTongueAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		RootViewController *viewController = [appDelegate viewController];
		[viewController createADBannerView];
		
		inStage_ = YES;		
	}
	
#endif // LITE_VERSION	
}

-(void) dealloc
{
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];	
	[super dealloc];
}


#pragma mark Menu callback

-(void) musicCallback: (id) sender {
	BOOL m = [[SimpleAudioEngine  sharedEngine] mute];
	if( m )
		[(CCSprite*)[sender normalImage] setDisplayFrameWithAnimationName:@"sound" index:0];
	else
		[(CCSprite*)[sender normalImage] setDisplayFrameWithAnimationName:@"sound" index:1];

	[[SimpleAudioEngine  sharedEngine] setMute:!m];

}

-(void) startCallback: (id) sender
{
	[self removeAd];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionProgressRadialCW transitionWithDuration:1.0f scene:[SelectCharNode scene]]];
}

-(void) instructionsCallback: (id) sender 
{
	[self removeAd];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionShrinkGrow transitionWithDuration:1.0f scene:[InstructionsNode scene]]];
}

-(void) highScoresCallback: (id) sender
{
	[self removeAd];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSplitRows transitionWithDuration:1.0f scene:[HiScoresNode sceneWithPlayAgain:NO]]];
}

-(void) creditsCallback: (id) sender
{
	[self removeAd];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionTurnOffTiles transitionWithDuration:1.0f scene:[CreditsNode scene] ]];
}

-(void) buyCallback: (id) sender
{
	// Launches Safari and opens the requested web page
#ifdef __CC_PLATFORM_IOS
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sapusmedia.com/sources/"]];
#elif defined(__CC_PLATFORM_MAC)
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.sapusmedia.com/sources/"]];
#endif
}

-(void) removeAd
{
#ifdef LITE_VERSION
	if( supportsAds_ ) {
		SapusTongueAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		RootViewController *viewController = [appDelegate viewController];
		
		[[viewController banner] removeFromSuperview];

		inStage_ = NO;	
	}
#endif
}

@end

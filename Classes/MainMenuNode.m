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
#import "AdViewController.h"
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
		CCMenuItemImage *item1 = [SoundMenuItem itemWithNormalSpriteFrameName:@"btn-play-normal.png" selectedSpriteFrameName:@"btn-play-selected.png" target:self selector:@selector(startCallback:)];
		CCMenuItemImage *item2 = [SoundMenuItem itemWithNormalSpriteFrameName:@"btn-instructions-normal.png" selectedSpriteFrameName:@"btn-instructions-selected.png" target:self selector:@selector(instructionsCallback:)];
		CCMenuItemImage *item3 = [SoundMenuItem itemWithNormalSpriteFrameName:@"btn-highscores-normal.png" selectedSpriteFrameName:@"btn-highscores-selected.png" target:self selector:@selector(highScoresCallback:)];
		CCMenuItemImage *item4 = [SoundMenuItem itemWithNormalSpriteFrameName:@"btn-about-normal.png" selectedSpriteFrameName:@"btn-about-selected.png" target:self selector:@selector(creditsCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, item4, nil];
		[menu alignItemsVertically];
		[self addChild: menu z:2];
		menu.position = ccp(s.width/2,s.height/2-20);

		// Sound ON/OFF button
		SoundMenuItem *soundButton = [SoundMenuItem itemWithNormalSpriteFrameName:@"btn-music-on.png" selectedSpriteFrameName:@"btn-music-pressed.png" target:self selector:@selector(musicCallback:)];
		CCAnimation *sounds = [CCAnimation animationWithSpriteFrames:nil delay:0.1f];
		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[sounds addSpriteFrame:[cache spriteFrameByName:@"btn-music-on.png"]];
		[sounds addSpriteFrame:[cache spriteFrameByName:@"btn-music-off.png"]];
		[[CCAnimationCache sharedAnimationCache] addAnimation:sounds name:@"sound"];

		BOOL m = [[SimpleAudioEngine  sharedEngine] mute];
		[(CCSprite*)[soundButton normalImage] setDisplayFrameWithAnimationName:@"sound" index: m ? 1 : 0];

		menu = [CCMenu menuWithItems:soundButton, nil];
		[self addChild: menu z:2];
		menu.position = ccp(20,s.height-20);

		// Buy Sapus Sources
		SoundMenuItem *buyButton = [SoundMenuItem itemWithNormalSpriteFrameName:@"btn-buy-normal.png" selectedSpriteFrameName:@"btn-buy-selected.png" target:self selector:@selector(buyCallback:)];	
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
		
		if( supportsAds_ )
			adViewController_ = [[AdViewController alloc] initWithNibName:nil bundle:nil];

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
		CCDirector *director = [CCDirector sharedDirector];
	
		[adViewController_ createADBannerView];
		
		// XXX: BUG, it should not use the Director view, but the main UI Navigation controller
		[director.view addSubview:adViewController_.view];
		
		inStage_ = YES;		
	}
#endif // LITE_VERSION	
}

-(void) dealloc
{
#ifdef LITE_VERSION	
	[adViewController_ release];
#endif

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
		[adViewController_.view removeFromSuperview];

		inStage_ = NO;	
	}
#endif
}

@end

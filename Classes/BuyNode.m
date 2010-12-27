//
//  BuyNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 06/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


//
// A simple Class that promotes the non-Lite version
//

#import "BuyNode.h"
#import "MainMenuNode.h"
#import "SimpleAudioEngine.h"
#import "SoundMenuItem.h"
#import "stiPadHelper.h"

@interface BuyNode ()
-(void) setupBackground;
-(void) setupChars;
-(void) setupMenu;
@end

@implementation BuyNode
+(id) scene
{
	CCScene *s = [CCScene node];
	id node = [BuyNode node];
	[s addChild:node];
	return s;
}

-(id) init
{
	if( (self=[super init]) ) {

		[self setupBackground];
		[self setupChars];
		[self setupMenu];
	}
	
	return self;
}
-(void) setupBackground
{
	// background
	CCSprite *back = [CCSprite spriteWithFile:stConverToiPadOniPad(@"SapusBuy.png")];
	back.anchorPoint = CGPointZero;
	[self addChild:back z:-1];
}

-(void) setupChars
{	
	// TIP:
	// When possible try to put all your images in 1 single big image
	// It reduces loading times and memory consuption. And if you render them using SpriteSheet, it also improves the performance
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:stConverToiPadOniPad(@"sapus-monus-selection.plist")];
	
	
	// Batch Node: uses the image "sapus-monus-selection.png"
	CCSpriteBatchNode *sheet = [CCSpriteBatchNode batchNodeWithFile:stConverToiPadOniPad(@"sapus-monus-selection.png") capacity:2];
	[self addChild:sheet];
	
	
	CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	
	// TIP:
	// SpriteSheet: The sprites are also loaded from the "sapus-monus-selection.png"
	// SpriteSheet: These are SpriteFrame names that were defined in the file "sapus-monus-selection.plist"
	sapusSprite_ = [[CCSprite spriteWithSpriteFrameName:@"SapusSelected1.png"] retain];
	monusSprite_ = [[CCSprite spriteWithSpriteFrameName:@"MonusSelected1.png"] retain];
	
	CCAnimation *sapusAnim = [CCAnimation animationWithFrames:nil delay:0.3f];
	[sapusAnim addFrame:[frameCache spriteFrameByName:@"SapusSelected1.png"]];
	[sapusAnim addFrame:[frameCache spriteFrameByName:@"SapusSelected2.png"]];
	[sapusAnim addFrame:[frameCache spriteFrameByName:@"SapusSelected1.png"]];
	[sapusAnim addFrame:[frameCache spriteFrameByName:@"SapusUnselected.png"]];

	
	CCAnimation *monusAnim = [CCAnimation animationWithFrames:nil delay:0.3f];
	[monusAnim addFrame:[frameCache spriteFrameByName:@"MonusSelected1.png"]];
	[monusAnim addFrame:[frameCache spriteFrameByName:@"MonusSelected2.png"]];
	[monusAnim addFrame:[frameCache spriteFrameByName:@"MonusSelected1.png"]];
	[monusAnim addFrame:[frameCache spriteFrameByName:@"MonusUnselected.png"]];

	[sapusSprite_ runAction: [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: sapusAnim] ] ];
	[monusSprite_ runAction: [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: monusAnim] ] ];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	sapusSprite_.position = ccp(s.width/5,s.height/2+20);
	monusSprite_.position = ccp(4*s.width/5,s.height/2+20);
	
	// TIP SpriteSheet: Add Monus and Sapus to the SpriteSheet
	// TIP: If the Sprites are added to a "normal" sprite (instead of SpriteSheet)
	// TIP: then the sprites won't be batched (the render performance will be slower).
	[sheet addChild:sapusSprite_];
	[sheet addChild:monusSprite_];
}

-(void) setupMenu
{
	CCMenuItem *item1 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-buy-sapus-normal.png" selectedSpriteFrameName:@"btn-buy-sapus-selected.png" target:self selector:@selector(buyCallback:)];
	CCMenuItem *item2 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-continue-normal.png" selectedSpriteFrameName:@"btn-continue-selected.png" target:self selector:@selector(continueCallback:)];
	
	CCMenu *menu = [CCMenu menuWithItems: item1, item2, nil];
	[self addChild: menu];
	[menu alignItemsVertically];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	menu.position = ccp(s.width/2,s.height/5);

}

-(void) dealloc
{
	[sapusSprite_ release];
	[monusSprite_ release];
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:stConverToiPadOniPad(@"sapus-monus-selection.plist")];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];

	[super dealloc];
}

// callbacks
-(void) buyCallback: (id) sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"snd-buy-vivaviva.caf"];
	
	// TIP:
	// Your URL must start with "phobos" to launch the App Store application.
	NSURL *url = [NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=295078769&mt=8"];
	[[UIApplication sharedApplication] openURL: url];
}

-(void) continueCallback: (id) sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"snd-buy-ohno.caf"];
	CCScene *s = [CCScene node];	
	MainMenuNode *node = [MainMenuNode node];
	[s addChild:node];	
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:1.0f scene:s orientation:kOrientationRightOver]];
}

@end

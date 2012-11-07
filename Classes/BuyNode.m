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
// A simple Class that promotes the non-Lite version
//

#import "BuyNode.h"
#import "MainMenuNode.h"
#import "SimpleAudioEngine.h"
#import "SoundMenuItem.h"

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
	CCSprite *back = [CCSprite spriteWithFile:@"SapusBuy.png"];
	back.anchorPoint = CGPointZero;
	[self addChild:back z:-1];
}

-(void) setupChars
{	
	// TIP:
	// When possible try to put all your images in 1 single big image
	// It reduces loading times and memory consuption. And if you render them using SpriteSheet, it also improves the performance
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sapus-monus-selection.plist"];
	
	
	// Batch Node: uses the image "sapus-monus-selection.png"
	CCSpriteBatchNode *sheet = [CCSpriteBatchNode batchNodeWithFile:@"sapus-monus-selection.png" capacity:2];
	[self addChild:sheet];
	
	
	CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	
	// TIP:
	// SpriteSheet: The sprites are also loaded from the "sapus-monus-selection.png"
	// SpriteSheet: These are SpriteFrame names that were defined in the file "sapus-monus-selection.plist"
	sapusSprite_ = [[CCSprite spriteWithSpriteFrameName:@"SapusSelected1.png"] retain];
	monusSprite_ = [[CCSprite spriteWithSpriteFrameName:@"MonusSelected1.png"] retain];
	
	CCAnimation *sapusAnim = [CCAnimation animationWithSpriteFrames:nil delay:0.3f];
	[sapusAnim addSpriteFrame:[frameCache spriteFrameByName:@"SapusSelected1.png"]];
	[sapusAnim addSpriteFrame:[frameCache spriteFrameByName:@"SapusSelected2.png"]];
	[sapusAnim addSpriteFrame:[frameCache spriteFrameByName:@"SapusSelected1.png"]];
	[sapusAnim addSpriteFrame:[frameCache spriteFrameByName:@"SapusUnselected.png"]];

	
	CCAnimation *monusAnim = [CCAnimation animationWithSpriteFrames:nil delay:0.3f];
	[monusAnim addSpriteFrame:[frameCache spriteFrameByName:@"MonusSelected1.png"]];
	[monusAnim addSpriteFrame:[frameCache spriteFrameByName:@"MonusSelected2.png"]];
	[monusAnim addSpriteFrame:[frameCache spriteFrameByName:@"MonusSelected1.png"]];
	[monusAnim addSpriteFrame:[frameCache spriteFrameByName:@"MonusUnselected.png"]];

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
	CCMenuItem *item1 = [SoundMenuItem itemWithNormalSpriteFrameName:@"btn-buy-sapus-normal.png" selectedSpriteFrameName:@"btn-buy-sapus-selected.png" target:self selector:@selector(buyCallback:)];
	CCMenuItem *item2 = [SoundMenuItem itemWithNormalSpriteFrameName:@"btn-continue-normal.png" selectedSpriteFrameName:@"btn-continue-selected.png" target:self selector:@selector(continueCallback:)];
	
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
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sapus-monus-selection.plist"];
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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:1.0f scene:s orientation:kCCTransitionOrientationRightOver]];
}

@end

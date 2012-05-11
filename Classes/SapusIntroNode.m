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

#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"

#import "SapusIntroNode.h"
#import "MainMenuNode.h"
#import "LoadingBarNode.h"

enum {
	kTagLoader,
};
//
// Small scene that plays the background music and makes a transition to the Menu scene
//
@implementation SapusIntroNode
+(id) scene {
	CCScene *s = [CCScene node];
	id node = [SapusIntroNode node];
	[s addChild:node];
	return s;
}

-(id) init {
	if( (self=[super init])) {

		CCSprite *background;
		
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"music-background.mp3"];

		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// Load SpriteFrames here. These SpriteFrames are going to be used all over the game.
		// TIP: When possible, try to use the sprite frame cache:
		// TIP: Faster loading times, less memory consuption, and faster rendering in case you use an SpriteSheet.
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sapus-buttons.plist"];		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sapus-monus-ufo-hud.plist"];		
		
	
#ifdef __CC_PLATFORM_IOS
		// TIP: If you are going to do an Universal application (iPad + iPhone)
		// then you should do runtime checks, like the following:
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			background = [CCSprite spriteWithFile:@"Default-Portrait.png"];
		else
			background = [CCSprite spriteWithFile:@"Default.png"];

		background.rotation = -90;

#elif defined(__CC_PLATFORM_MAC)
		background = [CCSprite spriteWithFile:@"Default-mac.png"];
#endif
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
		

		CGSize s = [[CCDirector sharedDirector] winSize];
		LoadingBarNode *loader = [LoadingBarNode node];
		
		[self addChild:loader z:1 tag:kTagLoader];
		[loader setPosition:ccp(s.width/2, 35)];
	}
	return self;
}

-(void) onEnter
{
	[super onEnter];
	LoadingBarNode *loader = (LoadingBarNode*) [self getChildByTag:kTagLoader];
	[loader loadImagesWithArray:[MainMenuNode textureNames] target:self selector:@selector(imagesLoaded:)];
}

-(void) imagesLoaded:(id)sender
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration:1.0f scene:[MainMenuNode scene]]];
	
}
@end

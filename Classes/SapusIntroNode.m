//
//  SapusIntroNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 23/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

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
		
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		// TIP: If you are going to do an Universal application (iPad + iPhone)
		// then you should do runtime checks, like the following:
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			background = [CCSprite spriteWithFile:@"Default-Portrait.png"];
		else
			background = [CCSprite spriteWithFile:@"Default.png"];

		background.rotation = -90;

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
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

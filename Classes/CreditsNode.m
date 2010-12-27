//
//  CreditsNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 12/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

//
// A nice credits scene that shows a "scrolling" layer and some sprites moving from here to there
//
#import "CreditsNode.h"
#import "GradientLayer.h"
#import "SoundMenuItem.h"
#import "MainMenuNode.h"
#import "FastGrid.h"

enum {
	kTagSpriteSheetUFO =1,
	kTagSpriteSheetSapus =1,
	
};


@interface CreditsNode ()
-(void) setupGradient;
-(void) setupUFO;
-(void) setupTree;
-(void) setupButton;
@end


@implementation CreditsNode

+(id) scene {
	CCScene *s = [CCScene node];
	id node = [CreditsNode node];
	[s addChild:node];
	return s;
}

-(id) init {
	if( (self = [super init]) ) {
	
		nodesToRemove_ = [[NSMutableArray arrayWithCapacity:2] retain];

		winSize_ = [[CCDirector sharedDirector] winSize];

		[self setupButton];
		[self setupGradient];
		[self setupUFO];
		[self setupTree];

		[self schedule:@selector(delayMeteor:) interval:20];
		[self schedule:@selector(delayJump:) interval:8];
		[self schedule:@selector(setupCredits:) interval:1.5f];
		
	}

	return self;
}

-(void) dealloc
{
	[nodesToRemove_ release];
	[ufo_ release];

	[[CCTextureCache sharedTextureCache] removeUnusedTextures];

	[super dealloc];
}

-(void) setupButton
{		
	CCMenuItemImage *item1 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-menu-normal.png" selectedSpriteFrameName:@"btn-menu-selected.png" target:self selector:@selector(menuCallback:)];
	CCMenu *menu = [CCMenu menuWithItems:item1, nil];
	[self addChild:menu z:10];
	menu.position = ccp(winSize_.width-55,winSize_.height-25);
}

-(void) setupGradient 
{
	// back color

	GradientLayer *g = [GradientLayer layerWithColor:ccc4(0,0,0,0)];
	[g setBottomColor:ccc4(0xb3,0xe2,0xe6,0xff) topColor:ccc4(0,0,0,255)];
	[g changeHeight:winSize_.height];
	[g changeWidth:winSize_.width];
	[self addChild: g z:-10];
}

-(void) setupUFO
{
	// ufo
	CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"sprite-sheet-ufo.png"];
	[self addChild:batch z:-8 tag:kTagSpriteSheetUFO];

	ufo_ = [[CCSprite spriteWithBatchNode:batch rect:CGRectMake(0,0,138,84)] retain];
	
	CCAnimation *ufos = [CCAnimation animationWithFrames:nil delay:0.0f];
	[ufos addFrameWithTexture:batch.texture rect:CGRectMake(0,0,138,84)]; // UFO 1
	[ufos addFrameWithTexture:batch.texture rect:CGRectMake(0,168,195,87)]; // UFO 2
	[ufos addFrameWithTexture:batch.texture rect:CGRectMake(176,0,81,160)]; // UFO 3
	
	[[CCAnimationCache sharedAnimationCache] addAnimation:ufos name:@"ufos"];
	
	ufo_.visible = NO;
	ufo_.scale = 0.4f;
	ufo_.position = ccp(winSize_.width+60,260);
	[batch addChild:ufo_];
	
	// ufo trigger
	[self schedule:@selector(triggerUFO:) interval:10];
	[self scheduleUpdate];
}

-(void) setupTree {
	CCSprite *tree = [CCSprite spriteWithFile:@"SapusCreditsBackground.png"];
	[self addChild:tree z:-5];
	tree.anchorPoint = CGPointZero;
}


-(void) setupCredits: (ccTime) dt {
	[self unschedule:_cmd];

	CCSprite *credits = [CCSprite spriteWithFile:@"SapusCredits.png"];
	credits.anchorPoint = ccp(0.5f,0);
	[self addChild:credits z:5];
	
	credits.position = ccp(winSize_.width/2,-680);
	
	float duration = (winSize_.height+720)/30.0f; // 30 pixels per second
	id action = [CCSequence actions:
					[CCMoveBy actionWithDuration:duration position:ccp(0,winSize_.height+720)],
					[CCPlace actionWithPosition: ccp(winSize_.width/2,-700)],
				 nil];
	
	[credits runAction: [CCRepeatForever actionWithAction:action]];
	
	CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"sprite-sheet-sapus.png"];
	[credits addChild:batch z:1 tag:kTagSpriteSheetSapus];

	// animated sapus
	CCSprite *sapus = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(64*2, 0, 64, 64)];
	CCAnimation *animFly = [CCAnimation animationWithFrames:nil delay:0.14f];
	CCTexture2D *texture = [batch texture];
	[animFly addFrameWithTexture:texture rect: CGRectMake(64*0, 64*0, 64, 64)];
	[animFly addFrameWithTexture:texture rect: CGRectMake(64*1, 64*0, 64, 64)];
	[animFly addFrameWithTexture:texture rect: CGRectMake(64*2, 64*0, 64, 64)];
	[animFly addFrameWithTexture:texture rect: CGRectMake(64*3, 64*0, 64, 64)];
	[animFly addFrameWithTexture:texture rect: CGRectMake(64*0, 64*1, 64, 64)];
	[animFly addFrameWithTexture:texture rect: CGRectMake(64*3, 64*0, 64, 64)];
	[animFly addFrameWithTexture:texture rect: CGRectMake(64*2, 64*0, 64, 64)];
	[animFly addFrameWithTexture:texture rect: CGRectMake(64*1, 64*0, 64, 64)];
	
	[batch addChild:sapus];
	sapus.position = ccp(240,50+12);
	
	id animate = [CCAnimate actionWithAnimation: animFly];
	[sapus runAction: [CCRepeatForever actionWithAction:animate]];
}

-(void) delayJump:(ccTime) dt {
	[self unschedule:_cmd];
	
	CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"sprite-sheet-sapus.png"];
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(64*0, 64*1, 64, 64)];
	[batch addChild:sprite];
	[self addChild: batch z:-2];
	sprite.position = ccp(30,20);
	
	int jumps = (winSize_.width-45)/108;
	float duration = (winSize_.width-45)/72.5f; // 72.5 pixels per second
	CCActionInterval* jumpBy = [CCJumpBy actionWithDuration:duration position:ccp(winSize_.width-45,0) height:50 jumps:jumps];
	CCActionInterval* rotateBy = [CCRotateBy actionWithDuration:duration angle:180*jumps];
	CCActionInterval* jumpRot = [CCSpawn actions: jumpBy, rotateBy, nil];
	CCActionInterval* invJumpRot = [jumpRot reverse];
	id seq = [CCSequence actions: jumpRot, invJumpRot, nil];
	id repeat = [CCRepeatForever actionWithAction: seq];
	
	[sprite runAction: repeat];
}


-(void) delayMeteor: (ccTime) dt {

	CCParticleMeteor *meteor = [[CCParticleMeteor alloc] initWithTotalParticles:250];
	// custom meteor
	meteor.startSize = 30.0f;
	meteor.endSize = 30.0f;
	meteor.gravity = CGPointZero;
	meteor.life = 0.7f;
	meteor.speed = 8;
	meteor.position = ccp( -80, winSize_.height);

	[self addChild:meteor z:-10];
	[meteor release];
	
	// speed: 175 pixels per second
	float duration = (winSize_.width+340) / 175.0f + 1.0f;
	CCActionInterval *action = [CCSequence actions:
								[CCMoveBy actionWithDuration: duration position: ccp(winSize_.width+340,-winSize_.height/2)],
								[CCCallFuncN actionWithTarget:self selector:@selector(removeNodeCallback:)],
								nil];
	[meteor runAction:action];
}

-(void) update:(ccTime) dt {
	
	for(id node in nodesToRemove_) {
		[self removeChild:node cleanup:YES];
	}
	[nodesToRemove_ removeAllObjects];

	time_ += dt;
	CGPoint v = ufo_.position;
	
	float diffx = (dt * winSize_.width) / 8.0f;
	v.x -= diffx;
	
	v.y = ufoY_ + sinf(v.x / 40.0f) * 40.0f;
	
	ufo_.position = v;
}

-(void) triggerUFO:(ccTime) dt {
	float x = winSize_.width + 100 + CCRANDOM_0_1() * 80;
	ufoY_ = winSize_.height/2 + CCRANDOM_0_1() * 220;
	ufo_.position = ccp(x,ufoY_);
	ufo_.visible = ~ufo_.visible;
	ufo_.scale = 0.2f + CCRANDOM_0_1()/2.0f;
	
	[ufo_ setDisplayFrameWithAnimationName:@"ufos" index:CCRANDOM_0_1()*3.0f];
}

#pragma mark CreditsNode - callbacks

-(void) removeNodeCallback:(id) node {
	[nodesToRemove_ addObject:node];
}

-(void) menuCallback:(id) sender {
	ufo_.visible = NO;
    [[CCDirector sharedDirector] replaceScene: [CCTransitionTurnOffTiles transitionWithDuration:1.0f scene:[MainMenuNode scene] ]];

}
@end

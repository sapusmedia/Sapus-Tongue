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
// A nice credits scene that shows a "scrolling" layer and some sprites moving from here to there
//
#import "CreditsNode.h"
#import "SoundMenuItem.h"
#import "MainMenuNode.h"
#import "FastGrid.h"


@interface CreditsNode ()
-(void) setupGradient;
-(void) setupUFO;
-(void) setupTree;
-(void) setupButton;
@end


@implementation CreditsNode

+(id) scene
{
	CCScene *s = [CCScene node];
	id node = [CreditsNode node];
	[s addChild:node];
	return s;
}

-(id) init
{
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
	CCMenuItemImage *item1 = [SoundMenuItem itemWithNormalSpriteFrameName:@"btn-menu-normal.png" selectedSpriteFrameName:@"btn-menu-selected.png" target:self selector:@selector(menuCallback:)];
	CCMenu *menu = [CCMenu menuWithItems:item1, nil];
	[self addChild:menu z:10];
	menu.position = ccp(winSize_.width-55,winSize_.height-25);
}

-(void) setupGradient 
{
	// back color

	CCLayerGradient *g = [CCLayerGradient layerWithColor:ccc4(0xb3, 0xe2, 0xe6, 0xff) fadingTo:ccc4(0,0,0,255) alongVector:ccp(0,1)];
	[self addChild: g z:-10];
}

-(void) setupUFO
{
	ufo_ = [CCSprite spriteWithSpriteFrameName:@"ufo_00.png"];
	[ufo_ retain];
	[self addChild:ufo_ z:-8];
	
	ufo_.visible = NO;
	ufo_.scale = 0.4f;
	ufo_.position = ccp(winSize_.width+60,260);
	
	// ufo trigger
	[self schedule:@selector(triggerUFO:) interval:10];
	[self scheduleUpdate];
}

-(void) setupTree
{
	CCSprite *tree = [CCSprite spriteWithFile:@"tree1.png"];
	[self addChild:tree z:-5];
	tree.anchorPoint = CGPointZero;
	tree.position = ccp(-50,-30);
	tree.scale = 0.5f;
}


-(void) setupCredits: (ccTime) dt
{
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
	
	// animated sapus
	CCSprite *sapus = [CCSprite spriteWithSpriteFrameName:@"sapus_01.png"];
	[credits addChild:sapus z:1];

	CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	NSArray *array = [NSArray arrayWithObjects:
					 [frameCache spriteFrameByName:@"sapus_00.png"],
					 [frameCache spriteFrameByName:@"sapus_01.png"],
					 [frameCache spriteFrameByName:@"sapus_02.png"],
					 [frameCache spriteFrameByName:@"sapus_03.png"],
					 [frameCache spriteFrameByName:@"sapus_04.png"],
					 [frameCache spriteFrameByName:@"sapus_03.png"],
					 [frameCache spriteFrameByName:@"sapus_02.png"],
					 [frameCache spriteFrameByName:@"sapus_01.png"],
					 nil];
					 
	CCAnimation *animFly = [CCAnimation animationWithSpriteFrames:array delay:0.14f];
	sapus.position = ccp(240,50+12);
	
	id animate = [CCAnimate actionWithAnimation: animFly];
	[sapus runAction: [CCRepeatForever actionWithAction:animate]];
}

-(void) delayJump:(ccTime) dt
{
	[self unschedule:_cmd];
	
	CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"sapus_01.png"];
	[self addChild:sprite z:-2];
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


-(void) delayMeteor: (ccTime) dt
{
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

-(void) update:(ccTime) dt
{
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

-(void) triggerUFO:(ccTime) dt
{
	float x = winSize_.width + 100 + CCRANDOM_0_1() * 80;
	ufoY_ = winSize_.height/2 + CCRANDOM_0_1() * 220;
	ufo_.position = ccp(x,ufoY_);
	ufo_.visible = ~ufo_.visible;
	ufo_.scale = 0.2f + CCRANDOM_0_1()/2.0f;
	
	int index = CCRANDOM_0_1()*3.0f;
	NSString *frameName = [NSString stringWithFormat:@"ufo_%02d.png", index];
	[ufo_ setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
}

#pragma mark CreditsNode - callbacks

-(void) removeNodeCallback:(id) node
{
	[nodesToRemove_ addObject:node];
}

-(void) menuCallback:(id) sender
{
	ufo_.visible = NO;
    [[CCDirector sharedDirector] replaceScene: [CCTransitionTurnOffTiles transitionWithDuration:1.0f scene:[MainMenuNode scene] ]];

}
@end

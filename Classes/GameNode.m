//
//  GameNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright 2008,2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

//
// Game Node:
// The logic of the game is implemented here.
//   a State machine is used for the different states:
//		kGameWaiting  <-- Game is being initialized
//		kGameStart    <-- Game started... flip the Sapus
//		kGameFlying   <-- Sapus is flying
//		kGameOver     <-- Sapus stoped flyting
//		kGameTryAgain <-- Menu is displayed
//		kGameDrawTongue <-- PlayAgain... draw tongue and play "uh no"
//		kGameIsBeingReplaced <-- Game is restared... 

// cocos2d imports
#import "cocos2d.h"
#import "chipmunk.h"
#import "ChipmunkHelper.h"

// local imports
#import "SapusConfig.h"
#import "GameNode.h"
#import "GameHUD.h"

#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"
#import "CDAudioManager.h"
#ifdef __CC_PLATFORM_IOS
#import "CCNotifications.h"
#import <GameKit/GameKit.h>
#endif // __CC_PLATFORM_IOS

#import "SelectCharNode.h"
#import "SapusTongueAppDelegate.h"
#import "FloorNode.h"
#import "MountainNode.h"

// Position of the "bee".. where the tongue is attached to
#define kJointX 160
#define kJointY 160

enum {
	kTagGradient = 1,
	kTagFloor = 2,
	kTagMountains = 3,
};

// TIP:
//  The most difficult part with a physics engine is tunning it.
//  Use constants (or #defines) while tunning the engine, and modify these constants.

#ifdef __CC_PLATFORM_IOS
const float kForceFactor = 350.0f;
const float kWallLength = 32768.0f;
#elif defined(__CC_PLATFORM_MAC)
const float kForceFactor = 200.0f;		// reduced force in Mac, since it is much easier to use the mouse, than the accelerometer
const float kWallLength = 49152;		// world is bigger in Mac

#endif

const float	kSapusTongueLength = 80.0f;
const float kSapusMass = 1.0f;
const float kSapusElasticity = 0.4f;
const float kSapusFriction = 0.8f;
const float kSapusOffsetY = 32;
const float kWallHeight = 4000.f;

const float kGravityRoll = -50.0f;
const float kGravityFly = -175.0f;

const float kCircleRadius = 12.0f;

// Having the optimal hash values is key in chipmunk: // http://code.google.com/p/chipmunk-physics/wiki/cpSpace
// hash static values:
# define kHashStaticDim  ((kWallHeight * 2 + kWallLength ) / 3.0f)
const int kHashStaticCount = 3 * 10;  // 3 shapes * 10
#define kHashActiveDim  (kCircleRadius * 2)
const int kHashActiveCount = 5 * 10;  // 5 shapes * 10



// EXPERIMENTAL TIP:
// Fixed time physics "step" in seconds
// The lower the number, the smoother the animation, but it consume more FPS
//
// WARNING: This number can't be much lower than this, else it is possible to enter
// in a never-ending-cycle that consume lot's of FPS
//
// WARNING: If you are planning to use this tip, test it very well on all the devices
//   * iPhone 1gen, 3G
//   * iPod Touch 1g, 2g
// 
// WHEN CAN YOU USE THIS TIP ?:
// When you know before hand that your physics simulation is constant
//  * No new bodies are added
// 
// By using this tip Sapus Tongue runs at 60 FPS and has an smoother physics simulation
//
#if ST_EXPERIMENTAL_PHYSICS_STEP
const float kPhysicsDelta = 0.0005f;

// if the delta is greater than this value, then something went wrong
// so we should update the physics engine ASAP.
const float kPhysicsDeltaSomethingWentWrong = 0.10f;
#endif

static int totalScore = 0;

#define kAccelerometerFrequency 40

enum {
	kCollTypeIgnore,
	kCollTypeSapus,
	kCollTypeFloor,
	kCollTypeWalls,
	kCallTypeBee,
};

#pragma mark Chipmunk Callbacks

//
// Debug functions used to draw the shapes.
// Only used while debugging & testing the physics world
//
#if ST_DRAW_SHAPES
void drawCircleShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpCircleShape *circle = (cpCircleShape *)shape;
	cpVect c = cpvadd(body->p, cpvrotate(circle->c, body->rot));
	ccDrawCircle( ccp(c.x, c.y), circle->r, body->a, 15, YES);
}

void drawSegmentShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	cpVect a = cpvadd(body->p, cpvrotate(seg->a, body->rot));
	cpVect b = cpvadd(body->p, cpvrotate(seg->b, body->rot));
	
	ccDrawLine( ccp(a.x, a.y), ccp(b.x, b.y) );
}

void drawPolyShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpPolyShape *poly = (cpPolyShape *)shape;
	
	int num = poly->numVerts;
	cpVect *verts = poly->verts;
	
	CGPoint *vertices = malloc( sizeof(CGPoint)*poly->numVerts);
	if( ! vertices )
		return;
	
	for(int i=0; i<num; i++){
		cpVect v = cpvadd(body->p, cpvrotate(verts[i], body->rot));
		vertices[i] = (CGPoint){v.x, v.y};
	}
	ccDrawPoly( vertices, poly->numVerts, YES );
	
	free(vertices);
}
#endif // ST_DRAW_SHAPES

static void
eachShape(cpShape *shape, void* instance)
{
//	GameNode *self = (GameNode*) instance;
	CCSprite *sprite = shape->data;
	if( sprite ) {
		cpVect c;
		cpBody *body = shape->body;
		
		c = cpvadd(body->p, cpvrotate(cpvzero, body->rot));
		
		[sprite setPosition: ccp( c.x, c.y)];
		[sprite setRotation: CC_RADIANS_TO_DEGREES( -body->a )];

	}
}

#if ST_DRAW_SHAPES
static void drawEachShape( cpShape *shape, void *instace )
{
	if( shape )		
	{
		switch(shape->CP_PRIVATE(klass)->type){
			case CP_CIRCLE_SHAPE:
				drawCircleShape(shape);
				break;
			case CP_SEGMENT_SHAPE:
				drawSegmentShape(shape);
				break;
			case CP_POLY_SHAPE:
				drawPolyShape(shape);
				break;
			default:
				printf("Bad enumeration in drawEachShape().\n");
		}
	}
}
#endif // ST_DRAW_SHAPES

int collisionSapusFloor(cpArbiter *arb, struct cpSpace *sapce, void *data);

int collisionSapusFloor(cpArbiter *arb, struct cpSpace *sapce, void *data)
{
	// The arbiter has the shapes in the order that the callback was created
	// a: Sapus Shape
	// b: Floor Shape

	GameNode *gameNode = (GameNode*) data;
	if( gameNode->state_ != kGameFlying )
		return 1;

	cpShape *sapusShape, *floorShape;
	cpArbiterGetShapes(arb, &sapusShape, &floorShape);

	cpBody *sapusBody_ = sapusShape->body;

	// play a vibrate "sound" & add "helmet" achievement if Sapus touches ground at a speed greater than 1000
#ifdef __CC_PLATFORM_IOS
	if( cpvlength(sapusBody_->v) > 1000 ) {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		
#ifdef LITE_VERSION
		[[GameCenterManager sharedManager] submitAchievement:@"Helmet_lite" percentComplete:100];
#else
		[[GameCenterManager sharedManager] submitAchievement:@"Helmet" percentComplete:100];
#endif

	}
#endif

	if( cpvlength(sapusBody_->v) > 250 )
		[[SimpleAudioEngine sharedEngine] playEffect:@"snd-gameplay-boing.caf"];
	
	// TIP:
	// return 1 means: "engine treat this collision as normal collision"
	// return 0 means: "ignore this collision"
	return 1;
}

#pragma mark GameNode - Private interaces
@interface GameNode ()
-(void) setupSapus;
-(void) setupTongue;
-(void) setupJoint;
-(void) setupBackground;
-(void) setupChipmunk;
-(void) setupCollisionDetection;

-(void) removeJoint;
-(void) updateSapusAngle;
-(void) updateJointLength;
-(void) drawTongue;

-(void) updateRollingVars;
-(void) updateRollingFrames;
-(void) updateFlyingFrames: (ccTime) dt;

-(void) throwFinish;
@end

@implementation GameNode

+(int) score
{
	return totalScore;
}

+(CCScene*) scene
{
	CCScene *s = [CCScene node];
	
	id game = [GameNode node];
	GameHUD *hud = [[GameHUD alloc] initWithGame:game];
	
	[s addChild:hud z:1];
	[s addChild:game];
	
	[hud release];
	
	return s;
}

//
// Return the list of needed images
// These images are going to be async-loaded
//
+(NSArray*) textureNames
{
	return [NSArray arrayWithObjects:
			@"fixed-tiles_8x8.png",
			@"sapus-monus-ufo-hud.png",
			@"MonusTail.png",
			@"SapusTongue.png",
			@"mountains1.png",
			@"mountains2.png",			
			nil];
}
#pragma mark GameNode - Init & Creation

-(id) init
{
	if( (self=[super init]) ) {
	
#ifdef __CC_PLATFORM_IOS
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		SapusTongueAppDelegate *appDelegate = (SapusTongueAppDelegate*) [[UIApplication sharedApplication] delegate];	

		if( [GameCenterManager isGameCenterAvailable] )
			[[GameCenterManager sharedManager] setDelegate: self];

#elif defined(__CC_PLATFORM_MAC)
		self.isMouseEnabled = YES;
		SapusTongueAppDelegate *appDelegate = [NSApp delegate];
#endif

	
		appDelegate.isPlaying = YES;
		
		[self setupBackground];
		[self setupTongue];
		[self setupChipmunk];
		[self setupCollisionDetection];
		
		[self scheduleUpdate];
		
		totalScore = 0;
		
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
		
	}
	
	return self;
}

-(void) setupBackground
{
	// tree
	CCSprite *tree = [CCSprite spriteWithFile:@"tree1.png"];
	tree.anchorPoint = CGPointZero;
	[self addChild:tree z:-5];

	// ufos
	CCSprite *ufo1 = [CCSprite spriteWithSpriteFrameName:@"ufo_00.png"];
	CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithTexture:[ufo1 texture] capacity:3];
	[self addChild:batch z:-2];
	[batch addChild:ufo1];
	ufo1.position = ccp(1400,2000);	
		
	CCSprite *ufo2 = [CCSprite spriteWithSpriteFrameName:@"ufo_01.png"];
	[batch addChild:ufo2];
	ufo2.position = ccp(900,2100);

	CCSprite *ufo3 = [CCSprite spriteWithSpriteFrameName:@"ufo_02.png"];
	[batch addChild:ufo3];
	ufo3.position = ccp(400,2100);
	

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
	[self addChild:floor z:-6 tag:kTagFloor];	

	// mountains	
	MountainNode *mountain = [MountainNode node];
	CCParallaxNode *parallax = [CCParallaxNode node];
	[parallax addChild:mountain z:0 parallaxRatio:ccp(0.3f, 0.3f) positionOffset:ccp(0,0)];
	[self addChild:parallax z:-7 tag:kTagMountains];

	// Gradient
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLayerGradient *g = [CCLayerGradient layerWithColor:ccc4(0xb3, 0xe2, 0xe6, 0xff) fadingTo:ccc4(0,0,0,255) alongVector:ccp(0,2)];
	[g setContentSize:CGSizeMake(s.width, 1600)];
	[self addChild: g z:-10 tag:kTagGradient];
}

-(void) setupChipmunk
{	
	cpInitChipmunk();
		
	space_ = cpSpaceNew();
	space_->iterations = 10;
	space_->gravity = cpv(0, kGravityRoll);
	
	// pivot point. fly
	CCSprite *fly = nil;
	if( [SelectCharNode selectedChar] == kSTSelectedCharSapus )
		fly = [CCSprite spriteWithSpriteFrameName:@"fly.png"];
	else {
		fly = [CCSprite spriteWithSpriteFrameName:@"branch.png"];
		CGSize s = [fly contentSize];
		fly.anchorPoint = ccp(19/s.width,30/s.height);
	}
	
	[self addChild:fly z:-1];
	
	cpShape *shape = NULL;

	pivotBody_ = cpBodyNew(INFINITY, INFINITY);
	pivotBody_->p =  cpv(kJointX,kJointY);
	shape = cpCircleShapeNew(pivotBody_, 5.0f, cpvzero);
	shape->e = 0.9f;
	shape->u = 0.9f;
	shape->data = fly;
	cpSpaceAddStaticShape(space_, shape);

	
	GLfloat wallWidth = 1;

	// floor
	wallBottom_ = cpSegmentShapeNew(space_->staticBody, cpv(-wallWidth,-wallWidth+1), cpv(kWallLength,-wallWidth), wallWidth+1);
	wallBottom_->e = 0.5f;
	wallBottom_->u = 0.9f;
	wallBottom_->collision_type = kCollTypeFloor;
	cpSpaceAddStaticShape(space_, wallBottom_);
		
	// left
	wallLeft_ = cpSegmentShapeNew(space_->staticBody, cpv(-wallWidth,-wallWidth), cpv(-wallWidth,kWallHeight), wallWidth);
	wallLeft_->e = 0.2f;
	wallLeft_->u = 1.0f;
	cpSpaceAddStaticShape(space_, wallLeft_);
	
	// right
	wallRight_ = cpSegmentShapeNew(space_->staticBody, cpv(kWallLength,-wallWidth), cpv(kWallLength,kWallHeight), wallWidth);
	wallRight_->e = 0.0f;
	wallRight_->u = 1.5f;
	cpSpaceAddStaticShape(space_, wallRight_);
		
	[self setupSapus];
	[self setupJoint];
	
	// reposition sapus
	sapusBody_->p.y = 30;
}

-(void) setupJoint {
	// TIP:
	// When dealing with joints it is OK to try the different kind of joints.
	// You can achieve different visual effects
	
	// The joint is used to attach Sapus to the tree
	// the joint is visually represented by the tongue (or tail)
	
//	joint = cpPinJointNew(sapusBody_, pivotBody_, cpvzero, cpvzero);
//	joint = cpGrooveJointNew(sapusBody_, pivotBody_, cpv(0, 40), cpv(0,100), cpv(0, 0));

	joint_ = cpPivotJointNew(sapusBody_, pivotBody_, cpv(kJointX, kJointY));
//	joint = cpSlideJointNew(sapusBody_, pivotBody_, cpvzero, cpvzero, 0, kSapusTongueLength);

}

-(void) setupSapus
{
	CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	CCAnimationCache *animCache = [CCAnimationCache sharedAnimationCache];

	CCSpriteFrame *rollFrame = nil;
	if( [SelectCharNode selectedChar] == kSTSelectedCharSapus ) {
		sapusSprite_ = [[CCSprite spriteWithSpriteFrameName:@"sapus_01.png"] retain];
		rollFrame = [frameCache spriteFrameByName:@"sapus_02.png"];
		
	} else {
		sapusSprite_ = [[CCSprite spriteWithSpriteFrameName:@"monus_01.png"] retain];
		rollFrame = [frameCache spriteFrameByName:@"monus_12.png"];
	}

	[self addChild:sapusSprite_ z:-1];

	CGSize s = [sapusSprite_ contentSize];
	CGPoint ta = sapusSprite_.anchorPoint;
	ta.y = kSapusOffsetY / s.height;
	sapusSprite_.anchorPoint = ta;


	// Rolling Animation
	NSArray *rollArray = [NSArray arrayWithObjects: rollFrame, nil];
														  
	CCAnimation *animRoll = [CCAnimation animationWithFrames:rollArray delay:0.2f];
	[animCache addAnimation:animRoll name:@"roll"];

	
	// Flying Animation
	NSArray *flyArray = nil;
	
	if( [SelectCharNode selectedChar] == kSTSelectedCharSapus ) {
		flyArray = [NSArray arrayWithObjects:
					[frameCache spriteFrameByName:@"sapus_00.png"],
					[frameCache spriteFrameByName:@"sapus_01.png"],
					[frameCache spriteFrameByName:@"sapus_02.png"],
					[frameCache spriteFrameByName:@"sapus_03.png"],
					[frameCache spriteFrameByName:@"sapus_04.png"],
					[frameCache spriteFrameByName:@"sapus_03.png"],
					[frameCache spriteFrameByName:@"sapus_02.png"],
					[frameCache spriteFrameByName:@"sapus_01.png"],
					nil];
	} else {
		flyArray = [NSArray arrayWithObjects:
					[frameCache spriteFrameByName:@"monus_00.png"],
					[frameCache spriteFrameByName:@"monus_01.png"],
					[frameCache spriteFrameByName:@"monus_02.png"],
					[frameCache spriteFrameByName:@"monus_03.png"],
					[frameCache spriteFrameByName:@"monus_04.png"],
					[frameCache spriteFrameByName:@"monus_03.png"],
					[frameCache spriteFrameByName:@"monus_02.png"],
					[frameCache spriteFrameByName:@"monus_01.png"],
					nil];
	}

	CCAnimation *animFly = [CCAnimation animationWithFrames:flyArray delay:0.2f];
	[animCache addAnimation:animFly name:@"fly"];
	
	// Flying NoTail Aniimation (only valid for Monus)
	// monus
	if( [SelectCharNode selectedChar] == kSTSelectedCharMonus ) {
		NSArray *noTailArray = [NSArray arrayWithObjects:
								[frameCache spriteFrameByName:@"monus_10.png"],
								[frameCache spriteFrameByName:@"monus_11.png"],
								[frameCache spriteFrameByName:@"monus_12.png"],
								[frameCache spriteFrameByName:@"monus_13.png"],
								[frameCache spriteFrameByName:@"monus_14.png"],
								[frameCache spriteFrameByName:@"monus_13.png"],
								[frameCache spriteFrameByName:@"monus_12.png"],
								[frameCache spriteFrameByName:@"monus_11.png"],
					nil];
		
		CCAnimation *animNoTail = [CCAnimation animationWithFrames:noTailArray delay:0.2f];
		[animCache addAnimation:animNoTail name:@"notail"];
	}

	//
	// Physics
	//

	// Sapus / Monus is simulated using 5 circles.
	// (imagine a pentagon, and with a circle in each of it's vertices)
	//
	// TIP:
	// According to my expirience it is easier and faster to model objects using circles
	// than using custom polygons.

	cpFloat moment = cpMomentForCircle(kSapusMass/5.0f, 0, kCircleRadius, cpv(0,(64-kCircleRadius)-kSapusOffsetY) );
	moment += cpMomentForCircle(kSapusMass/5.0f, 0, kCircleRadius, cpv(-14,3+kCircleRadius-kSapusOffsetY) );
	moment += cpMomentForCircle(kSapusMass/5.0f, 0, kCircleRadius, cpv(14,3+kCircleRadius-kSapusOffsetY) );
	moment += cpMomentForCircle(kSapusMass/5.0f, 0, kCircleRadius, cpv(22,29+kCircleRadius-kSapusOffsetY) );
	moment += cpMomentForCircle(kSapusMass/5.0f, 0, kCircleRadius, cpv(-22,29+kCircleRadius-kSapusOffsetY) );

	sapusBody_ = cpBodyNew(kSapusMass, moment);
	
	sapusBody_->p = pivotBody_->p;
	sapusBody_->p.y = pivotBody_->p.y - kSapusTongueLength;
//	sapusBody_->p.y = 30;

	cpSpaceAddBody(space_, sapusBody_);
	
	
	//
	// The position/elasticity/friction of the 5 circles
	//
//	cpShape *shape = cpPolyShapeNew(sapusBody_, numVertices, verts, cpvzero);
	cpShape *shape = cpCircleShapeNew(sapusBody_, kCircleRadius, cpv(0,(64-kCircleRadius)-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	shape->data = sapusSprite_;
	cpSpaceAddShape(space_, shape);

	shape = cpCircleShapeNew(sapusBody_, kCircleRadius, cpv(-14,3+kCircleRadius-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	cpSpaceAddShape(space_, shape);

	shape = cpCircleShapeNew(sapusBody_, kCircleRadius, cpv(14,3+kCircleRadius-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	cpSpaceAddShape(space_, shape);
	
	shape = cpCircleShapeNew(sapusBody_, kCircleRadius, cpv(22,29+kCircleRadius-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	cpSpaceAddShape(space_, shape);

	shape = cpCircleShapeNew(sapusBody_, kCircleRadius, cpv(-22,29+kCircleRadius-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	cpSpaceAddShape(space_, shape);
	
}

-(void) setupTongue
{
	if( [SelectCharNode selectedChar] == kSTSelectedCharSapus )
		tongue_ = [[CCTextureCache sharedTextureCache] addImage: @"SapusTongue.png"];
	else
		tongue_ = [[CCTextureCache sharedTextureCache] addImage: @"MonusTail.png"];
	[tongue_ retain];
}

-(void) setupCollisionDetection
{
	// TIP:
	// Chipmunk 5 has 4 types of collisions: ( http://code.google.com/p/chipmunk-physics/wiki/CallbackSystem )
	//
	// Begin: Two shapes just started touching for the first time this step.
	//        Return false from the callback to make Chipmunk ignore the collision or true to process it normally.
	// Pre Solve: Two shapes are touching.
	//			Return false from the callback to make Chipmunk ignore the collision or true to process it normally.
	//			Additionally, you may override collision values such as cpArbiter.e and cpArbiter.u to provide custom friction or elasticity values.
	//			See cpArbiter for more info.
	// Post Solve: Two shapes are touching and their collision response has been processed.
	//				You can retrieve the collision force at this time if you want to use it to calculate sound volumes or damage amounts.
	// Separate: Two shapes have just stopped touching for the first time this frame.

	//
	// SapusTongue only uses the "begin" callback
	//
	cpSpaceAddCollisionHandler(space_, kCollTypeSapus, kCollTypeFloor, &collisionSapusFloor,  NULL, NULL, NULL, self);
}


-(void) dealloc
{
#ifdef __CC_PLATFORM_IOS
	SapusTongueAppDelegate *appDelegate = (SapusTongueAppDelegate*) [[UIApplication sharedApplication] delegate];	
#elif defined(__CC_PLATFORM_MAC)
	SapusTongueAppDelegate *appDelegate = [NSApp delegate];
#endif
	appDelegate.isPlaying = NO;
	
	[sapusSprite_ release];
	[tongue_ release];
	
	// TIP:
	// Remember: static (rogue) shapes needs to be freed manually
	//
//	cpShapeFree(wallLeft_);
//	cpShapeFree(wallRight_);
//	cpShapeFree(wallBottom_);
	
	ChipmunkFreeSpaceChildren(space_);
	cpSpaceFree(space_);

	[[CCTextureCache sharedTextureCache] removeUnusedTextures];	

#ifdef __CC_PLATFORM_IOS
	if( [GameCenterManager isGameCenterAvailable] )
		[[GameCenterManager sharedManager] setDelegate:nil];
#endif

	[super dealloc];
}

//
// The heavy part of init and the UIKit controls are initialized after the transition is finished.
// This trick is used to:
//    * create a smooth transition (load heavy resources after the transition is finished)
//    * show UIKit controls after the transition to simulate that they transition like any other control
//
-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];

	state_ = kGameStart;

	[self addJoint];

	// TIP:
	// BUG: In v0.8-beta the 'onEnter' callback of the new Scene is called before the 'onExit' of the outgoing scene
	// It means that the 'onExit' might disable the accelerotmer.
	// A workaround it to re-enable it here.
	// This is useful if the incoming and outgoing scenes are both are using the accelerometer
	
#ifdef __CC_PLATFORM_IOS
	if( self.isAccelerometerEnabled )
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
#endif

}

-(void) onEnter
{
	[super onEnter];
	
#ifdef __CC_PLATFORM_IOS
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
#endif
}

#pragma mark GameNode - Main Loop

-(void) update: (ccTime) delta
{
	cpBodyResetForces(sapusBody_);

//	cpVect impulse = cpvmult(force, 10);
	cpVect f = cpvmult(force_, kForceFactor);

	if( state_ == kGameStart ) {
		
		cpBodyApplyForce(sapusBody_, f, cpvzero);		
		[self updateRollingFrames];
		[self updateRollingVars];

	} else if( state_ == kGameFlying ) {
		totalScore = sapusBody_->p.x;

		// TIP:
		// A physics engine has lots of variables.
		// Here I'm reducing the angular speed when Sapus/Monus
		// is rotation while it is flying.
		//
		// If you comment this line you will see that sapus
		// rotates much faster (obtain better scores)
		sapusBody_->t = -(sapusBody_->w) * sapusBody_->i / 4.0f;
		
		[self updateFlyingFrames: delta];
		if( cpvlength(sapusBody_->v) <= 1.0f && sapusBody_->p.y <= 70 ) {
			[self throwFinish];
		}
		
		// XXX BUG: since we don't have continous collition detection
		// Sapus/Monus can pass through the floor.
		// To prevent this, we just re position the Monus/Sapus if 
		// it's position is lower than 20
		if( sapusBody_->p.y < 20 ) {
			sapusBody_->p.y = 70;
		}
		
#ifdef __CC_PLATFORM_IOS
		// Check Max Height
		if( ! maxHeightAchievementTriggered_ && sapusBody_->p.y > 2200) {
			maxHeightAchievementTriggered_ = YES;
#ifdef LITE_VERSION
			[[GameCenterManager sharedManager] submitAchievement:@"Moon_lite" percentComplete:100];
#else
			[[GameCenterManager sharedManager] submitAchievement:@"Moon" percentComplete:100];
#endif
		}
#endif // __CC_PLATFORM_IOS

	}

	// EXPERIMENTAL PHYSICS is disabled since v1.8 since it's not reliable
	// EXPERIMENTAL TIP:
	// Try to always pass a fixed delta in the simulation
	// This article explains a good way to achieve it:
	// http://gafferongames.com/game-physics/fix-your-timestep/
	// This is also valid for chipmunk
#if ST_EXPERIMENTAL_PHYSICS_STEP
	physicsAccumulator_ += delta;
	if( delta > kPhysicsDeltaSomethingWentWrong ) {
		cpSpaceStep(space_, delta);
	} else while( physicsAccumulator_ >= kPhysicsDelta ) {
		cpSpaceStep(space_, kPhysicsDelta);
		physicsAccumulator_ -= kPhysicsDelta;
	}
#else 
	int steps = 7;
	cpFloat dt = delta/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space_, dt);
	}	
#endif
	

	// update sprite position
	cpSpaceEachShape(space_, &eachShape, self);
	
	
	CGPoint newPos = self.position;
	// update screen position
	if( sapusBody_->p.x > 260 )
		newPos.x = -(sapusBody_->p.x - 260);
	else
		newPos.x = 0;

	if( sapusBody_->p.y > 244 )
		newPos.y = -(sapusBody_->p.y - 244);
	else
		newPos.y = 0;

	self.position = newPos;


	// update gradient & floor X position
	CCNode *gradient = [self getChildByTag:kTagGradient];
	CCNode *floor = [self getChildByTag:kTagFloor];
	CGPoint p = self.position;
	p.x = -self.position.x;
	p.y = self.position.y;
	gradient.position = p;
	floor.position = p;
}

-(void) updateSapusAngle
{
	cpVect diff = cpvsub(pivotBody_->p,sapusBody_->p);
	cpFloat a = cpvtoangle(diff);
	sapusBody_->a = a - (float)M_PI_2;
}

-(void) updateJointLength
{
	cpSlideJoint *j = (cpSlideJoint*) joint_;
	cpFloat v = cpvlength( sapusBody_->v );
	
	j->max = kSapusTongueLength + (v / 13.0f);
	j->max = MAX(j->max, kSapusTongueLength);
	j->max = MIN(j->max, kSapusTongueLength+70);
}


-(void) updateRollingVars
{	
	// velocity
	throwVelocity_ = cpvlength( sapusBody_->v );

	// angle
	cpVect diff = cpvsub(pivotBody_->p,sapusBody_->p);
	cpFloat a = cpvtoangle(diff);
	throwAngle_ = CC_RADIANS_TO_DEGREES(a);
}

-(void) updateRollingFrames
{
	[sapusSprite_ setDisplayFrameWithAnimationName:@"roll" index:0];
	displayFrame_ = 0;
}

-(void) updateFlyingFrames: (ccTime) dt
{	
	if( cpvlength(sapusBody_->v) > 100 ) {
		flyingDeltaAccum_ += dt;

		int idx = flyingDeltaAccum_  / 0.06f;
		[sapusSprite_ setDisplayFrameWithAnimationName:@"fly" index: idx%8];
		displayFrame_ = idx % 8;
	}
}

-(void) draw
{
	if( state_ == kGameStart || state_ == kGameDrawTongue )
		[self drawTongue];

	
	// draw shapes
#if ST_DRAW_SHAPES
	cpSpaceEachShape(space_, &drawEachShape, self);
#endif

}

-(void) drawTongue
{	
	//
	// TIP:
	// The tongue (or tail) is drawn
	// using a GL Quad from the mouth to the pivot point
	// You can strech, enlarge any texture using a Quad.
	//
	// It is also possible to draw the tongue (or tail) by 
	// rotating and scaling a CCSprite with a custom anchorPoint
	//
	GLfloat	 coordinates[] = {  0,				tongue_.maxT,
								tongue_.maxS,	tongue_.maxT,
								0,				0,
								tongue_.maxS,	0  };
	

	cpVect sapusV = sapusBody_->p;
	float angle = cpvtoangle( cpvsub(pivotBody_->p, sapusV) );
	float x = sinf(angle);
	float y = -cosf(angle);

	float ys = sinf( sapusBody_->a + (float)M_PI_2);
	float xs = cosf( sapusBody_->a + (float)M_PI_2);

	float tongueLen = (CC_CONTENT_SCALE_FACTOR() == 1) ? 11 : 7;
	if( [SelectCharNode selectedChar] == kSTSelectedCharSapus )
		tongueLen = 15;
	sapusV.x = sapusV.x + tongueLen*xs;
	sapusV.y = sapusV.y + tongueLen*ys;	
	
	GLfloat	vertices[] = {	(sapusV.x - x*1.5f),		(sapusV.y - y*1.5f),		0.0f,
							(sapusV.x + x*1.5f),		(sapusV.y + y*1.5f),		0.0f,
							(pivotBody_->p.x - x*1.5f),	(pivotBody_->p.y - y*1.5f),	0.0f,
							(pivotBody_->p.x + x*1.5f),	(pivotBody_->p.y + y*1.5f),	0.0f };		
	

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );

	ccGLUseProgram( shaderProgram_->program_ );
	ccGLUniformModelViewProjectionMatrix( shaderProgram_ );
	
	ccGLBindTexture2D( tongue_.name );
	
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, vertices);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, coordinates);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	CHECK_GL_ERROR_DEBUG();	
}

-(void) addJoint
{
	cpSpaceAddConstraint(space_, joint_);
	jointAdded_ = YES;
	state_ = kGameStart;
	totalScore = 0;
	space_->gravity = cpv(0, kGravityRoll);
	maxHeightAchievementTriggered_ = NO;
}

-(void) removeJoint
{
	cpSpaceRemoveConstraint(space_, joint_);
	jointAdded_ = NO;
	state_ = kGameFlying;
	space_->gravity = cpv(0, kGravityFly);

	[sapusSprite_ setDisplayFrameWithAnimationName:@"fly" index:2];
	
	if( cpvlength(sapusBody_->v) > 630 ) {
		int r = CCRANDOM_0_1() * 6;
		switch (r) {
			case 0:
				[[SimpleAudioEngine sharedEngine] playEffect:@"snd-gameplay-mama.caf"];
				break;
			case 1:
				[[SimpleAudioEngine sharedEngine] playEffect:@"snd-gameplay-geronimo.caf"];
				break;
			case 2:
				[[SimpleAudioEngine sharedEngine] playEffect:@"snd-gameplay-yaaa.caf"];
				break;
			case 3:
				[[SimpleAudioEngine sharedEngine] playEffect:@"snd-gameplay-argh.caf"];
				break;
			case 4:
				[[SimpleAudioEngine sharedEngine] playEffect:@"snd-gameplay-yupi.caf"];
				break;
			case 5:
				[[SimpleAudioEngine sharedEngine] playEffect:@"snd-gameplay-waka.caf"];
				break;				
				
		}
	}
}

-(void) throwFinish
{
	state_ = kGameOver;
}

#ifdef __CC_PLATFORM_IOS

#pragma mark GameNode - iOS GameCenterManager Delegate

- (void) achievementSubmitted:(GKAchievement*)ach error:(NSError*)error
{
	if((error == NULL) && (ach != NULL))
	{
		CCNotifications *noti = [CCNotifications sharedManager];

		//
		// SapusTongue only uses 100% achievements
		// but this code also shows how to report not 100% achievements
		//
		if(ach.percentComplete == 100.0)
		{
			[noti addWithTitle:@"Achievement Earned!"
					   message:[NSString stringWithFormat: @"Great job!  You earned an achievement: \"%@\"", NSLocalizedString(ach.identifier, NULL)]
						 image:@"trophy.png"
						   tag:-1
					   animate:YES
				 waitUntilDone:NO];
		}
		else if(ach.percentComplete > 0)
		{
			[noti addWithTitle:@"Achievement Progress!"
					   message:[NSString stringWithFormat: @"Great job!  You're %.0f\%% of the way to: \"%@\"",ach.percentComplete, NSLocalizedString(ach.identifier, NULL)]
						 image:@"trophy.png"
						   tag:-1
					   animate:YES
				 waitUntilDone:NO];
		}
	}	
}

#pragma mark GameNode - iOS Touches and accelerometer

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	
	CCDirector *director = [CCDirector sharedDirector];
	location = [director convertToGL: location];
	CGSize winSize = [director winSize];
	
#define kBorder 2
	if( location.x > kBorder && location.x < (winSize.width-kBorder) && location.y > kBorder && location.y < (winSize.height-kBorder) ) {
		if( state_ == kGameStart ) {
			if( jointAdded_ ) {
				[self removeJoint];
			} else {
				[self addJoint];
			}
		}
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	static float prevX=0, prevY=0;
	

#define kFilterFactor 0.05f
	
	if( state_ == kGameStart ) {
		float accelX = (float)acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
		float accelY = (float)acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
		prevX = accelX;
		prevY = accelY;
		
		force_ = cpv( (float)-acceleration.y, (float)acceleration.x);
//		force_ = cpv( (float)acceleration.y, (float)-acceleration.x);

		
	} else if( state_ == kGameFlying ) {
		force_ = cpvzero;
	}
}

#pragma mark GameNode - Mac Mouse events

#elif defined(__CC_PLATFORM_MAC)

-(BOOL) ccMouseUp:(NSEvent*) event
{
	if( state_ == kGameStart ) {
		if( jointAdded_ ) {
			[self removeJoint];
		} else {
			[self addJoint];
		}
	}
	
	force_ = cpvzero;

	// YES means that you claim this event as yours, and it won't be propagated.
	// return NO to propagate it.
	return YES;
}

-(BOOL) ccMouseDragged:(NSEvent *)event
{	
	if( state_ == kGameStart ) {
		CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
		CGPoint origin = ccp(kJointX, kJointY);
		
		CGPoint diff = ccpSub( location, origin );
		
		CGPoint normalized = ccpNormalize( diff );
		force_ = cpv( normalized.x, normalized.y );

	} else if( state_ == kGameFlying ) {
		force_ = cpvzero;
	}
	
	// YES means that you claim this event as yours, and it won't be propagated.
	// return NO to propagate it.
	return YES;
}

#endif
@end


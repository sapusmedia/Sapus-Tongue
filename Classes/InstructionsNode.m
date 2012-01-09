//
//  InstructionsNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


//
// The InstructionsNode.m contains a simplified logic of GameNode
//
// The entry point of the node is "Init & Creation"
//


// cocos2d imports
#import "cocos2d.h"
#import "chipmunk.h"
#import "ChipmunkHelper.h"

#if __CC_PLATFORM_IOS
#import <MediaPlayer/MediaPlayer.h>
#endif

// local imports
#import "SapusConfig.h"
#import "InstructionsNode.h"
#import "SimpleAudioEngine.h"
#import "MainMenuNode.h"
#import "SoundMenuItem.h"
#import "SapusTongueAppDelegate.h"
#import "FloorNode.h"
#import "MountainNode.h"

#ifdef __CC_PLATFORM_IOS
#define kJointX 142
#define kJointY 130
#elif defined(__CC_PLATFORM_MAC)
#define kJointX 210
#define kJointY 170
#endif

#define kAccelerometerFrequency 60

static const float	kSapusTongueLength = 80.0f;
static const float kSapusMass = 1.0f;
static const float kForceFactor = 350.0f;
static const float kSapusElasticity = 0.4f;
static const float kSapusFriction = 0.8f;
static const float kSapusOffsetY = 32;
static const float kCircleRadius = 12.0f;

#ifdef __CC_PLATFORM_IOS
static const float kGravityRoll = -50.0f;
#elif defined(__CC_PLATFORM_MAC)
static const float kGravityRoll = -350.0f;
#endif

static int totalScore = 0;


enum {
	kCollTypeIgnore,
	kCollTypeSapus,
	kCollTypeFloor,
	kCollTypeWalls,
	kCallTypeBee,
};

#pragma mark Chipmunk Callbacks


static void
eachShape(cpShape *shape, void* instance)
{
//	InstructionsNode *self = (InstructionsNode*) instance;
	CCSprite *sprite = shape->data;
	if( sprite ) {
		cpVect c;
		cpBody *body = shape->body;
		
		c = cpvadd(body->p, cpvrotate(cpvzero, body->rot));
		
		[sprite setPosition: ccp( c.x, c.y)];
		[sprite setRotation: CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

#pragma mark InstructionsNode - Private interaces
@interface InstructionsNode ()
-(void) setupSapus;
-(void) setupTongue;
-(void) setupJoint;
-(void) setupBackground;
-(void) setupChipmunk;

-(void) drawTongue;

@end

@interface InstructionsNode (PrivateMovie)
-(NSURL*) movieURL;
-(void)playMovieAtURL:(NSURL*)theURL;
@end


@implementation InstructionsNode

+(CCScene*) scene
{
	CCScene *s = [CCScene node];
	
	id game = [InstructionsNode node];
	[s addChild:game];
	
	return s;
}

#pragma mark InstructionsNode - Physics Init & Creation

-(id) init
{
	if( (self=[super init] ) ) {
	
#ifdef __CC_PLATFORM_IOS
		self.isAccelerometerEnabled = YES;
		
		SapusTongueAppDelegate *appDelegate = (SapusTongueAppDelegate*) [[UIApplication sharedApplication] delegate];
		isLandscapeLeft_ = appDelegate.isLandscapeLeft;

#elif defined(__CC_PLATFORM_MAC)
		self.isMouseEnabled = YES;
#endif
		
		[self setupBackground];
		[self setupChipmunk];
		[self setupTongue];
		
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
		
		CGSize s = [[CCDirector sharedDirector] winSize];

		CCMenu *menu;
#ifdef __CC_PLATFORM_IOS
		CCMenuItem* item1 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-viewvideo-normal.png" selectedSpriteFrameName:@"btn-viewvideo-selected.png" target:self selector:@selector(viewVideoCB:)];	
#endif // __CC_PLATFORM_IOS
		CCMenuItem* item2 = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-menumed-normal.png" selectedSpriteFrameName:@"btn-menumed-selected.png" target:self selector:@selector(menuCB:)];	

#ifdef __CC_PLATFORM_IOS
		menu = [CCMenu menuWithItems:item1, item2, nil];
#elif defined(__CC_PLATFORM_MAC)
		menu = [CCMenu menuWithItems:item2, nil];
#endif
		[menu alignItemsVertically];
		menu.position = ccp(s.width-60,45);
		[self addChild:menu z:1];
			
		
		[self scheduleUpdate];
		
		totalScore = 0;
	}
	
	return self;
}

-(void) setupBackgroundTree
{
	// tree
	CCSprite *tree = [CCSprite spriteWithFile:@"tree1.png"];
	tree.anchorPoint = CGPointZero;
	[self addChild:tree z:-5];
	
	// floor
	FloorNode *floor = [FloorNode node];
	[self addChild:floor z:-6];		
}

-(void) setupBackground
{
	// tree

#ifdef __CC_PLATFORM_IOS
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#endif // __CC_PLATFORM_IOS
		[self setupBackgroundTree];

	// gradient
	CCLayerGradient *g = [CCLayerGradient layerWithColor:ccc4(0xc3,0xf2,0xf6,0xff) fadingTo:ccc4(0x73,0xa2,0xa6,0xff) alongVector:ccp(0,1)];
	[self addChild: g z:-10];		
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCSprite *tree = [CCSprite spriteWithFile:@"SapusInstructions.png"];
	tree.position = ccp( s.width/2, s.height/2);
	[self addChild:tree z:-1];
}

-(void) setupChipmunk
{	
	cpInitChipmunk();
		
	space_ = cpSpaceNew();

	space_->iterations = 10;
	space_->gravity = cpv(0, kGravityRoll);
	
	cpShape *shape;

	// pivot point. fly
	CCSprite *fly = [CCSprite spriteWithSpriteFrameName:@"fly.png"];
	[self addChild:fly z:-1];
	
	pivotBody_ = cpBodyNew(INFINITY, INFINITY);
	pivotBody_->p =  cpv(kJointX,kJointY);
	shape = cpCircleShapeNew(pivotBody_, 5.0f, cpvzero);
	shape->e = 0.9f;
	shape->u = 0.9f;
	shape->data = fly;
	cpSpaceAddStaticShape(space_, shape);

	[self setupSapus];
	[self setupJoint];
	[self addJoint];
}

-(void) setupJoint
{
	joint_ = cpPivotJointNew(sapusBody_, pivotBody_, cpv(kJointX, kJointY));
}

-(void) setupSapus
{	
	sapusSprite_ = [[CCSprite spriteWithSpriteFrameName:@"sapus_01.png"] retain];		
	[self addChild:sapusSprite_ z:-1];
	
	CGSize s = [sapusSprite_ contentSize];
	CGPoint ta = sapusSprite_.anchorPoint;
	ta.y = kSapusOffsetY / s.height;
	sapusSprite_.anchorPoint = ta;
	
			
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
	tongue_ = [[CCTextureCache sharedTextureCache] addImage: @"SapusTongue.png"];
	[tongue_ retain];
}

-(void) dealloc
{
	[sapusSprite_ release];
	[tongue_ release];
	
	ChipmunkFreeSpaceChildren(space_);
	cpSpaceFree(space_);
	
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];	

	[super dealloc];
}

//
// The heavy part of init and the UIKit controls are initialized after the transition is finished.
// This trick is used to:
//    * create a smooth transition (load heavy resources after the transition is finished)
//    * show UIKit controls after the transition to simulate that they transition like any other control
//

-(void) onEnter
{
	[super onEnter];

#ifdef __CC_PLATFORM_IOS
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
#endif

}

#pragma mark InstructionsNode - Physics Main Loop

-(void) update: (ccTime) delta
{
	cpBodyResetForces(sapusBody_);

	cpVect f = cpvmult(force_, kForceFactor);

	cpBodyApplyForce(sapusBody_, f, cpvzero);
	
	int steps = 7;
	cpFloat dt = delta/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space_, dt);
	}
	
	cpSpaceEachShape(space_, &eachShape, self);
}


-(void) draw
{
	[self drawTongue];
}

-(void) drawTongue
{
	
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

	float tongueLen = 15;
	
	sapusV.x = sapusV.x + tongueLen*xs;
	sapusV.y = sapusV.y + tongueLen*ys;	
	
	GLfloat	vertices[] = {	(sapusV.x - x*1.5f),		(sapusV.y - y*1.5f),		0.0f,
							(sapusV.x + x*1.5f),		(sapusV.y + y*1.5f) ,		0.0f,
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
	space_->gravity = cpv(0, kGravityRoll);
}

#pragma mark InstructionsNode - Accelerometer Event (iOS only)

#ifdef __CC_PLATFORM_IOS
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float)acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float)acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;

	prevX = accelX;
	prevY = accelY;
	
	// landscape left mode
	if( isLandscapeLeft_ )
		force_ = cpv( (float)-acceleration.y, (float)acceleration.x);
	else
		force_ = cpv( (float)acceleration.y, (float)-acceleration.x);
}

#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseDragged:(NSEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	CGPoint origin = ccp(kJointX, kJointY);
	
	CGPoint diff = ccpSub( location, origin );
	
	CGPoint normalized = ccpNormalize( diff );
	force_ = cpv( normalized.x, normalized.y );

	return YES;
}

-(BOOL) ccMouseUp:(NSEvent *)event
{
	force_ = cpv(0,0);
	return YES;
}
#endif

#pragma mark InstructionsNode - Menu Callbacks

-(void) menuCB:(id) sender {
	[[CCDirector sharedDirector] replaceScene: [CCTransitionShrinkGrow transitionWithDuration:1.0f scene: [MainMenuNode scene]]];
}

-(void) viewVideoCB:(id) sender {
	[self playMovieAtURL:[self movieURL]];
}

#pragma mark InstructionsNode - Movie Player (iOS only)

#ifdef __CC_PLATFORM_IOS

// return a URL for the movie file in our bundle
-(NSURL *)movieURL
{
    if (mMovieURL == nil)
    {
        NSBundle *bundle = [NSBundle mainBundle];
        if (bundle) 
        {
            NSString *moviePath = [bundle pathForResource:@"Movie" ofType:@"m4v"];
            if (moviePath)
            {
                mMovieURL = [NSURL fileURLWithPath:moviePath];
                [mMovieURL retain];
            }
        }
    }
    
    return mMovieURL;
}

-(void)playMovieAtURL:(NSURL*)theURL
{
	// TIP:
	// The easiest way to play a movie, is by creating a Movie View Controller
	// and present it as modal using the Navigation Controller
	//
	MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:theURL];

	if( mpvc ) {
		
		[[mpvc moviePlayer] prepareToPlay];
		
		SapusTongueAppDelegate *app = (SapusTongueAppDelegate*) [[UIApplication sharedApplication] delegate];
		UINavigationController *navControler = [app navController];

		[navControler presentModalViewController:mpvc animated:YES];

		// TIP:
		// There is no need to pause cocos2d, cocos2d will be automatically paused
		// But we need to pause the music in order to listen to the movie audio.
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		
		// play the video
		[[mpvc moviePlayer] play];
		
		// Register for the playback finished notification.
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(myMovieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:[mpvc moviePlayer]];
	}
	
	[mpvc release];
}

// When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification
{	
	// TIP:
	// There is no need to re-animate the cocos2d view. cocos2d will be resumed automatically.
	// But we need to resume the audio
	[[CDAudioManager sharedManager] audioSessionResumed];

	SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
	CDAudioManager *audioMgr = [CDAudioManager sharedManager];

	// If the music was already muted, then play the music and set it as muted again
	// If it wasn't muted, just play it
	BOOL m = [audioMgr mute];
	[audioEngine playBackgroundMusic:@"music-background.mp3"];
	[audioMgr setMute:m];
	
	// remove the movie player 
	MPMoviePlayerController* mp = [aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:mp];

	// Dismiss the Movie View Controller
	SapusTongueAppDelegate *app = (SapusTongueAppDelegate*)[[UIApplication sharedApplication] delegate];
	[[app navController] dismissMoviePlayerViewControllerAnimated];	
}

#endif // __CC_PLATFORM_IOS

@end


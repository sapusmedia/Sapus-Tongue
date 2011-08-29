//
//  GameNode.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "cocos2d.h"
#import "chipmunk.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#import "GameCenterManager.h"
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED

typedef enum {
	kGameWaiting,
	kGameStart,
	kGameFlying,
	kGameOver,
	kGameTryAgain,
	kGameDrawTongue,
	kGameIsBeingReplaced,
} tGameState;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface GameNode : CCLayer <UIAccelerometerDelegate, GameCenterManagerDelegate>
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
@interface GameNode : CCLayer
#endif
{
	ccTime		flyingDeltaAccum_;
	CCTexture2D	*tongue_;
	
	// accumulator for the physics engine. Used only in Fixed-Time-Step physics
	float		physicsAccumulator_;
	
	// Whether or not the device is landscape left or right
	// in order to read the accelerometer correctly
	BOOL		isLandscapeLeft_;

	// TIP:
	// GameHUD will access these variables, and instead of creating properties for each one of these,
	// it is faster to make them public
	// In general, I don't recommend making public every variable, but sometimes it is
	// faster
@public
	CCSprite		*sapusSprite_;
	
	// Physics: Hero
	cpSpace			*space_;
	cpConstraint	*joint_;
	cpBody			*pivotBody_;
	cpBody			*sapusBody_;
	cpVect			force_;
	BOOL			jointAdded_;
	
	// Physics: Wall
	cpShape			*wallLeft_, *wallBottom_, *wallRight_;
		
	float			throwAngle_;
	float			throwVelocity_;
	BOOL			maxHeightAchievementTriggered_;
	
	tGameState		state_;
	
	int				displayFrame_;	
}

// returns the scene
+(CCScene*) scene;

// returns an array of the names that will be loaded
// useful to load the asynchronously
+(NSArray*) textureNames;


+(int) score;
-(void) addJoint;
@end

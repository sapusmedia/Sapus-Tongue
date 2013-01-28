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


#import "cocos2d.h"
#import "chipmunk.h"

#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#import "GameCenterManager.h"
#endif // __CC_PLATFORM_IOS

typedef enum {
	kGameWaiting,
	kGameStart,
	kGameFlying,
	kGameOver,
	kGameTryAgain,
	kGameDrawTongue,
	kGameIsBeingReplaced,
} tGameState;

#ifdef __CC_PLATFORM_IOS
@interface GameNode : CCLayer <UIAccelerometerDelegate, GameCenterManagerDelegate>
#elif __CC_PLATFORM_MAC
@interface GameNode : CCLayer
#endif
{
	ccTime		flyingDeltaAccum_;
	CCTexture2D	*tongue_;
	
	// accumulator for the physics engine. Used only in Fixed-Time-Step physics
	float		physicsAccumulator_;
	
	CCPhysicsDebugNode *debugPhysics_;
	
	// TIP:
	// GameHUD will access these variables, and instead of creating properties for each one of these,
	// it is faster to make them public
	// In general, I don't recommend making public every variable, but sometimes it is faster
@public
	CCPhysicsSprite		*sapusSprite_;
	
	// Physics: Hero
	cpSpace			*space_;
	cpConstraint	*joint_;
	cpBody			*pivotBody_;
	cpBody			*sapusBody_;
	cpVect			force_;
	BOOL			jointAdded_;
	
	float			throwAngle_;
	float			throwVelocity_;
	BOOL			maxHeightAchievementTriggered_;
	
	tGameState		state_;
	
	int				displayFrame_;	
}

@property (nonatomic, readonly) CCPhysicsDebugNode *debugPhysics;

// returns the scene
+(CCScene*) scene;

// returns an array of the names that will be loaded
// useful to load the asynchronously
+(NSArray*) textureNames;


+(int) score;
-(void) addJoint;
@end

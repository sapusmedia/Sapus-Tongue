//
//  InstructionsNode.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "cocos2d.h"
#import "chipmunk.h"

#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif


#ifdef __CC_PLATFORM_IOS
@interface InstructionsNode : CCLayer <UIAccelerometerDelegate>
#elif defined(__CC_PLATFORM_MAC)
@interface InstructionsNode : CCLayer
#endif
{
	CCSprite		*sapusSprite_;
	
	ccTime			flyingDeltaAccum_;
	CCTexture2D		*tongue_;
	
	NSURL			*mMovieURL;
	
	BOOL			isLandscapeLeft_;


	cpSpace			*space_;
	cpConstraint	*joint_;
	cpBody			*pivotBody_;
	cpBody			*sapusBody_;
	cpVect			force_;
	BOOL			jointAdded_;
}

+(CCScene*) scene;
-(void) addJoint;
@end

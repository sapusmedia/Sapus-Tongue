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

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#endif


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface InstructionsNode : CCLayer <UIAccelerometerDelegate>
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
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

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
	
	CCSprite		*sapusSprite;
	
	ccTime		flyingDeltaAccum;
	CCTexture2D	*tongue;
	
	NSURL *mMovieURL;
	
	BOOL			newMVPlayer;
	
	BOOL			isLandscapeLeft_;


@public
	cpSpace			*space;
	cpConstraint	*joint;
	cpBody			*pivotBody;
	cpBody			*sapusBody;
	cpVect			force;
	BOOL			jointAdded;
}

+(CCScene*) scene;
-(void) addJoint;
@end

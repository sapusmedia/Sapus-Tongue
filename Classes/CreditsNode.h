//
//  CreditsNode.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 12/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "cocos2d.h"

@interface CreditsNode : CCLayer {
	
	NSMutableArray	*nodesToRemove_;
	CCSprite		*ufo_;
	ccTime			time_;
	float			ufoY_;
	
	CGSize			winSize_;
}

+(id) scene;

@end

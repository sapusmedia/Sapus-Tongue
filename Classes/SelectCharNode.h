//
//  SelectCharNode.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 06/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import "cocos2d.h"

enum
{
	kSTSelectedCharSapus,
	kSTSelectedCharMonus,
};

@interface SelectCharNode : CCLayer {
	CCSprite		*sapusSprite_;
	CCSprite		*monusSprite_;
	
	CCMenuItem		*startButton_;
}

+(id) scene;
+(int) selectedChar;

@end

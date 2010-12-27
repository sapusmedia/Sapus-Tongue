//
//  GradientLayer.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 09/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "cocos2d.h"

@interface GradientLayer : CCLayerColor {
}

-(void) setBottomColor:(ccColor4B)cb topColor:(ccColor4B)ct;

@end

//
//  SoundMenuItem.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 17/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface SoundMenuItem : CCMenuItemSprite {

}

/** creates an initialize an item with Sprite Frame Names */
+(id) itemFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector;

/** creates an initialize an item with Sprite Frame Names */
+(id) itemFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName disabledSpriteFrameName:(NSString*)disabled target:(id)target selector:(SEL)selector;

/** initialize an item with Sprite Frame Names */
-(id) initFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName disabledSpriteFrameName:(NSString*)disabledSpriteFrameName target:(id)target selector:(SEL)selector;

/** initialize an item with Sprite Frame Names */
-(id) initFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector;

@end

//
//  MainMenuNode.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 06/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "cocos2d.h"
#import "SoundMenuItem.h"

#ifdef LITE_VERSION
#import <UIKit/UIKit.h>
#import "AdViewController.h"
#endif // LITE_VERSION

@interface MainMenuNode : CCLayer
{
#ifdef LITE_VERSION
	// iAd related
	BOOL				inStage_;
	BOOL				musicIsEnabled_;
	BOOL				supportsAds_;
	AdViewController	*adViewController_;
#endif // LITE_VERSION

}


// returns a MainMenu scene
+(id) scene;

// returns an array of the names that will be loaded
// useful to load the asynchronously
+(NSArray*) textureNames;
@end



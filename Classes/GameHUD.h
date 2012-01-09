//
//  GameHUD.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 04/08/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import "cocos2d.h"

#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif


enum {
	kTagConnectionFailedAlert = 1,
	kTagPauseAlert = 2,
};

typedef enum {
	kHUDGame,
	kHUDMenu,
	kHUDRemoveMenu,
} tHUDState;

@class GameNode;

#if __CC_PLATFORM_IOS
@interface GameHUD : CCLayer  <UITextFieldDelegate, UIAlertViewDelegate>
#elif __CC_PLATFORM_MAC
@interface GameHUD : CCLayer
#endif
{
	
#if __CC_PLATFORM_IOS
	// UI controls
	UITextField		*nameField_;
	UIToolbar		*toolbar_;
	UISwitch		*switchCtl_;
	UIActivityIndicatorView *activityIndicator_;
#endif // __CC_PLATFORM_IOS

	// pointer to State
	GameNode		*game_;

	// player name
	NSString		*name_;

	tHUDState	state;
	
	CCLabelAtlas	*scoreLabel_;
	CCSprite		*arrowSprite_;
	CCLabelAtlas	*angleLabel_;
	CCLabelAtlas	*speedLabel_;
	CCSprite		*speedSprite_;
	
	// global scores stuff
	BOOL					submittingInProgress_;
}

// initialization
-(id) initWithGame:(GameNode*) game;

@end

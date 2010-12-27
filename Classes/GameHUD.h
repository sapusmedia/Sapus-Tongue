//
//  GameHUD.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 04/08/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import "cocos2d.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
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

#if __IPHONE_OS_VERSION_MAX_ALLOWED
@interface GameHUD : CCLayer  <UITextFieldDelegate, UIAlertViewDelegate>
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
@interface GameHUD : CCLayer
#endif
{
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED
	// UI controls
	UITextField		*nameField;
	UIToolbar		*toolbar;
	UISwitch		*switchCtl;
	UIActivityIndicatorView *activityIndicator;	
#endif

	// pointer to State
	GameNode *game;

	// player name
	NSString		*name;

	tHUDState	state;
	
	CCLabelAtlas	*scoreAtlas;
	CCSprite		*arrowSprite;
	CCLabelAtlas	*angleAtlas;
	CCLabelAtlas	*speedAtlas;
	CCSprite		*speedSprite;
	
	// global scores stuff
	BOOL					submittingInProgress;	
}

// initialization
-(id) initWithGame:(GameNode*) game;

@end

//
//  HiScoresNode.h
//  Sapus Tongue
//
//  Created by Ricardo Quesada on 18/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import "cocos2d.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>

@class GameCenterViewController;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#endif


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface HiScoresNode : CCLayer <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

#elif __MAC_OS_X_VERSION_MAX_ALLOWED
@interface HiScoresNode : CCLayer <NSTableViewDelegate, NSTableViewDataSource>
#endif
{
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	UITableView					*myTableView_;
	UIActivityIndicatorView		*activityIndicator_;
	BOOL						displayLocalScores_;
	GameCenterViewController	*gameCenterViewController_;
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
	
}

+(id) sceneWithPlayAgain: (BOOL) again;
-(id) initWithPlayAgain: (BOOL) again;
@end

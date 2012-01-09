//
//  HiScoresNode.h
//  Sapus Tongue
//
//  Created by Ricardo Quesada on 18/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import "cocos2d.h"

#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#elif defined(__CC_PLATFORM_MAC)
#endif


#ifdef __CC_PLATFORM_IOS
@interface HiScoresNode : CCLayer <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>

#elif __CC_PLATFORM_MAC
@interface HiScoresNode : CCLayer <NSTableViewDelegate, NSTableViewDataSource>
#endif
{
	
#ifdef __CC_PLATFORM_IOS
	UITableView					*myTableView_;
	UIActivityIndicatorView		*activityIndicator_;
	BOOL						displayLocalScores_;
#endif // __CC_PLATFORM_IOS
	
}

+(id) sceneWithPlayAgain: (BOOL) again;
-(id) initWithPlayAgain: (BOOL) again;
@end

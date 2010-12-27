//
//  GameCenterViewController.h
//  SapusTongue-iOS
//
//  Created by Ricardo Quesada on 10/8/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#import "GameCenterManager.h"


@interface GameCenterViewController : UIViewController <GameCenterManagerDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
}

// show the leaderboard
-(void) showLeaderboard;

// show the Game Center Achievements
-(void) showAchievements;
@end

//
//  GameHUDSaveScore.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 8/28/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "GameHUD.h"


@interface GameHUD (SaveScoreExtension)

-(void) saveScoreButtonPressed;
-(void) submitLocalScoreWithName:(NSString*) name;

#if __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) submitGlobalScoreWithName: (NSString*) name;
-(void) submitScore;
-(void) gotoHiScores;
-(UITextField*) newTextField_Rounded;
#endif


@end

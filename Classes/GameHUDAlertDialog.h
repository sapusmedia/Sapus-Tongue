//
//  GameHUDAlertDialog.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 8/28/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "GameHUD.h"


@interface GameHUD (AlertExtension)

-(void) pauseButtonPressedShowAlert;
-(void) scorePostFailedShowAlert;

@end

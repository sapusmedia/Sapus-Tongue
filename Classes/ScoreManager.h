//
//  ScoreManager.h
//  SapusTongue-iOS
//
//  Created by Ricardo Quesada on 10/12/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import "GameCenterManager.h"
#import "CCNotifications.h"

@interface ScoreManager : NSObject <GameCenterManagerDelegate, CCNotificationsDelegate>

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@interface ScoreManager : NSObject
#endif
{

	NSMutableArray		*scores_;
	NSMutableArray		*globalScores_;
    // Opaque reference to the SQLite database.
    sqlite3				*database_;

	// send global scores
	BOOL				sendGlobalScores_;
}

// Makes the main array of scores objects available to other objects in the application.
@property (nonatomic, retain) NSMutableArray *scores, *globalScores;

@property (nonatomic, readonly) sqlite3 *database;
@property (nonatomic, readwrite) BOOL sendGlobalScores;

+(ScoreManager*) sharedManager;

-(void) initScores;
-(void) loadScoresFromDB;
@end

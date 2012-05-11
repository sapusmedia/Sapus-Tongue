/*
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011-2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "ScoreManager.h"
#import "LocalScore.h"

#ifdef __CC_PLATFORM_IOS
#import "CCNotifications.h"
#import "GameCenterManager.h"
#endif

static ScoreManager *sharedManager = nil;

@interface ScoreManager ()
-(void) createEditableCopyOfDatabaseIfNeeded;
-(void) updateDBSchema;
-(void) initializeDatabase;
-(void) loadScoresFromDB;
@end

@implementation ScoreManager

@synthesize scores=scores_;
@synthesize database=database_;

+ (ScoreManager *)sharedManager
{
	if (!sharedManager)
		sharedManager = [[ScoreManager alloc] init];
	
	return sharedManager;
}

+(id)alloc
{
	NSAssert(sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

-(id) init
{
	if( (self = [super init]) ) {
		
		[self createEditableCopyOfDatabaseIfNeeded];
		[self initializeDatabase];
	}
	
	return self;
}

-(void) initScores
{		
#ifdef __CC_PLATFORM_IOS
	
	// GameCenter initialization
	if( [GameCenterManager isGameCenterAvailable] ) {
		
		[[GameCenterManager sharedManager] setDelegate:self];
		[[GameCenterManager sharedManager] authenticateLocalUser];
		
		CCNotifications *notifications= [CCNotifications sharedManager];
		[notifications setPosition:kCCNotificationPositionBottom];
		[[CCDirector sharedDirector] setNotificationNode:notifications];
		
		/** init CCNotifications **/
		[notifications setDelegate:self];	
		
	}
	else
	{
		CCLOG(@"GameCenter not available");
	}
#endif // __CC_PLATFORM_IOS
}

#pragma mark ScoreManager - Database Stuff

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"scores.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
	
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"scores.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase
{
    NSMutableArray *scoresArray = [[NSMutableArray alloc] init];
    self.scores = scoresArray;
    [scoresArray release];
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"scores.sqlite"];
    // Open the database. The database was prepared outside the application.
	
	
    if (sqlite3_open([path UTF8String], &database_) == SQLITE_OK) {
		
		[self updateDBSchema];
		
		[self loadScoresFromDB];
		
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database_);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database_));
        // Additional error handling, as appropriate...
    }
}

// Creates the angle & speed column in case they don't exists
// This can happen when migrating from Sapus Tongue v1.0 to v1.2
//
// TIP:
//   If you are chaning the schema of your game, then you should provide
//   a migration "tool" (like this function) to update the old schema.
//   Updates don't remove the old data, it will be reused.
-(void) updateDBSchema
{
	sqlite3_stmt	*alter1_stmt = nil;
	sqlite3_stmt	*alter2_stmt = nil;
	sqlite3_stmt	*test_rows_stmt = nil;
	int rc;
	
	char *alter1_sql = "ALTER TABLE scores ADD COLUMN angle INTEGER DEFAULT 0";
	char *alter2_sql = "ALTER TABLE scores ADD COLUMN speed INTEGER DEFAULT 0";	
	
	rc = sqlite3_prepare_v2(database_, "SELECT angle,speed FROM scores", -1, &test_rows_stmt, NULL);
	if( rc != SQLITE_OK ) {
		// Query failed... using old schema.
		// So, update schema
		NSLog(@"%s", sqlite3_errmsg(database_));
		NSLog(@"Updated Sapus Tongue schema");
		
		rc = sqlite3_prepare_v2( database_, alter1_sql, -1, &alter1_stmt, NULL);
		if( rc != SQLITE_OK)
			NSAssert1(0, @"Error: failed to update scheme message '%s'.", sqlite3_errmsg(database_));
		sqlite3_step( alter1_stmt);
		
		rc = sqlite3_prepare_v2( database_, alter2_sql, -1, &alter2_stmt, NULL);
		if( rc != SQLITE_OK)
			NSAssert1(0, @"Error: failed to update scheme message '%s'.", sqlite3_errmsg(database_));
		sqlite3_step( alter2_stmt);		
	}
	if (alter1_stmt)
		sqlite3_finalize( alter1_stmt );
	if (alter2_stmt)
		sqlite3_finalize( alter2_stmt );
	if (test_rows_stmt)
		sqlite3_finalize( test_rows_stmt );
}

-(void) loadScoresFromDB
{
	[scores_ removeAllObjects];
	
	//
	// Load only the best 50 scores
	//
	const char *sql = "SELECT pk FROM scores ORDER BY score DESC LIMIT 50";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database_, sql, -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			LocalScore *score = [[LocalScore alloc] initWithPrimaryKey:primaryKey database:database_];
			[scores_ addObject:score];
			[score release];
		}
		// "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
	}
}

#ifdef __CC_PLATFORM_IOS

#pragma mark AppDelegate - GameCenterManagerDelegate (iOS)
- (void) processGameCenterAuth: (NSError*) error
{
	// TIP:
	// Cache the achievements at init time (recommended by Apple)
	[[GameCenterManager sharedManager] loadAchievements];
	
	// TIP: You can reset your achievements programatically. You might want to include this option in your game.
	//	[[GameCenterManager sharedManager] resetAchievements];	
}

- (void) achievementResetResult: (NSError*) error;
{
}

#pragma mark AppDelegate - CCNotifications delegate (iOS)

- (void) notification:(ccNotificationData*)notification newState:(char)state
{
	switch (state) {
		case kCCNotificationStateHide:
			CCLOG(@"Notification hidden");
			//Play sound
			break;
		case kCCNotificationStateShowing:
			CCLOG(@"Showing notification");
			//Play sound
			
			break;
		case kCCNotificationStateAnimationIn:
			CCLOG(@"Animation-In, began");
			//Play sound
			
			break;
		case kCCNotificationStateAnimationOut:
			CCLOG(@"Animation-Out, began");
			//Play sound
			
			break;
		default: break;
	}
}

#endif // __CC_PLATFORM_IOS

@end

//
//  LocalScore.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 22/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

//
// A SQLite interface to the local Scores
//

#import "LocalScore.h"

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;

@implementation LocalScore

@synthesize score, playername, playerType, angle, speed;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements
{
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (init_statement) sqlite3_finalize(init_statement);
}

// Creates the object with primary key.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db
{
    if (self = [super init]) {
        primaryKey = pk;
        database = db;
        // Compile the query for retrieving score data.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT playername,score,speed,angle,playerType FROM scores WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
				NSLog(@"%s", sqlite3_errmsg(database));
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			self.playername = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
			self.score = [NSNumber numberWithInt: sqlite3_column_int(init_statement,1)];
			self.speed = [NSNumber numberWithInt: sqlite3_column_int(init_statement,2)];
			self.angle = [NSNumber numberWithInt: sqlite3_column_int(init_statement,3)];
			self.playerType = [NSNumber numberWithInt: sqlite3_column_int(init_statement,4)];
        } else {
			playername = @"No name";
			score = [NSNumber numberWithInt:0];
			speed = [NSNumber numberWithInt:0];
			angle = [NSNumber numberWithInt:0];
			playerType = [NSNumber numberWithInt:0];
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
    }
    return self;
}

- (void)insertIntoDatabase:(sqlite3 *)db
{
    database = db;
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any LocalScore object.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO scores (playername,score,speed,angle,playerType) VALUES(?,?,?,?,?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement, 1, [playername UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement, 2, [score intValue]);
    sqlite3_bind_int(insert_statement, 3, [speed intValue]);
    sqlite3_bind_int(insert_statement, 4, [angle intValue]);
    sqlite3_bind_int(insert_statement, 5, [playerType intValue]);

    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    } else {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        primaryKey =  (NSInteger)sqlite3_last_insert_rowid(database);
    }
}

- (void)dealloc
{
    [playername release];
    [score release];
	[speed release];
	[angle release];
	[playerType release];
    [super dealloc];
}

#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSInteger)primaryKey
{
    return primaryKey;
}

@end


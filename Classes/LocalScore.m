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

//
// A SQLite interface to the local Scores
//

#import "LocalScore.h"

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;

@implementation LocalScore

@synthesize score=score_, playername=playername_, playerType=playerType_, angle=angle_, speed=speed_;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements
{
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (init_statement) sqlite3_finalize(init_statement);
}

// Creates the object with primary key.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db
{
    if ((self = [super init] )) {
        primaryKey_ = pk;
        database_ = db;
        // Compile the query for retrieving score data.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT playername,score,speed,angle,playerType FROM scores WHERE pk=?";
            if (sqlite3_prepare_v2(database_, sql, -1, &init_statement, NULL) != SQLITE_OK) {
				NSLog(@"%s", sqlite3_errmsg(database_));
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database_));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, (int)primaryKey_);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			self.playername = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
			self.score = [NSNumber numberWithInt: sqlite3_column_int(init_statement,1)];
			self.speed = [NSNumber numberWithInt: sqlite3_column_int(init_statement,2)];
			self.angle = [NSNumber numberWithInt: sqlite3_column_int(init_statement,3)];
			self.playerType = [NSNumber numberWithInt: sqlite3_column_int(init_statement,4)];
        } else {
			playername_ = @"No name";
			score_ = [NSNumber numberWithInt:0];
			speed_ = [NSNumber numberWithInt:0];
			angle_ = [NSNumber numberWithInt:0];
			playerType_ = [NSNumber numberWithInt:0];
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
    }
    return self;
}

- (void)insertIntoDatabase:(sqlite3 *)db
{
    database_ = db;
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any LocalScore object.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO scores (playername,score,speed,angle,playerType) VALUES(?,?,?,?,?)";
        if (sqlite3_prepare_v2(database_, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database_));
        }
    }
    sqlite3_bind_text(insert_statement, 1, [playername_ UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement, 2, [score_ intValue]);
    sqlite3_bind_int(insert_statement, 3, [speed_ intValue]);
    sqlite3_bind_int(insert_statement, 4, [angle_ intValue]);
    sqlite3_bind_int(insert_statement, 5, [playerType_ intValue]);

    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database_));
    } else {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        primaryKey_ =  (NSInteger)sqlite3_last_insert_rowid(database_);
    }
}

- (void)dealloc
{
	[playername_ release];
	[score_ release];
	[speed_ release];
	[angle_ release];
	[playerType_ release];
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
    return primaryKey_;
}

@end


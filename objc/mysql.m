/*!
@file mysql.m
@discussion Objective-C components of the Nu MySQL wrapper.
@copyright Copyright (c) 2008 Neon Design Technology, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
#import <Foundation/Foundation.h>
#import "mysql.h"

@interface MySQLField : NSObject
{
    MYSQL_FIELD *field;
}

@end

@implementation MySQLField

@end

@interface MySQLResult : NSObject
{
    MYSQL_RES *result;
}

@end

@implementation MySQLResult

+ (id) resultWithResult:(MYSQL_RES *) result
{
    MySQLResult *object = [[self alloc] init];
    object->result = result;
    return object;
}

- (id) nextRow
{
    int fields = mysql_num_fields(result);
    MYSQL_ROW row = mysql_fetch_row(result);
    if (row == NULL)
        return nil;
    else {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < fields; i++) {
            [array addObject:[NSString stringWithCString:row[i]
                encoding:NSUTF8StringEncoding]];
        }
        return array;
    }
}

- (int) rowCount
{
    return mysql_num_rows(result);
}

- (int) fieldCount
{
    return mysql_num_fields(result);
}

- (void) dealloc
{
    mysql_free_result(result);
    [super dealloc];
}

@end

@interface MySQLConnection : NSObject
{
    MYSQL mysql;
    MYSQL *connection;
}

@end

@implementation MySQLConnection

- (id) init
{
    [super init];
    mysql_init(&mysql);
    return self;
}

- (BOOL) connect
{
    connection = mysql_real_connect(&mysql, "", "root", "", "", 0, 0, 0);
    if (!connection) {
        NSLog(@"FAIL");
        return NO;
    }
    return YES;
}

- (BOOL) selectDB:(NSString *) database
{
    return mysql_select_db(connection, [database cStringUsingEncoding:NSUTF8StringEncoding]) == 0;
}

- (MySQLResult *) tables
{
    MYSQL_RES *tables = mysql_list_tables(connection, NULL);
    return [MySQLResult resultWithResult:tables];
}

- (MySQLResult *) query:(NSString *) queryString
{
    int state = mysql_query(connection, [queryString cStringUsingEncoding:NSUTF8StringEncoding]);
    if (state != 0) {
        NSLog(@"query failed");
        return nil;
    }
    else {
        MYSQL_RES *result = mysql_store_result(connection);
        return [MySQLResult resultWithResult:result];
    }
}

@end

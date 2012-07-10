//
//  ToDoList.h
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoList : NSObject

@property(nonatomic,retain) NSString *listName;
@property(assign)int listId;
@property(assign)BOOL doneStatus;
@property(nonatomic,retain) NSDate * createdAtDate;
@property(nonatomic,retain) NSDate * updatedAtDate;
@property(nonatomic,retain)NSMutableArray * toDoItemsArray;
- (void)readFromDictionary:(NSDictionary *)paramDictionary;
@end

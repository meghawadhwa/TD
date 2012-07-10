//
//  ToDoItem.h
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject

@property(assign)int itemId;
@property(assign)int itemPriority;
@property(assign)BOOL doneStatus;
@property(nonatomic,retain) NSString *itemName;
@property(nonatomic,retain) NSDate * createdAtDate;
@property(nonatomic,retain) NSDate * updatedAtDate;
- (void)readFromDictionary:(NSDictionary *)paramDictionary;
@end

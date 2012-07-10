//
//  ToDoItem.m
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ToDoItem.h"

@implementation ToDoItem
@synthesize itemId,itemPriority,itemName,createdAtDate,updatedAtDate,doneStatus;
- (id)init
{
    self = [super init];
    if (self) {
        self.itemName = nil;
        self.itemId = 0;
        self.itemPriority = 0;
        self.createdAtDate = nil;
        self.updatedAtDate = nil;
    }
    
    return self;
}

- (void)readFromDictionary: (NSDictionary* ) paramDictionary
{
    if ([paramDictionary objectForKey:@"name"]) 
    {
        self.itemName = [paramDictionary objectForKey:@"name"];
    }
    
    if ([paramDictionary objectForKey:@"id"]) 
    {
        self.itemId = [[paramDictionary objectForKey:@"id"] intValue];
    }
    if ([paramDictionary objectForKey:@"priority"]) 
    {
        self.itemPriority = [[paramDictionary objectForKey:@"priority"] intValue];
    }
    if ([paramDictionary objectForKey:@"created_at"]) 
    {
        self.createdAtDate = [paramDictionary objectForKey:@"created_at"];
    }
    
    if ([paramDictionary objectForKey:@"updated_at"]) 
    {
        self.createdAtDate = [paramDictionary objectForKey:@"updated_at"];
    }
    
    if ([paramDictionary objectForKey:@"doneStatus"]) 
    {
        //self.doneStatus = [[paramDictionary objectForKey:@"doneStatus"] boolValue];
        self.doneStatus = FALSE;
    }
    
}

@end

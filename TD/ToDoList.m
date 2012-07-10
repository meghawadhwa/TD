//
//  ToDoList.m
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ToDoList.h"

@implementation ToDoList
@synthesize listName,createdAtDate,updatedAtDate,listId,toDoItemsArray,doneStatus;
- (id)init
{
    self = [super init];
    if (self) {
        self.listName = nil;
        self.listId = 0;
        self.createdAtDate = nil;
        self.updatedAtDate = nil;
    }
    return self;
}

- (void)readFromDictionary: (NSDictionary* )paramDictionary
{
    if ([paramDictionary objectForKey:@"listName"]) 
    {
        self.listName = [paramDictionary objectForKey:@"listName"];
    }
    
    if ([paramDictionary objectForKey:@"id"]) 
    {
        self.listId = [[paramDictionary objectForKey:@"id"] intValue];
    }
    
    if ([paramDictionary objectForKey:@"created_at"]) 
    {
        self.createdAtDate = [paramDictionary objectForKey:@"created_at"];
    }
    
    if ([paramDictionary objectForKey:@"updated_at"]) 
    {
        self.updatedAtDate = [paramDictionary objectForKey:@"updated_at"];
    }
    if ([paramDictionary objectForKey:@"items"])
    {
        
    }
    
    if ([paramDictionary objectForKey:@"doneStatus"]) 
    {
        //self.doneStatus = [[paramDictionary objectForKey:@"doneStatus"] boolValue];
        self.doneStatus = FALSE;
    }
    

}

@end

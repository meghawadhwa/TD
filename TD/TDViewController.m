//
//  TDViewController.m
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


#import "TDViewController.h"
#import "TDCategory.h"
#import "ToDoList.h"
#import "TDScrollView.h"
#import "TDListCustomRow.h"
#import "TDCommon.h"

@interface TDViewController(privateMethods)
- (void)createUI;
- (void)rearrangeRowsAfterRemovingObjectAtIndex:(NSMutableArray*)indexArray withDeletionFlag:(BOOL)flag bySwipe:(BOOL)Flag
;
- (void)rearrangeListObjectsAfterRemovingObjectAtIndex:(NSMutableArray*)indexArray withDeletionFlag:(BOOL)flag;
- (void)shiftRowsFromIndex:(int)index;
- (void)shiftRowsBackFromIndex:(int)index;
- (void)rearrangeColorsBasedOnPrioirity; 
@end

@implementation TDViewController
@synthesize backgroundScrollView;
@synthesize listArray;
@synthesize customViewsArray;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    self.listArray = [[NSMutableArray alloc] init];
    self.customViewsArray = [[NSMutableArray alloc] init];
    [self getDataFromServer];
    [self createUI];
    
}
#pragma mark -Delegates

- (BOOL)checkedRowsExist
{
    BOOL checkedRowFlag = FALSE;
    int totalObjects = [self.listArray count];
    for (int i =0; i<totalObjects; i++) 
    {
        ToDoList *aListItem = [self.listArray objectAtIndex:i];
        if (aListItem.doneStatus == TRUE) 
        {
            checkedRowFlag = TRUE;
            break;
        }
    }
    return checkedRowFlag;
}

- (void)TDCustomRowToBeDeleted:(BOOL)flag WithId:(int)senderId bySwipe:(BOOL)Flag

{
    int numberOfviews = [self.customViewsArray count];
    NSMutableArray *swipedIndexArray = [[NSMutableArray alloc] init];
    int index;
    for (index = 0; index< numberOfviews; index++) 
    {
        TDListCustomRow * currentView = [self.customViewsArray objectAtIndex:index];  
        if(senderId == currentView.tag){  [swipedIndexArray addObject:[NSNumber numberWithInt:index]]; }   
    }
    if ([swipedIndexArray count]>0) {
        [self rearrangeRowsAfterRemovingObjectAtIndex:swipedIndexArray withDeletionFlag:flag bySwipe:Flag];
        // TODO: remove from Server also.
    }
}

- (void)TDCustomViewPulledUp
{
    int numberOfRows = [listArray count];
    NSMutableArray *checkedIndexArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<numberOfRows; i++) 
    { 
        ToDoList *currentList = [self.listArray objectAtIndex:i];
        if (currentList.doneStatus == TRUE) 
        {
            [checkedIndexArray addObject:[NSNumber numberWithInt:i]];
            NSLog(@"index :%i",i);
        }
    }
    if ([checkedIndexArray count]>0) {
        [self rearrangeRowsAfterRemovingObjectAtIndex:checkedIndexArray withDeletionFlag:YES bySwipe:NO];
        // TODO: remove from Server also.
    }
}

- (void)TDCustomViewPulledDownWithNewRow:(TDListCustomRow *)newRow
{
    static int listId = 7;
    ToDoList *newList = [[ToDoList alloc] init];
    newList.listName = newRow.listTextField.text;
    if ([self.listArray count]!=0) {
        ToDoList *firstList = [self.listArray objectAtIndex:0];
        ToDoList *lastList = [self.listArray lastObject];
        newList.listId =(lastList.listId >firstList.listId ? lastList.listId :firstList.listId)+1;   
    }
    else
    {
        newList.listId = listId;
        listId ++;
    }
    // greater of first/last 
    newList.createdAtDate = [NSDate date];
    newList.updatedAtDate = [NSDate date];
    
    // TODO: WEB SERVICE TO ADD A LIST NEW :
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithObjects:newList, nil];
    [tempArray addObjectsFromArray:self.listArray];
    self.listArray = nil;
    self.listArray = tempArray;
    tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithObjects:newRow, nil];
    newRow.tag = newList.listId; 
    newRow.delegate = self;
    [tempArray addObjectsFromArray:self.customViewsArray];
    self.customViewsArray = nil;
    self.customViewsArray = tempArray;
    tempArray = nil;
    
    [self rearrangeColorsBasedOnPrioirity];
}

- (void)shiftRowsFromIndex:(int)index
{
    // rearrange after the new row is added
}

- (void)shiftRowsBackFromIndex:(int)index
{
    int lastObjectIndex = [self.customViewsArray count]-1;
    if (index < lastObjectIndex) // Not the last object
    {
        for (int i = lastObjectIndex; i > index; i--)  // transfer frames from last to current
        {
            TDListCustomRow *Row = [self.customViewsArray objectAtIndex:i];
            TDListCustomRow *previousRow = [self.customViewsArray objectAtIndex:i-1];
            [UIView animateWithDuration:0.8 animations:^{
                Row.frame = CGRectMake(0, previousRow.frame.origin.y, previousRow.frame.size.width, previousRow.frame.size.height);
            }]; 
        }
    }
}

#pragma mark - UI
// Prioirity is based on Index,Higher Index Lesser Priority,Lesser Color
- (void)rearrangeColorsBasedOnPrioirity 
{
    int totalRows = [self.customViewsArray count];
    for (int i =0; i<totalRows; i++) 
    {
        ToDoList *aList = [self.listArray objectAtIndex:i];
        if(aList.doneStatus == FALSE)
        {
        TDListCustomRow *aRow = [self.customViewsArray objectAtIndex:i];
        aRow.backgroundColor = [TDCommon getColorByPriority:i+1];
        }
    }
 
}
- (void)rearrangeRowsAfterRemovingObjectAtIndex:(NSMutableArray*)indexArray withDeletionFlag:(BOOL)flag bySwipe:(BOOL)Flag
{
    NSLog(@"array here %@",self.customViewsArray);
    int lastObjectIndex = [indexArray count] -1;
    for (int i =lastObjectIndex; i>=0; i--) 
    {
            int index = [[indexArray objectAtIndex:i] intValue];
            int lastObjectIndex = [self.customViewsArray count]-1;
        TDListCustomRow *RowToBeMoved = [self.customViewsArray objectAtIndex:index];
        
        if (flag == TRUE)     // deleted row to be removed from view
        {
            [UIView animateWithDuration:0.3 animations:^{
                if (Flag == YES) {
                RowToBeMoved.frame = CGRectMake(-ROW_WIDTH, RowToBeMoved.frame.origin.y, ROW_WIDTH, ROW_HEIGHT);
                }
                else{
                    RowToBeMoved.frame = CGRectMake(0, 480, ROW_WIDTH, ROW_HEIGHT);
            }
                 }];
            [RowToBeMoved performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
        }   
        
        
        if (index < lastObjectIndex) // Not the last object
        {
            for (int i = lastObjectIndex; i > index; i--)  // transfer frames from last to current
            {
                TDListCustomRow *Row = [self.customViewsArray objectAtIndex:i];
                TDListCustomRow *previousRow = [self.customViewsArray objectAtIndex:i-1];
                float delay;
                if (flag == TRUE) { delay = 0.3; } 
                else {delay =0.0;}
                [UIView animateWithDuration:0.8 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    Row.frame = CGRectMake(0, previousRow.frame.origin.y, previousRow.frame.size.width, previousRow.frame.size.height);} completion:nil]; 
            }
        }
        if (flag == TRUE) {    // deleted row to be removed from custom views array
        [self.customViewsArray removeObjectAtIndex:index];
        }
        else
        {
         [self.customViewsArray removeObjectAtIndex:index];
            [UIView animateWithDuration:0.5 animations:^{
            TDListCustomRow *lastRow = [self.customViewsArray lastObject];
            
            [self.backgroundScrollView bringSubviewToFront:RowToBeMoved];
            RowToBeMoved.frame =CGRectMake(0, lastRow.frame.origin.y + lastRow.frame.size.height, RowToBeMoved.frame.size.width, RowToBeMoved.frame.size.height);
            RowToBeMoved.backgroundColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1];
            }];
            RowToBeMoved.listTextField.textColor = [UIColor grayColor];
            [self.customViewsArray addObject:RowToBeMoved];
        }
    }
       [self rearrangeListObjectsAfterRemovingObjectAtIndex:indexArray withDeletionFlag:flag];
    [self rearrangeColorsBasedOnPrioirity];
     NSLog(@"array now %@",self.customViewsArray);
}


- (void)rearrangeListObjectsAfterRemovingObjectAtIndex:(NSMutableArray*)indexArray withDeletionFlag:(BOOL)flag
{
     NSLog(@"array before %@",self.listArray);
    int lastObjectIndex = [indexArray count] -1;
    for (int i =lastObjectIndex; i>=0; i--) 
    {
        int index = [[indexArray objectAtIndex:i] intValue];

        if (flag == TRUE) 
        {                                   // TODO: DELETE WEB SERVICE CALL
        [self.listArray removeObjectAtIndex:index];
        } 
        else
        {
            ToDoList *listToBeMoved = [self.listArray objectAtIndex:index];
            if (listToBeMoved.doneStatus == TRUE) {
               // listToBeMoved.doneStatus =FALSE;
            }
            else
            {
                listToBeMoved.doneStatus = TRUE;
            }
            [self.listArray removeObjectAtIndex:index];
            [self.listArray addObject:listToBeMoved];
                                            // TODO: update WEB SERVICE CALL
            // checked
            //TODO:delete after pull
        }
    }
    NSLog(@"array now %@",self.listArray);
}

- (void)createUI
{
  /************** background scrollview *************/
    self.backgroundScrollView = [[TDScrollView alloc] initWithFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
    self.backgroundScrollView.delegate = self;
    [self.view addSubview:self.backgroundScrollView];
    
    //static int y =1;
    for (int i =0; i<[self.listArray count]; i++)
    {
        ToDoList *toDoList = [self.listArray objectAtIndex:i];
         static int y =0;
        y= ROW_HEIGHT *i ;
        TDListCustomRow *row = [[TDListCustomRow alloc ] initWithFrame:CGRectMake(0, y,ROW_WIDTH , ROW_HEIGHT)];
        row.backgroundColor = [TDCommon getColorByPriority:i+1];
        row.listTextField.text = toDoList.listName;
        CGSize textSize = [[row.listTextField text] sizeWithFont:[row.listTextField font]];
        [row.listTextField setFrame:CGRectMake(row.listTextField.frame.origin.x, row.listTextField.frame.origin.y, textSize.width, textSize.height)];
        row.delegate = self;
        row.tag =toDoList.listId;
        NSLog(@" To Do List :%@,%i",toDoList.listName,y);
        [self.backgroundScrollView addSubview:row];
        [self.customViewsArray addObject:row];       
    }
     NSLog(@"array now %@",self.customViewsArray);
}


# pragma mark - FETCH  DATA FROM SERVER
- (void)getDataFromServer
{
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfJSONURLString:IP];
    
    if (dict) 
    {
            NSArray* responseArray = [dict objectForKey:@"result"]; //2
            NSLog(@"response array: %@",responseArray);

            //****************** populating model with data
            for (int i =0; i<[responseArray count]; i++)
            {
                ToDoList *toDoList = [[ToDoList alloc] init];
                NSDictionary *paramDict = [responseArray objectAtIndex:i];
                [toDoList readFromDictionary:paramDict]; 
                toDoList.doneStatus = FALSE;   //TOREMOVE
                [self.listArray addObject:toDoList];
                NSLog(@" To Do List :%@",self.listArray);
            }
            }
    
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"To Do App" message:@"Server unavailable" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [alert show];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

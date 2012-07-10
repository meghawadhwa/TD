//
//  TDViewController.h
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoList.h"
#import "TDDelegates.h"
#import "TDScrollView.h"
#import "TDConstants.h"

@class TDScrollView;
@class ToDoList;
@interface TDViewController : UIViewController<TDCustomRowSwipedDelegate,UITextFieldDelegate,TDCustomViewPulledDelegate>
@property(nonatomic,retain)TDScrollView *backgroundScrollView;
@property(nonatomic,retain) NSMutableArray *listArray;
@property(nonatomic,retain) NSMutableArray *customViewsArray;
- (void)getDataFromServer;
@end

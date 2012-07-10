//
//  TDScrollView.m
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TDScrollView.h"
#import "TDListCustomRow.h"
#import <QuartzCore/QuartzCore.h>
#import "TDListCustomRow.h"

#define HORIZ_SWIPE_DRAG_MAX  4
#define VERT_PULL_DRAG_MIN   55
#define VERT_PULL_UP_DRAG_MIN 115
#define DEGREE_TO_RADIAN 0.0174532925
#define EMPTY_BOX [UIImage imageNamed:@"empty_box.png"]
#define FULL_BOX [UIImage imageNamed:@"full_box.png"]

@interface TDScrollView(privateMethods)
- (void)customViewPullUpDetected:(NSSet *)touches withEvent:(UIEvent*)event;
- (void)customViewPullDownDetected:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)removeCheckedItems;
- (void)makeNewRow;
- (void)addNewRow;
- (void)accomodateNewRowAndMakeItFirstResponder;
- (void)removeNewRow;
- (void)createPullUpView;
- (void)createArrowImageView;
- (void)addOverlayView;
- (void)createOverlay;
@end

@implementation TDScrollView
static float rotationAngle; // global variable

@synthesize initialCentre;
@synthesize pullUpDetected,pullDownDetected;
@synthesize delegate;
@synthesize customNewRow;
@synthesize RowAdded;
@synthesize startedpullingDownFlag;
@synthesize overlayView;
@synthesize pullUpView,arrowImageView,boxImageView;
@synthesize checkedRowsExist;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        [self setUserInteractionEnabled:YES];
        }
    return self;
}

#pragma mark - touch delegates

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (self.overlayView) {
        return;
    }
    initialCentre = self.center;
    pullDownDetected = FALSE;
    pullUpDetected = FALSE;
    startedpullingDownFlag = FALSE;
     rotationAngle = 85.0; 
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (self.overlayView) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self];
    CGPoint prevTouchPosition = [touch previousLocationInView:self];
    
    float deltaY;
    CGRect myFrame = self.frame;
    deltaY = currentTouchPosition.y - prevTouchPosition.y;
    if (pullDownDetected || pullUpDetected || self.pullUpView.alpha <1) {
    deltaY = deltaY/DECELERATION_RATE;
    }
    myFrame.origin.y += deltaY;
    [self setFrame:myFrame];

    float scrolledDistanceY = self.center.y - initialCentre.y;
    //static float rotationAngle = 85.0f;
   
    CGFloat originY = self.frame.origin.y;
    if (originY >0) {
        startedpullingDownFlag = YES;
    }
    else
    {
        startedpullingDownFlag = NO;
    }
    
    if (startedpullingDownFlag == YES) 
    {
        if (prevTouchPosition.y < currentTouchPosition.y && pullUpDetected == NO) // PULL DOWN
            {
                 [self makeNewRow];
                if (rotationAngle >0) {
                    if (rotationAngle <3  || scrolledDistanceY >= VERT_PULL_DRAG_MIN) 
                    {
                        rotationAngle = 0;
                    }
                    else{
                    rotationAngle = (85.0 - scrolledDistanceY *1.52);
                    }
                }
                
            }
        else if(prevTouchPosition.y > currentTouchPosition.y && pullUpDetected == NO) // PULL UP
        {
             if(scrolledDistanceY <= VERT_PULL_DRAG_MIN) //ROTATE back ONLY after REACHING THE MINIMUM DRAG POINT 
             {rotationAngle = (85.0 - scrolledDistanceY *1.52);}
            
        }
    }
    else if(scrolledDistanceY <= VERT_PULL_UP_DRAG_MIN && startedpullingDownFlag == NO)
    {
        [self createPullUpView];
        if ([delegate checkedRowsExist]) // checks If already checked rows exists
        {
            [self createArrowImageView];
        }
        else
        {
            self.pullUpView.alpha = 0.2;
            return;
        }
        
    }
    
    if (self.arrowImageView) {
        CGRect arrowFrame = self.arrowImageView.frame;
        arrowFrame.origin.y -= deltaY/3.1;
        [self.arrowImageView setFrame:arrowFrame];
    }
    CALayer *layer = self.customNewRow.layer;
    layer.anchorPoint =CGPointMake(0.5, 1);
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 /- 120;     //m34(matrix value at 3 by 4) is the value of zDistance that affects the sharpness of the transform and lesser the value ,more sharper transformation across z axis.
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, rotationAngle * M_PI / 180.0f,1.0f, 0.0f,0.0f);
    layer.transform = rotationAndPerspectiveTransform;
     
    // To be a pull, direction of touch must be vertical and long enough.
    if (fabsf(initialCentre.y - self.center.y) >= VERT_PULL_DRAG_MIN && fabsf(initialCentre.x - self.center.x) <= HORIZ_SWIPE_DRAG_MAX)
    { 
        if (fabsf(initialCentre.y - self.center.y) >= VERT_PULL_UP_DRAG_MIN && prevTouchPosition.y > currentTouchPosition.y && pullDownDetected == FALSE)
        {
            NSLog(@" PULL UP :delta ,prev , current : %f %f,%f",initialCentre.y - self.center.y,initialCentre.y,self.center.y);
            self.boxImageView.image = FULL_BOX;
            self.arrowImageView.hidden = YES;
            pullUpDetected = TRUE;
            startedpullingDownFlag = FALSE;
            NSLog(@"pullUpDetected %i",pullUpDetected);
        }
        else if(fabsf(initialCentre.y - self.center.y) < VERT_PULL_UP_DRAG_MIN)
        {
            if (pullUpDetected == TRUE) {
                pullUpDetected = FALSE;
                self.arrowImageView.hidden = NO;
                self.boxImageView.image = EMPTY_BOX;
            }
        } 
        if (prevTouchPosition.y < currentTouchPosition.y && startedpullingDownFlag == TRUE )
        {
            NSLog(@" PULL DOWN :delta ,prev , current : %f %f,%f",initialCentre.y - self.center.y,initialCentre.y,self.center.y);
            pullDownDetected = TRUE;
            NSLog(@"pullDownDetected %i",pullDownDetected);
        }
        self.customNewRow.listTextField.text= RELEASE_AFTER_PULL_TEXT;
    } 
    else if(fabsf(initialCentre.y - self.center.y) < VERT_PULL_DRAG_MIN)
    {
        if (pullDownDetected == TRUE && (fabsf(initialCentre.y - self.center.y) < VERT_PULL_DRAG_MIN)) {
            pullDownDetected =FALSE;
        }
        self.customNewRow.listTextField.text= PULL_DOWN_TEXT;
    }
} 

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (self.overlayView) {
        return;
    }
    if (self.pullUpView) {
        [self.pullUpView removeFromSuperview];
        self.pullUpView = nil;
        [self.arrowImageView removeFromSuperview];
        self.arrowImageView = nil;
    }
    if (pullUpDetected == YES) {
        [self customViewPullUpDetected:touches withEvent:event];
        [self setFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
    }
    else if (pullDownDetected == YES){
        [self customViewPullDownDetected:touches withEvent:event];
         NSLog(@" angle : %f ",rotationAngle);
    }
    else{
    [self setFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
    }
}

# pragma mark - PULL UP METHODS

- (void)createArrowImageView
{
    if (self.arrowImageView != nil) {
        return;
    }
    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    self.arrowImageView.backgroundColor = [UIColor clearColor];
    [self.arrowImageView setFrame:CGRectMake(105, 480, 10, 13)];
    [self addSubview:self.arrowImageView];
}

- (void)createPullUpView
{
    if (self.pullUpView != nil) {
        return;
    }
    self.boxImageView = [[UIImageView alloc] initWithImage:EMPTY_BOX];
    self.boxImageView.backgroundColor = [UIColor clearColor];
    [self.boxImageView setFrame:CGRectMake(0, 13, 22, 10)];
                            
    UILabel *pullUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100,30)];
    pullUpLabel.text = @"Pull to Clear";
    pullUpLabel.textAlignment = UITextAlignmentCenter;
    pullUpLabel.textColor = [UIColor whiteColor];
    pullUpLabel.backgroundColor = [UIColor clearColor];
    pullUpLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.pullUpView = [[UIView alloc] initWithFrame:CGRectMake(100, 510, 130, 30)];
    self.pullUpView.backgroundColor = [UIColor clearColor];
    [self.pullUpView addSubview:pullUpLabel];
    [self.pullUpView addSubview:self.boxImageView];
    [self addSubview:self.pullUpView];
}

#pragma mark - PULL DOWN METHODS
- (void)makeNewRow
{
    if (self.customNewRow) {
        self.customNewRow.listTextField.text =PULL_DOWN_TEXT;
        return;
    }  
    TDListCustomRow * newRow;
    if (self.customNewRow == nil) {
        newRow = [[TDListCustomRow alloc]initWithFrame:CGRectMake(0,-ROW_HEIGHT + 27.5, ROW_WIDTH , ROW_HEIGHT)];
        self.customNewRow = newRow;
        self.customNewRow .listTextField.text =PULL_DOWN_TEXT;
        [self addSubview:self.customNewRow];
    }
}

- (void)accomodateNewRowAndMakeItFirstResponder
{   self.customNewRow.listTextField.text = NO_TEXT;
    [self.customNewRow.listTextField becomeFirstResponder];
    [self setFrame:CGRectMake(0,ROW_HEIGHT, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
}

- (void)createOverlay
{
    if (self.overlayView) {
        return;
    }
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ROW_WIDTH, 480)];
    self.overlayView.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayViewTapped)]; 
    [self.overlayView addGestureRecognizer:tapGestureRecognizer];
}

- (void)addOverlayView
{
    [self addSubview:self.overlayView];

}

- (void)overlayViewTapped
{
    if (self.overlayView == nil) {
        return;
    }
    [self.customNewRow.listTextField resignFirstResponder];
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
    if ([self.customNewRow.listTextField.text isEqualToString:NO_TEXT]) {
        [self removeNewRow];
    }
    else
    {
        for ( TDListCustomRow * row in [self subviews])
        {
            [row setFrame:CGRectMake(0, row.frame.origin.y +ROW_HEIGHT , ROW_WIDTH, ROW_HEIGHT)]; 
            NSLog(@" Y : %f angle : %f",row.frame.origin.y,rotationAngle);
        }
        [self setFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH , SCROLLVIEW_HEIGHT)];
             [self addNewRow];
    }
}

- (void)removeNewRow
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        [self.customNewRow setFrame:CGRectMake(-ROW_WIDTH, self.customNewRow.frame.origin.y, ROW_WIDTH, ROW_HEIGHT)];
    } completion:^(BOOL finished){
        [self.customNewRow removeFromSuperview];
        self.customNewRow = nil;  [self setFrame:CGRectMake(0, 0, 320, 480)];} ];
    }

- (void)addNewRow
{
    self.RowAdded = self.customNewRow;
    self.customNewRow = nil;
    if ([delegate respondsToSelector:@selector(TDCustomViewPulledDownWithNewRow:)]) {
    [delegate TDCustomViewPulledDownWithNewRow:self.RowAdded];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    pullUpDetected = NO;
    pullDownDetected = NO;
    [self setFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
}

#pragma mark -  PUll UP
- (void)customViewPullUpDetected:(NSSet *)touches withEvent:(UIEvent*)event
{
    [self performSelector:@selector(removeCheckedItems) withObject:nil afterDelay:0.4];
}

- (void)removeCheckedItems
{
    if ([delegate respondsToSelector:@selector(TDCustomViewPulledUp)])
    {
    [delegate TDCustomViewPulledUp];
    }
}
#pragma mark -  PUll Down

- (void)customViewPullDownDetected:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self createOverlay];
    [self accomodateNewRowAndMakeItFirstResponder];
    
    [self addOverlayView];
}


@end

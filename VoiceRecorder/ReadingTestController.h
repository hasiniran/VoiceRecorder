//
//  UIViewController+ReadingTestController.h
//  VoiceRecorder
//
//  Created by Randy on 9/13/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PageContentViewController.h"

@protocol ReadingTest3Delegate <NSObject>
@required
-(void)setLastTakenDate:(NSString *)date:(NSString *)test;
@end

@interface ReadingTestController:UIViewController <UIPageViewControllerDataSource>


- (IBAction)startWalkthrough:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *recorderStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;


@end

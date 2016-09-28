//
//  UIViewController+ReadingTest4Controller.h
//  VoiceRecorder
//
//  Created by Randy on 9/19/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryPageViewController.h"

@interface ReadingTest4Controller:UIViewController <UIPageViewControllerDataSource>


@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
@property (weak, nonatomic) id delegate;


@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *recorderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *pageText;
@property (weak, nonatomic) IBOutlet UIButton *nextPageButton;

@end

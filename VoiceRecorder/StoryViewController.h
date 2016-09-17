//
//  UIViewController+StoryViewController.h
//  VoiceRecorder
//
//  Created by Randy on 9/9/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface StoryViewController:UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
@property (weak, nonatomic) id delegate;

@end
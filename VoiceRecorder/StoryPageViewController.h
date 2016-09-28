//
//  UIViewController+StoryPageViewController.h
//  VoiceRecorder
//
//  Created by Randy on 9/20/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface  StoryPageViewController:UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *pageText;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@end

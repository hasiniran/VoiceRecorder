//
//  StoryViewController.h
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 9/9/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryPageViewController : UIViewController

@property (assign,nonatomic) NSInteger pageNumber;
@property (assign, nonatomic) IBOutlet UITextView *storyText;
@property (assign, nonatomic) IBOutlet UIImageView* storyImage;

@end

/* StoryViewController_h */

//
//  UIViewController_StoryViewController.h
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 9/9/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "StoryPageViewController.h"

@implementation StoryPageViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.storyText = [NSString stringWithFormat:@"Screen %ld", (long)self.pageNumber];
}

@end

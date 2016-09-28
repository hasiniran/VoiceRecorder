//
//  UIViewController+StoryPageViewController.m
//  VoiceRecorder
//
//  Created by Randy on 9/20/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "StoryPageViewController.h"

@implementation StoryPageViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.pageText.text = self.titleText;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

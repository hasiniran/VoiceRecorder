//
//  UIViewController+PageContentViewController.m
//  VoiceRecorder
//
//  Created by Randy on 9/11/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "PageContentViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PageContentViewController ()



@end

@implementation PageContentViewController

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
    
    
    if(self.imageFile != Nil){
        self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
        [self.imageButton setBackgroundImage:[UIImage imageNamed:self.imageFile] forState:UIControlStateNormal];
    }
    //self.titleLabel.text = self.titleText;
    self.pageText.text = self.titleText;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

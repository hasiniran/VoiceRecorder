//
//  UIViewController+PageContentViewController.h
//  VoiceRecorder
//
//  Created by Randy on 9/11/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property NSUInteger pageIndex;

@property NSString *titleText;
@property NSString *imageFile;
@end


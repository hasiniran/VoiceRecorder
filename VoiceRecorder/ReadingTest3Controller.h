//
//  UIViewController+ReadingTest3Controller.h
//  VoiceRecorder
//
//  Created by Randy on 9/12/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PageContentViewController.h"
#import "ReadingTestController.h"

@protocol ReadingTest3Delegate <NSObject>
@required
-(void)setLastTakenDate:(NSString *)date:(NSString *)test;
@end

@interface ReadingTest3Controller:UIViewController


@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak,nonatomic) NSArray *words1;

@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property (strong, nonatomic) NSArray *wordList;
@property (strong, nonatomic) NSArray *imagesList;

@property (weak, nonatomic) id delegate;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *recorderStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *WordLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wordImage;

@end



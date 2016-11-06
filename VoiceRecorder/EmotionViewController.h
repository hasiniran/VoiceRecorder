//
//  UIViewController+EmotionViewController.h
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 10/18/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "CustomIOSAlertView.h"

#import "ASValueTrackingSlider.h"

/**
 
 emotion 1: Negative
 emotion 2: Neutral
 emotion 3: Positive
 **/


@interface EmotionViewController:UIViewController <ASValueTrackingSliderDataSource>

@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *LabelSelectedEmotion;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmotion1;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmotion2;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmotion3;


-(void)resetEmotionButtons;
@end

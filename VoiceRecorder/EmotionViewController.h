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
#import "JMMarkSlider.h"
#import "ASValueTrackingSlider.h"

/**
 
 emotion 1: Angry
 emotion 2: Sad
 emotion 3: Anxious
 emotion 4: happy
 emotion 5: neutral
 **/


@interface EmotionViewController:UIViewController <ASValueTrackingSliderDataSource>

@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *LabelSelectedEmotion;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmotion1;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmotion2;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmotion3;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmotion4;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmotion5;

-(void)resetEmotionButtons;
@end

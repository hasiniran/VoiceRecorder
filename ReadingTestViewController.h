//
//  ReadingTestViewController.h
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 10/4/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ReadingTestViewController : UIViewController <AVAudioRecorderDelegate>
@property  NSString* userid;
@property (weak, nonatomic) IBOutlet UIButton *buttonStart;
@property (weak, nonatomic) IBOutlet UIButton *buttonStop;
@property (weak, nonatomic) IBOutlet UILabel *labelInstructions;
@property (weak, nonatomic) IBOutlet UITextView *textViewSentences;
@property (weak, nonatomic) IBOutlet UITextField *textboxName;
@property (weak, nonatomic) IBOutlet UIButton *ButtonPrevious;

@end

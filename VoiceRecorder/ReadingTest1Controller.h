//
//  ReadingTest1Controller.h
//  VoiceRecorder
//
//  Created by Randy on 11/12/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadingTest1Controller : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *buttonRecord;
@property (weak, nonatomic) IBOutlet UIButton *buttonStop;
@property (weak, nonatomic) IBOutlet UITextView *textviewSentences;

@end

//
//  ReadingTestHome.h
//  VoiceRecorder
//
//  Created by Randy on 11/11/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadingTest1Controller.h"
#import "ReadingTest2Controller.h"
#import "ReadingTest3Controller.h"

@interface ReadingTestHome : UIViewController<ReadingTest1Delegate>

@property (weak, nonatomic) IBOutlet UITextField *textboxName;
@property (weak, nonatomic) IBOutlet UITextField *textfieldName;
@property (weak, nonatomic) IBOutlet UIButton *buttonTest1;
@property (weak, nonatomic) IBOutlet UIButton *buttonTest2;
@property (weak, nonatomic) IBOutlet UILabel *labelTest1LastTaken;
@property (weak, nonatomic) IBOutlet UILabel *labelTest2LastTaken;
@property (weak, nonatomic) IBOutlet UIPickerView *uipickerNames;

@end

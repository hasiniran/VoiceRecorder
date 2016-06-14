//
//  ReadingTest2Controller.h
//  VoiceRecorder
//
//  Created by Randy on 11/15/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "ReadingTest1Controller.h"

@protocol ReadingTest2Delegate <NSObject>
@required
-(void)setLastTakenDate:(NSString *)date:(NSString *)test;
@end

@interface ReadingTest2Controller : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *buttonRecord;
@property (weak, nonatomic) IBOutlet UIButton *buttonStop;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) id delegate;

@end

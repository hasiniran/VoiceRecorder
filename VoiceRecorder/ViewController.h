//
//  ViewController.h
//  VoiceRecorder
//
//  Created by Spencer King on 9/30/14.
//  Copyright (c) 2014 University of Notre Dame. All rights reserved.
//

//import appropriate frameworks
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DevelopmentInterfaceViewController.h"
#import "DevelopmentSettings.h"

@interface ViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, DevelopmentInterfaceViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *storageText;

@property (weak, nonatomic) IBOutlet UITextView *currentText;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UILabel *audioLevelLabel;
@property (weak, nonatomic) IBOutlet UITextView *lastRecordingText;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRecordingsForUploadLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentageDiskSpaceRemainingLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfMinutesRecorded;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;

@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

- (IBAction)recordTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
- (IBAction)uploadFile:(id)sender;
- (void)setNumberOfFilesRemainingForUpload;
- (void)askForUserInfo;

@end


//
//  ReadingTest1Controller.m
//  VoiceRecorder
//
//  Created by Randy on 11/12/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "ReadingTest1Controller.h"
#import <AVFoundation/AVFoundation.h>
#import "ReadingTestHome.h"

@interface ReadingTest1Controller (){
    AVAudioRecorder *recorder;
    AVAudioSession *session;
    BOOL isRecording;
    NSUserDefaults *defaults;
     NSString        *dateString;
}

@end

@implementation ReadingTest1Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.buttonRecord setTitle:@"Record" forState:UIControlStateNormal ];
    [self.buttonStop setTitle:@"Cancel" forState:UIControlStateNormal];
    isRecording = false;
    
    self.textviewSentences.text = @"The fox jumped over the fence.\n\nJack and Jill went up the hill.";
    
    defaults = [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)recordTapped:(id)sender {
    
    
    //initialize the recorder
    
    if(!isRecording){

        //set the output file url
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"]; //format the date string
        dateString = [dateFormatter stringFromDate:[NSDate date]]; //get the date string
        
        NSString* fileName = [NSString stringWithFormat:@"ReadingTest %@_%@ test1 %@.m4a", [defaults objectForKey:@"username"], [defaults objectForKey:@"siblingname"],dateString];
        
        //set the audio file
        //this is for defining the URL of where the sound file will be saved on the device
        // Currently saving files to Documents directory. Might be better to save to tmp
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   fileName,
                                   
                                   nil];
        
        NSURL *filepath = [NSURL fileURLWithPathComponents:pathComponents];
        
        //initialize audio session
        session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        recorder = [[AVAudioRecorder alloc] initWithURL:filepath settings:recordSetting error:NULL];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        [recorder prepareToRecord];
        
    }
    
    //start recording
    
    
    if (!recorder.recording) {
        // Start recording
        [recorder record];
        [self.buttonRecord setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        // Pause recording
        [recorder pause];
        [self.buttonRecord setTitle:@"Record" forState:UIControlStateNormal];
    }

    [self.buttonStop setTitle:@"Stop" forState:UIControlStateNormal];
    isRecording = true;

}
- (IBAction)stopTapped:(id)sender {
    
    //stop recording
    
    if([self.buttonStop.titleLabel.text  isEqual: @"Stop"]){
    
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    isRecording = NO;
    [defaults setObject:dateString  forKey:@"Test1LastTaken"];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.buttonRecord setTitle:@"Record" forState:UIControlStateNormal];
    [self.buttonStop setEnabled:NO];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft; // or Right of course
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end

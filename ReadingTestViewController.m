//
//  ReadingTestViewController.m
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 10/4/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "ReadingTestViewController.h"

@interface ReadingTestViewController (){

    NSString* name;
    NSURL* filepath;
    BOOL isrecording;
    
    AVAudioRecorder *recorder;
    AVAudioSession *session;
    NSString *username;
}


@end

@implementation ReadingTestViewController
@synthesize userid;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.labelInstructions setHidden:YES];
    [self.textViewSentences setHidden:YES];
    [self.buttonStop setEnabled:NO];
    [self.buttonStart setEnabled:NO];
    isrecording = NO;
    self.textboxName.delegate = self; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)previousButtonTapped:(id)sender {
      [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)startTapped:(id)sender {
    [self.labelInstructions setHidden:NO];
    [self.textViewSentences setHidden:NO];

    //if recorder is not initialized
    
    if(!isrecording){
        //set the output file url
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString        *dateString;
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"]; //format the date string
        dateString = [dateFormatter stringFromDate:[NSDate date]]; //get the date string
        
        NSString* fileName = [NSString stringWithFormat:@"ReadingTest %@ %@.m4a", self->name, dateString];
        
        //set the audio file
        //this is for defining the URL of where the sound file will be saved on the device
        // Currently saving files to Documents directory. Might be better to save to tmp
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   fileName,
                                   
                                   nil];
        
        filepath = [NSURL fileURLWithPathComponents:pathComponents];
        
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
        [self.buttonStart setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        // Pause recording
        [recorder pause];
        [self.buttonStart setTitle:@"START" forState:UIControlStateNormal];
    }
    [self.buttonStop setEnabled:YES];
    isrecording = YES;
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.buttonStart setTitle:@"START" forState:UIControlStateNormal];
    [self.buttonStop setEnabled:NO];
}


- (IBAction)stopTapped:(id)sender {
    [self.labelInstructions setHidden:YES];
    [self.textViewSentences setHidden:YES];
    
    //stop recording
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    isrecording = NO;
    
}
- (IBAction)nameEntered:(id)sender {
    
    if(self.textboxName.text != NULL && ![self.textboxName.text  isEqual: @""]){
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userid = [defaults objectForKey:@"username"];
    name = [NSString stringWithFormat:@"%@_%@", self.userid, self.textboxName.text];
    NSLog(@"name : %@", name);
        [self.buttonStart setEnabled:YES];
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textboxName resignFirstResponder];
    return YES;
}

@end

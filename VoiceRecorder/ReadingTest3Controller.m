//
//  UIViewController+ReadingTest3Controller.m
//  VoiceRecorder
//
//  Created by Randy on 9/12/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "ReadingTest3Controller.h"
#import <AVFoundation/AVFoundation.h>

@interface ReadingTest3Controller(){
    AVAudioRecorder *recorder;
    AVAudioSession *session;
    BOOL isRecording;
    NSUserDefaults *defaults;
    NSString  *dateString;
    NSString* fileName;

    NSInteger currentWordIndex;
    NSInteger currentWordArray;
    
    NSMutableArray *timestamps;
    NSString *wordTestInfoFile;
}

@end

@implementation ReadingTest3Controller

- (void)viewDidLoad
{
    
    // create the data model
    
    self.wordList = @[@"House", @"Tree", @"Window", @"Telephone", @"Cup", @"Knife", @"Spoon", @"Girl", @"Ball",@"Wagon",@"Shovel",
                     @"Monkey", @"Zipper", @"Scissors", @"Duck",@"Quack", @"Yellow", @"Vacuum",@"Watch", @"Plane", @"Swimming",
                      @"Watches", @"Lamp",@"Car",@"Blue", @"Rabbit", @"Carrot", @"Orange",@"Fishing", @"Chair", @"Feather",
                      @"Pencil", @"Bathtub",@"Bath", @"Ring",@"Finger",@"Thumb", @"Jumping", @"Pajamas", @"Flowers", @"Brush",
                      @"Drum", @"Frog", @"Green",@"Clown", @"Balloons", @"Crying", @"Glasses", @"Slide", @"Stars",@"Five"];
    
    self.imagesList = @[@"house.png", @"tree.png", @"window.png",
                        @"telephone.png", @"cup.png",@"knife.png", @"spoon.png",
                        @"girl.png", @"ball.png",
                        @"wagon.png",@"shovel.png",
                        @"monkey.png", @"zipper.png", @"scissors.png", @"duck.png",@"quack.png", @"yellow.png",
                        @"vacuum.png",
                        @"watch.png", @"plane.png", @"swimming.png", @"watches.png", @"lamp.png",@"car.png",@"blue.png",
                        @"rabbit.png", @"carrot.png", @"orange.png",
                        @"fishing.png", @"chair.png", @"feather.png",
                        @"pencil.png", @"bathtub.png",@"bath.jpg",
                        @"ring.png",@"fingers.png",@"thumb.png",
                        @"jump.png", @"pajamas.png", @"flowers.png", @"brush.png", @"drum.png", @"frog.png", @"green.jpg",
                        @"clown.png", @"balloons.png",
                        @"crying.png", @"glasses.png", @"slide.png", @"stars.png",@"five.png"];
    [super viewDidLoad];
    
    [self constructWordsList];
    //init variables
    defaults = [NSUserDefaults standardUserDefaults];
    timestamps = [[NSMutableArray alloc] initWithCapacity:[self.pageTitles count]];
    
    
    //set begining word
    currentWordIndex = 0;
    [self.wordImage setImage:[UIImage imageNamed:self.pageImages[currentWordIndex]]];
    self.WordLabel.text = self.pageTitles[currentWordIndex];
}


- (BOOL)shouldAutorotate {
    return NO;
}
- (IBAction)helpButtonTapped:(id)sender {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Reading Test Instructions" message:@"1. Click Record to start recording. \n 2. Read the word displayed on the screen aloud. \n 3. Swipe to go the next word. \n 4. Click stop when the test is finished. " delegate:nil cancelButtonTitle:Nil otherButtonTitles:@"OK" , nil];
    alert.cancelButtonIndex=1;
    [alert setDelegate:self];
    [alert show];
    
}

- (IBAction)nextButtonTapped:(id)sender {
    
    NSUInteger pageCount = self.pageTitles.count;
    
    if(currentWordIndex<pageCount-1){
        currentWordIndex++;
        [self.wordImage setImage:[UIImage imageNamed:self.pageImages[currentWordIndex]]];
        self.WordLabel.text = self.pageTitles[currentWordIndex];
    }
    
    //last word displayed
    if (currentWordIndex == pageCount-1) {
        [self.nextButton setEnabled:NO];
        self.recorderStatusLabel.text =@"End of the test. Click stop to go to the main screen.";
        
        
    }
    
    //set begining time stamp of word
    [timestamps addObject:[NSNumber numberWithDouble:[recorder currentTime]]];
}



- (NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
}




//recorder functions

- (IBAction)recordTapped:(id)sender {
    
    [self record];
    
    //enable next button at the begining
    if(currentWordIndex == 0){
//       [self.nextButton setEnabled:YES];
    
       [timestamps addObject:[NSNumber numberWithDouble:[recorder currentTime]]];
    }
    
}


- (IBAction)stopTapped:(id)sender {
    //stop recording
    
    if([self.stopButton.titleLabel.text  isEqual: @"Stop"]){
        
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        isRecording = NO;
    }
    [defaults setObject:dateString  forKey:@"Test3LastTaken"];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    //write timestamps to csv
    [self writeToCSV:wordTestInfoFile :fileName :timestamps];
    
}

-(void)record{
    //initialize the recorder
    
    if(!isRecording){
        
        //set the output file url
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM.dd.YYYY hh:mm a"];//format the date string
        dateString = [dateFormatter stringFromDate:[NSDate date]]; //get the date string
        
        fileName = [NSString stringWithFormat:@"ReadingTest %@_%@ words %@.m4a", [defaults objectForKey:@"username"], [defaults objectForKey:@"siblingname"],dateString];
        
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
        NSLog(@"Starting the reading test :%@", fileName);
        
    }
    
    //start recording
    
    if (!recorder.isRecording) {
        // Start recording
        [recorder record];
        [self.recordButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.recorderStatusLabel.text =@"Recording...";
        
        
        if(currentWordIndex < [self.pageTitles count]-1){
            [self.nextButton setEnabled:YES];
        }
        
        
    } else {
        // Pause recording
        [recorder pause];
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        self.recorderStatusLabel.text =@"Click RECORD to continue recording.";
        [self.nextButton setEnabled:NO];

    }
    
    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    isRecording = true;
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [self.stopButton setEnabled:NO];
}


//write to timestamps to csv
-(void) writeToCSV: (NSString*)csvfileName : (NSString*)recorderfile : (NSMutableArray*)timestampDict{
    
    if(csvfileName == NULL || [csvfileName isEqualToString:@""]){
        csvfileName =[self loadInfoFile];
    }
    
    
    NSMutableString* csvString = [NSMutableString stringWithFormat:@"%@,",recorderfile];
    
    int totalWords = [timestamps count];
    
    for(int i=0; i<totalWords; i++){
        [csvString appendString:[NSString stringWithFormat:@"%@,%@,",[self.pageTitles objectAtIndex:i], [timestamps objectAtIndex:i]]];
    }
    
    NSLog(csvString);
    
    NSError *error;
    if(![csvString writeToFile:csvfileName atomically:YES encoding:NSUTF8StringEncoding error:&error]){
        NSLog(@"Error %@ while writing to file %@", [error localizedDescription], csvfileName );
    }
    
}

//load wordtest info file

-(NSString*)loadInfoFile{
    
    NSString *documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString *file = [NSString stringWithFormat:@"%@-wordsTest.csv",[defaults objectForKey:@"username"]];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:file];
    wordTestInfoFile = filePath;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    return wordTestInfoFile;
}


-(void)constructWordsList{
    
    
    int i = arc4random_uniform(5);

    switch (i) {
        case 0:
            self.pageTitles = [self.wordList subarrayWithRange:NSMakeRange(0, 11)];
            self.pageImages = [self.imagesList subarrayWithRange:NSMakeRange(0, 11)];
            break;
            
        case 1:
            self.pageTitles = [self.wordList subarrayWithRange:NSMakeRange(11, 10)];
            self.pageImages = [self.imagesList subarrayWithRange:NSMakeRange(11, 10)];
            break;
            
        case 2:
            self.pageTitles = [self.wordList subarrayWithRange:NSMakeRange(21, 10)];
            self.pageImages = [self.imagesList subarrayWithRange:NSMakeRange(21, 10)];
            break;
            
        case 3:
            self.pageTitles = [self.wordList subarrayWithRange:NSMakeRange(31, 10)];
            self.pageImages = [self.imagesList subarrayWithRange:NSMakeRange(31, 10)];
            break;
            
        case 4:
            self.pageTitles = [self.wordList subarrayWithRange:NSMakeRange(41, 10)];
            self.pageImages = [self.imagesList subarrayWithRange:NSMakeRange(41,10)];
            break;
        default:
            break;
    }
    
}


@synthesize delegate;
-(void)viewWillDisappear:(BOOL)animated
{
    [delegate setLastTakenDate:dateString:@"Test3"];
    
}
@end



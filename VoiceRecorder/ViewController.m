//
//  ViewController.m
//  VoiceRecorder
//
//  Created by Spencer King on 9/30/14.
//  Copyright (c) 2014 University of Notre Dame. All rights reserved.
//

//Assistance from:
//http://www.appcoda.com/ios-avfoundation-framework-tutorial/
//http://purplelilgirl.tumblr.com/post/3847126749/tutorial-the-step-two-to-making-a-talking-iphone

#import "ViewController.h"
#import <DropboxSDK/DropboxSDK.h>

//DBRestClient is used to access Dropbox after linking
@interface ViewController () <DBRestClientDelegate>{
    //declare instances for recording and playing
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    NSString *fileName;
    NSArray *pathComponents;
    NSURL *outputFileURL;
    
    NSURL *monitorTmpFile;
    NSURL *recordedTmpFile;
    AVAudioRecorder *audioMonitor;

    BOOL isRecording;
    BOOL isMonitoring;
    BOOL isPlaying;
    
    
    //variables for monitoring the audio input and recording
    double AUDIOMONITOR_THRESHOLD; //don't record if below this number
    double MAX_SILENCETIME; //max time allowed between words
    double MAX_MONITORTIME; //max time to try to record for
    double MIN_RECORDTIME; //minimum time to have in a recording
    double silenceTime; //current amount of silence time
}

@property (nonatomic, strong) DBRestClient *restClient;

- (void)setNumberOfFilesRemainingForUpload;

@end

@implementation ViewController
@synthesize storageText, currentText, lastRecordingText, recordButton, playButton, linkButton, uploadButton;

- (void) viewDidLoad {
    [super viewDidLoad];
    //[self initAudioMonitor];
    //[self freeDiskspace]; //displays the free space on the device
    
    //lastRecordingText.text = [standardUserDefaults stringForKey:@"lastRecordingDate"];
    
    //set monitoring and recording variables
    AUDIOMONITOR_THRESHOLD = 0.1;
    MAX_SILENCETIME = 2.0;
    MAX_MONITORTIME = 5.0;
    MIN_RECORDTIME = 1.0;
    silenceTime = 0;
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;

    // Disable stop and play buttons in the beginning
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:NO];
    
    // Set number of recordings remaining
    [self setNumberOfFilesRemainingForUpload];
}


//set up the filename
-(void)setOutputFileUrl {
    
    //name the file with the recording date, later add device ID
    fileName = [NSString stringWithFormat:@"Recording %@.m4a", [self getDate]];
    
    //set the audio file
    //this is for defining the URL of where the sound file will be saved on the device
    // Currently saving files to Documents directory. Might be better to save to tmp
    pathComponents = [NSArray arrayWithObjects:
                      [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                      fileName,
                      nil];
    
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
}

//uploads the file
-(IBAction)uploadFile {
    
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:fileName];
    
    // Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:fileName toPath:destDir withParentRev:nil fromPath:localPath];
}

//initialize the audio monitor
-(void) initAudioMonitor{
    
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* fullFilePath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent: @"monitor.caf"];
    monitorTmpFile = [NSURL fileURLWithPath:fullFilePath];
    
    audioMonitor = [[ AVAudioRecorder alloc] initWithURL: monitorTmpFile settings:recordSetting error:NULL];
    
    [audioMonitor setMeteringEnabled:YES];
    
    [audioMonitor setDelegate:self];
    
    [audioMonitor record];
}

//initialize the recorder
-(void) initRecorder{
    /*
     Initializes the recorder and recorder settings
    */
    
    
    //set up the audio session
    //this allows for both playing and recording
    //CHANGE THIS LATER ONCE IT WORKS, ONLY NEED RECORDING
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //define the recorder settings
    //the AVAudioRecorder uses dictionary-based settings
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    //initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord]; //this line initiates the recorder
    
}


//monitors audio input and determines if it should start recording
//(ccTime) dt comes from an external library but doesn't seem to do anything other than increment the silence time
//I increment the time by 1 second every time the method is called
//I messaged the tutorial author about this but they have not responded
-(void) monitorAudioController//: (ccTime) dt
{
    //making this a while loop is probably better but doesn't load the UI
    if(!isPlaying)
    {   [audioMonitor updateMeters];
        
        int x = 0;
        // a convenience, it’s converted to a 0-1 scale, where zero is complete quiet and one is full volume
        const double ALPHA = 0.05;
        double peakPowerForChannel = pow(10, (0.05 * [audioMonitor peakPowerForChannel:0]));
        double audioMonitorResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * audioMonitorResults;
        
        NSLog(@"audioMonitorResults: %f", audioMonitorResults);
        
        //double dt;
        double dt = 1;
        
        //double silenceTime = 0;
        
        //check if sound input is above the threshold
        if (audioMonitorResults > AUDIOMONITOR_THRESHOLD)
        {   NSLog(@"Sound detected");
            if(!isRecording)
            {
                //stop monitoring and start recording
                [audioMonitor stop];
                [self startRecording];
            }
        }
        //not above threshold, so don't record
        else{
            NSLog(@"Silence detected");
            if(isRecording){
                //if we're recording and above max silence time
                if(silenceTime > MAX_SILENCETIME){
                    //stop recording, playback the recording
                    NSLog(@"Next silence detected");
                    [audioMonitor stop];
                    //isRecording = NO;
                    isMonitoring = NO;
                    //[recorder stop];
                    [self stopRecording];
                    silenceTime = 0;
                    x = 1;
                    NSLog(@"MADE IT THROUGH");
                }
                else{
                //silent but hasn't been silent for too long so increment time
                silenceTime += dt;
                }
            }
        }
        
        if([audioMonitor currentTime] > MAX_MONITORTIME){
            [audioMonitor stop];
            [audioMonitor record];
        }
        else if(isMonitoring == NO){
            [audioMonitor record];
            NSLog(@"keep monitoring");
        }
        
        if (x==1){
            NSLog(@"let's do it again");
        }
    }
    
}

//start recording
-(void) startRecording{
    
    NSLog(@"startRecording");
    
    isRecording = YES;
    [self setLastRecordingText]; //set the last recording time
    [recorder record];
}

//stop the recording and play it
-(void) stopRecordingAndPlay{
    
    NSLog(@"stopRecording Record time: %f", [recorder currentTime]);
    
    if([recorder currentTime] > MIN_RECORDTIME)
    {   isRecording = NO;
        [recorder stop];
        
        isPlaying = YES;
        // insert code for playing the audio here
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        isPlaying = NO;
        //[self monitorAudioController];
    }
    else{
        [audioMonitor record];
    }
    //[audioMonitor record];
    //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(monitorAudioController) userInfo:nil repeats:YES];
    //NSLog(@"calling again");
}

//stops the recording
-(void) stopRecording{
    NSLog(@"stopRecording Record time: %f", [recorder currentTime]);
    
    if([recorder currentTime] > MIN_RECORDTIME)
    {   isRecording = NO;
        [recorder stop];
        
        isPlaying = YES;
        // insert code for playing the audio here
        //player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        //[player setDelegate:self];
        //[player play];
        //isPlaying = NO;
        //[self monitorAudioController];
    }
    else{
        [audioMonitor record];
    }
}

//stop playing
-(void) stopPlaying{
    isPlaying = NO;
    [audioMonitor record];
}

//displays the last time a recording was made
-(void) setLastRecordingText{
    
    NSString* last;
    NSString* date;
    last = @"Last recording date: ";
    date = [self getDate];
    NSString* str = [NSString stringWithFormat: @"%@ %@", last, date]; //concatenate the strings
    lastRecordingText.text = str;
    
    [self saveToUserDefaults:str];
}

//saves the last recording date to the user defaults
-(void)saveToUserDefaults:(NSString*)recordingDate
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:recordingDate forKey:@"lastRecordingDate"];
        [standardUserDefaults synchronize];
    }
}

//https://developer.apple.com/library/ios/documentation/cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
//this function returns the date, which will be used for the recording file name
- (NSString*)getDate {
    //initialize variables
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString        *dateString;
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"]; //format the date string
    
    dateString = [dateFormatter stringFromDate:[NSDate date]]; //get the date string
    
    return dateString; //return the string
}

//http://stackoverflow.com/questions/5712527/how-to-detect-total-available-free-disk-space-on-the-iphone-ipad-device
- (uint64_t)freeDiskspace
{
    //uint64 gives better precision
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        
        //get total space and free space
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        
        //print free space to console as a check
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        //print an error to the console if not able to get memory
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);
    }
    
    
    //Make and display a string of the current free space of the device
    //If we want to display minutes remaining, recordings take roughly 2MB/minute
    
    uint64_t actualFreeSpace = totalFreeSpace/(1024*1024); //convert to megabytes
    uint64_t freeSpaceMinutes = actualFreeSpace/2; //convert to minutes
    NSString* space = [@(actualFreeSpace) stringValue]; //put free space into a string
    NSString* spaceUnit = @" MB"; //string for the unit of free space
    NSString* str = [NSString stringWithFormat: @"%@ %@", space, spaceUnit]; //concatenate the strings
    
    NSString* desc = @"Free space remaining: ";
    NSString* str2 = [NSString stringWithFormat: @"%@ %@", desc, str]; //concatenate the strings

    
    storageText.text = str2; //display the amount of free space
    return totalFreeSpace;
}

//BUTTONS

//record button tapped
- (IBAction)recordTapped:(id)sender {
    // If audio player is playing, stop it
    if (player.playing)
    {
        [player stop];
    }

    if (!recorder.recording)
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];

        // Recorder needs to be initialized each time due to the file url
        // property being readonly. New file url must be set for each recording
        // Setup audio file
        [self setOutputFileUrl];

        // Setup Audio Session and Recorder
        [self initRecorder];

        // Start recording
        [recorder record];
        [self.recordButton setEnabled:NO];
    }

    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];
    
    
    // TODO: setup monitor method
    //tutorial said the monitor method needed to be called in an update function
    //this calls it every second
    //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(monitorAudioController) userInfo:nil repeats:YES];
}

//stops the recorder and deactivates the audio session
- (IBAction)stopTapped:(id)sender {
    [recorder stop];

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];

    // Update count of recordings
    [self setNumberOfFilesRemainingForUpload];


    //[audioMonitor stop];
    //isRecording = NO;
    //isMonitoring = NO;
    //[recorder stop];
    //isPlaying = YES;
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.recordButton setEnabled:YES];

    
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:YES];
}

//makes sure no recording or monitoring is happening and then plays
- (IBAction)playTapped:(id)sender {
    if (!recorder.recording)
    {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        player.delegate = self;
        [player play];
    }
    //[audioMonitor stop];
    //isRecording = NO;
    //isMonitoring = NO;
    //isPlaying = YES;
    //[recorder stop];
    //player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
    //[player setDelegate:self];
    //[player play];
    ////isPlaying = NO;

}

// Show alert after recording
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done" message: @"Finish playing the recording!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

//for linking to dropbox
// TODO: Just put this to upload button
- (IBAction)didPressLink:(id)sender
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"linking");
    }
    NSLog(@"already linked");
    [self uploadFile]; //upload the test file
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
    from:(NSString *)srcPath metadata:(DBMetadata *)metadata {

    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Success" message: @"Files uploaded successfully!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

- (void)setNumberOfFilesRemainingForUpload {
    /*
     * Calculaes number of files remaining for uplaod
    */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory error:nil];

    self.numberOfRecordingsForUploadTextField.text = [NSString stringWithFormat:@"Number of Recordings for Upload: %lu", (unsigned long)filePathsArray.count];
}

@end

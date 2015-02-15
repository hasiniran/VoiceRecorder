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
@interface ViewController () <DBRestClientDelegate, UIAlertViewDelegate>{
    //declare instances for recording and playing
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer *audioMonitorTimer;

    NSString *fullName;
    NSString *fileName;
    NSArray *pathComponents;
    NSURL *outputFileURL;
    NSTimer *recordingTimer;
    int numberOfRecordingsForUpload;
    
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
    double MAX_RECORDTIME; //max time to try to record for
    double MIN_RECORDTIME; //minimum time to have in a recording
    double silenceTime; //current amount of silence time
    double dt; // Timer (audioMonitor level) update frequencey
}

@property (nonatomic, strong) DBRestClient *restClient;

@end

@implementation ViewController
@synthesize storageText, currentText, lastRecordingText, recordButton, playButton, linkButton, uploadButton;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //set monitoring and recording variables
    AUDIOMONITOR_THRESHOLD = .1;
    MAX_SILENCETIME = 20.0; // seconds
    MAX_MONITORTIME = 200.0; // seconds
    MIN_RECORDTIME = 1.0; // seconds
    MAX_RECORDTIME = 20;  // minutes
    dt = .001;
    silenceTime = 0;

    // Set Bools
    isPlaying = NO;
    isMonitoring = NO;
    isRecording = NO;
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;

    // Disable stop and play buttons in the beginning
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:NO];
    
    // Set number of recordings remaining
    [self setNumberOfFilesRemainingForUpload];
    
    // Get user info
    if (!fullName)
    {
        [self askForUserInfo];
    }
    // Set disk space etc
    [self setFreeDiskspace];
    
}


//set up the filename
-(void)setOutputFileUrl {
    
    // If name not set, set name
    if (!fullName)
    {
        [self askForUserInfo];
    }

    //name the file with the recording date, later add device ID
    fileName = [NSString stringWithFormat:@"Recording of %@ %@.m4a", self->fullName, [self getDate]];
    
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
-(IBAction)uploadFiles {
    /*
     * Iterates through documents directory, searches for files beginning with
     * "Recording", and uploads files.
    */

    // Dropbox destination path
    NSString *destDir = @"/";

    // Get file manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Get directory path
    NSString *documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:documentsDir error:nil];
    
    // Iterate through contents, if starts with "Recording", upload
    NSString *filePath;
    for (filePath in dirContents)
    {
        if ([filePath containsString:@"Recording"])
        {
            NSLog(@"filePath: %@", filePath);
            
            NSString *localPath = [documentsDir stringByAppendingPathComponent:filePath];
            // Upload file to Dropbox
            [self.restClient uploadFile:filePath toPath:destDir withParentRev:nil fromPath:localPath];
        }
        
    }
    
}

//initialize the audio monitor
-(void) initAudioMonitorAndRecord{
    
    // Set session to play and record
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

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
    isMonitoring = YES;

    // Timer for update of audio level
    audioMonitorTimer = [NSTimer scheduledTimerWithTimeInterval:dt target:self selector:@selector(monitorAudioController) userInfo:nil repeats:YES];

    // Timer for update of time elapsed label
    recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];  //this is nstimer to initiate update method
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


-(void) monitorAudioController
{
    /*
     * Meant to be called on a timer, this gets the audio level from the
     * audioMonitor and converts it to a zero to 1 scale. If the audio level is
     * greater than the AUDIOMONITOR_THRESHOLD value, if the recorder is not
     * recording, it begins recording and isRecording is set to YES. If the
     * audio level is not above the AUDIOMONITOR_THRESHOLD value, the recorder
     * stops recording
    */

    static double audioMonitorResults = 0;
    // TODO Check if isPlaying is neccessary 
    if(!isPlaying)
    {   
        [audioMonitor updateMeters];
        
        // a convenience, it’s converted to a 0-1 scale, where zero is complete quiet and one is full volume
        const double ALPHA = 0.05;
        double peakPowerForChannel = pow(10, (0.05 * [audioMonitor peakPowerForChannel:0]));
        audioMonitorResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * audioMonitorResults;
        
        self.audioLevelLabel.text = [NSString stringWithFormat:@"Level: %f", audioMonitorResults];
        
        //####################### RECORDER AUDIO CHECKING #####################
        // set status label
        if (isRecording)
        {
            self.statusLabel.text = @"Recording.";
        }
        else
        {
            self.statusLabel.text = @"Not recording.";
        }
        //check if sound input is above the threshold
        if (audioMonitorResults > AUDIOMONITOR_THRESHOLD)
        {   
            self.statusLabel.text = [self.statusLabel.text stringByAppendingString:@" Sound detected."];
            if(!isRecording)
            {
                // start recording
                [self startNewRecording];
            }
        }
        //not above threshold, so don't record
        else{
            self.statusLabel.text = [self.statusLabel.text stringByAppendingString:@" Silence detected"];
            if(isRecording){
                // if we're recording and above max silence time
                if(silenceTime > MAX_SILENCETIME){
                    // stop recording
                    [self stopRecorder];
                    silenceTime = 0;
                }
                else{
                    //silent but hasn't been silent for too long so increment time
                    // For some reason, increment is off by 10
                    silenceTime += dt * 10;
                }
            }
        }
        //##################################################################### 


        //####################### MONITOR CHECKING ###########################
        // If monitor time greater than max allowed monitor time, stop monitor
        if([audioMonitor currentTime] > MAX_MONITORTIME){
            [self stopAudioMonitorAndAudioMonitorTimer];
        }
        //####################################################################
        
    }
    
}

-(void) startRecorder{
    /*
     * Sets recorder to start recording and sets isRecording to YES
    */

    NSLog(@"startRecorder");
    
    isRecording = YES;
    //[self setLastRecordingText]; //set the last recording time
    [recorder record];
}

//stop the recording and play it
-(void) stopRecorderAndPlay{
    
    NSLog(@"stopRecorder Record time: %f", [recorder currentTime]);
    
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

-(void) stopRecorder{
    /*
     * Stops the recorder and sets isRecording to NO. Displays about of time
     * recorded
    */

    // Log elapsed record time
    NSLog(@"stopRecorder Record time: %f", [recorder currentTime]);
    
    // TODO Check if MIN_RECORDTIME is necessary considering there is a
    // MAX_SILENCETIME
    isRecording = NO;
    [recorder stop];
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
- (void)setFreeDiskspace
{
    /*
     * Calculates free disk space and sets Label
    */

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
        //NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        //print an error to the console if not able to get memory
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    
    //Make and display a string of the current free space of the device
    //If we want to display minutes remaining, recordings take roughly 2MB/minute
    
    uint64_t actualFreeSpace = totalFreeSpace/(1024*1024); //convert to megabytes
    uint64_t freeSpaceMinutes = actualFreeSpace/2; //convert to minutes
    NSString* space = [@(actualFreeSpace) stringValue]; //put free space into a string
    NSString* spaceUnit = @" MB"; //string for the unit of free space

    // Remaining memory percentage, amount of minutes remaining,
    uint64_t percentageSpaceRemaining = (totalFreeSpace * 100/totalSpace);
    self.percentageDiskSpaceRemainingLabel.text = [NSString stringWithFormat:@"Percentage disk space remaining: %llu%%", percentageSpaceRemaining];

    self.numberOfMinutesRemainingLabel.text = [NSString stringWithFormat:@"Number of Minutes Remaining: %llu", freeSpaceMinutes];
}


//BUTTONS

//record button tapped
- (IBAction)recordTapped:(id)sender {
    /*
     * When record button is tapped, Audio monitor should be started
    */ 

    // If audio player is playing, stop it
    if (player.playing)
    {
        [player stop];
    }

    if (!isMonitoring)
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];

        [self initAudioMonitorAndRecord];

        // Start monitoring
        // Disable record button
        [self.recordButton setEnabled:NO];
    }

    // Enable stop button and disable play button
    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];

    
    
    // TODO: setup monitor method
    //tutorial said the monitor method needed to be called in an update function
    //this calls it every second
}

-(void)startNewRecording
{
    /*
     * Starts new recording by getting audio session, setting it active,
     * setting outputFileUrl, initializing the recorder, starting the recorder,
     * and starting a recordingTimer that updates the elapsed time label
     */

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
    isRecording = YES;


    // Set buttons
    [self.recordButton setEnabled:NO];
    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];
}

- (void)updateSlider {
    // Update the slider about the music time
    float minutesMonitoring = floor(audioMonitor.currentTime/60);
    float secondsMonitoring = audioMonitor.currentTime - (minutesMonitoring * 60);
    
    float minutesRecording = floor(recorder.currentTime/60);
    float secondsRecording = recorder.currentTime - (minutesRecording * 60);

    NSString *time = [[NSString alloc] 
        initWithFormat:@"Time Elapsed: %0.0f:%0.0f",
        minutesMonitoring, secondsMonitoring];
    self.timeElapsedLabel.text = time;

    // If recording has gone on for more than given time, start new recording
    // In minutes
    double allowedElapsedTime = MAX_RECORDTIME;
    if (minutesRecording >= allowedElapsedTime && isRecording)
    {
        // Stop old recording and start new one to decrease upload file sizes
        [self stopRecorder];
        [self startNewRecording];
        [self setNumberOfFilesRemainingForUpload];
    }
}

//stops the recorder and deactivates the audio session
- (IBAction)stopTapped:(id)sender {

    [self stopRecorder];
    [self stopAudioMonitorAndAudioMonitorTimer];
    [recordingTimer invalidate];
    
    // Update count of recordings
    [self setNumberOfFilesRemainingForUpload];

    // Update display of the free space on the device
    [self setFreeDiskspace];

    // Reenable buttons
    [self.playButton setEnabled:YES];
    [self.stopButton setEnabled:NO];
    [self.recordButton setEnabled:YES];
}

- (void)stopAudioMonitorAndAudioMonitorTimer
{
    /*
     * Stops audioMonitor and audioMonitorController selector (on a timer)
    */

    [audioMonitor stop];
    [audioMonitorTimer invalidate];
    isMonitoring = NO;
    NSLog(@"Audio Monitor stopped");
    
    // Give up audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}

//makes sure no recording or monitoring is happening and then plays
- (IBAction)playTapped:(id)sender {
    /*
     * Plays back most recent recording
    */

    if (!recorder.recording)
    {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        player.delegate = self;
        [player play];
    };
}

// Show alert after recording
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done" message: @"Finish playing the recording!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

//for linking to dropbox
// TODO: Just put this to upload button
- (IBAction)uploadFile:(id)sender
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"linking");
    }
    NSLog(@"already linked");
    [self uploadFiles]; //upload the test file
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
    from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"File uploaded successfully to path: %@ from path: %@", metadata.path, srcPath);
    
    // Delete file after upload
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:srcPath error:&error];
    // Display success message if all recordings successfully uploaded
    if (success && numberOfRecordingsForUpload == 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Success" message: @"All Files uploaded successfully!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
    // Update count of recordings
    [self setNumberOfFilesRemainingForUpload];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

- (void)setNumberOfFilesRemainingForUpload {
    /*
     * Calculates and sets Label of number of files remaining for uplaod
    */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory error:nil];
    NSString *filePath;
    int numOfRecordings = 0;
    for (filePath in filePathsArray)
    {
        if ([filePath containsString:@"Recording"])
        {
            numOfRecordings++;
        }
    }

    self->numberOfRecordingsForUpload = numOfRecordings;
    self.numberOfRecordingsForUploadLabel.text = [NSString stringWithFormat:@"Number of Recordings for Upload: %i", numOfRecordings];
}

- (void)askForUserInfo
{
    /*
     * Opens alert box asking user for information
     * if first name @"admin" and last @"", development button will be shown
    */
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Full name" message:@"Please enter your full name" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert setDelegate:self];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self->fullName = [alertView textFieldAtIndex:0].text;
}

@end

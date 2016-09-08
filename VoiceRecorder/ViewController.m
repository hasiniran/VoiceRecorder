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
#import "ReadingTestViewController.h"

//DBRestClient is used to access Dropbox after linking
@interface ViewController () <DBRestClientDelegate, UIAlertViewDelegate>{
    //declare instances for recording and playing
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer *audioMonitorTimer;
    
    NSString *fullName;
    NSString *fileName;  // recording file name
    NSString *currentMode; // current recording mode
    NSString *previousMode; // previous recording mode
    NSString *measuresFilePath; // path to battery status file
    NSString *recordingInfoFile; // path to file storing information about recordings
    NSString *logFilePath;
    NSString *comment; // hold the comment text field value untill saved to file
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
    double totalRecordTime; //total records in terms of time
    
    NSArray *tableLables; // array to contain application information
    NSArray *tableData;
    NSArray *_labelPickerData;
    
    NSInteger weekNumber; // current week number to track number of minutes recorded
    double cribTime; // minutes recorded in crib mode within current week
    double supTime; // minutes recorded in supervised mode within current week
    double unsupTime; // minutes recorded in unsupervised mode within current week
    double siblingTime; // minutes recorded in 'Record Sibling' mode within the current week
    
    NSInteger userGroup; // used to customize the UI according to the test group user belongs to
    NSArray *diagnosedUsers; //list of diagnosed children names in the system
    NSArray *undiagnosedUsers; // list of undiagnosed children in the system
    
    id selectedSender; // to store the id of mode button
    NSString* childNames; // to log the selected child names
    
    NSInteger MAX_UPLOAD_FAILS_PER_FILE;
    NSInteger uploadAttemptsForFile;
    NSInteger totalFailedAttempts;
    NSInteger ALLOWED_UPLOAD_FAILS;
    NSInteger MAX_FILE_SIZE; // if file size exceeds this limit, use chunked file upload
    
    NSMutableArray *filesToUpload; // path of files remaining in the device to upload
    NSInteger nextFile; //index of the next file
    AVAudioPlayer *backgroundPlayer;
    
}

@property (nonatomic, strong) DBRestClient *restClient;

@end

@implementation ViewController
@synthesize storageText, currentText, lastRecordingText, recordButton, playButton, uploadButton;
@synthesize uploadProgressValue;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //set the test group.
    // userGroup = 1 for the infant study. userGroup = 2 for the emotion recognition study.
    userGroup = [[NSUserDefaults standardUserDefaults] integerForKey:@"usergroup"];
    
    
    //set monitoring and recording variables
    AUDIOMONITOR_THRESHOLD = .001;
    MAX_SILENCETIME = 300.0; // seconds (5 min)
    MAX_MONITORTIME = 36000.0; // seconds (10 hours)
  //  MAX_MONITORTIME = 60.0; // seconds (1 min)
    MIN_RECORDTIME = 60.0; // seconds ( 1 min)
    MAX_RECORDTIME = 600;  // seconds ( 10 min)
    dt = 1;
    silenceTime = 0;
    
    MAX_UPLOAD_FAILS_PER_FILE = 10;
    uploadAttemptsForFile=0;
    totalFailedAttempts=0;
    ALLOWED_UPLOAD_FAILS = 100;
    MAX_FILE_SIZE = 2000000; // 2 MB
    
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
    [self getUsername];
    if (!fullName)
    {
        [self askForUserInfo];
    }else{
        
        [self initLogFile:fullName];
        [self initInfoFile];
    }
    
    self.labelUsername.text = [NSString stringWithFormat:@"User: %@", fullName];
    
    // Set disk space etc
    [self setFreeDiskspace];
    
    //set user specific settings
    [self setUserSpecificSettings];
    
    //setup mode buttons
    [self initRecordingModeButtons];
    
    // uncomment if you want to record battery status
   // [self recordBatteryStatus];
    
    //set week number for the first time
    if(weekNumber == 0 || [self getWeekOfYear] == 0){
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
        weekNumber = [components weekOfYear];
        [self saveWeekOfYear:weekNumber];
    }
    
    [self.textfieldComment setDelegate:self];
    
    
    //load recording time for each mode
    [self loadRecordedTime];
    
    [self getFirstDayofWeek];
    
   
    
}



//set up the filename
-(void)setOutputFileUrl {
    
    // If name not set, set name
    if (!fullName)
    {
        [self askForUserInfo];
    }
    
    //name the file with the recording date, later add device ID
    fileName = [NSString stringWithFormat:@"Recording of %@-%@ %@ %@.m4a", self->fullName,self->childNames, self->currentMode, [self getDate]];
    
    //set the audio file
    //this is for defining the URL of where the sound file will be saved on the device
    // Currently saving files to Documents directory. Might be better to save to tmp
    pathComponents = [NSArray arrayWithObjects:
                      [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                      fileName,
                      
                      nil];
    
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
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
         //           NSLog(@"%f", audioMonitorResults);
        if (audioMonitorResults > AUDIOMONITOR_THRESHOLD)
        {
            self.statusLabel.text = [self.statusLabel.text stringByAppendingString:@" Sound detected."];

            if(!isRecording)
            {
                // start recording
                NSLog(@"Starting to record.");
                [self startRecording];
            }
            silenceTime = 0; // reset silence counter
        }
        //not above threshold, so don't record
        else{
            self.statusLabel.text = [self.statusLabel.text stringByAppendingString:@" Silence detected"];
            if(isRecording){
                // if we're recording and above max silence time
                if(silenceTime > MAX_SILENCETIME){
                    // stop recording
                    NSLog(@"Silence for %f time. Stopping the recorder.", (silenceTime/60));
                    [self stopRecorder];
                    silenceTime = 0;
                }
                else{
                    //silent but hasn't been silent for too long so increment time
                    silenceTime += dt;
                }
            }
        }
        //#####################################################################
        
        
        //####################### MONITOR CHECKING ###########################
        // If monitor time greater than max allowed monitor time, stop monitor
        if([audioMonitor currentTime] > MAX_MONITORTIME){
            NSLog(@"Monitored for %f time. Stopping the monitor.", [audioMonitor currentTime]/60.0);
            [self stopRecorder];
            [self stopAudioMonitorAndAudioMonitorTimer];
        }
        //####################################################################
        
    }
    
}

//-(void) startRecorder{
//    /*
//     * Sets recorder to start recording and sets isRecording to YES
//     */
//    
//    NSLog(@"startRecorder");
//    
//    isRecording = YES;
//    //[self setLastRecordingText]; //set the last recording time
//    [recorder record];
//}

//stop the recording and play it
-(void) stopRecorderAndPlay{
    
    NSLog(@"stoping the recorder. Recorded time: %f", [recorder currentTime]);
    
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
    
}

-(void) stopRecorder{
    /*
     * Stops the recorder and sets isRecording to NO. Displays about of time
     * recorded
     */
    
    // Log elapsed record time
    
    if(isRecording){
        double timeRecorded = [recorder currentTime];
        NSLog(@"Stoping the recorder. Recorded time: %f", timeRecorded);
        totalRecordTime += timeRecorded;
        
        unsigned int totalTimeInSec = (unsigned int)round(totalRecordTime);
        
        self.numberOfMinutesRecorded.text =[[NSString alloc] initWithFormat:@"%02u:%02u:%02u", totalTimeInSec/3600, (totalTimeInSec/60)%60, totalTimeInSec%60];
        
        
        
        [self updateRecordingTime:previousMode :timeRecorded];
        
        // TODO Check if MIN_RECORDTIME is necessary considering there is a
        // MAX_SILENCETIME
        isRecording = NO;
        [recorder stop];
        
        //update metadata file
        [self updateMetadataFile];
        previousMode = currentMode;
    }
}

//stop playing
-(void) stopPlaying{
    isPlaying = NO;
    [audioMonitor record];
}

//is called when switching between methods
-(void) stopAndRecord{
    [self stopRecorder];
    [self stopAudioMonitorAndAudioMonitorTimer];
    [recordingTimer invalidate];
    
    // Update count of recordings
    [self setNumberOfFilesRemainingForUpload];
    
    // Update display of the free space on the device
    [self setFreeDiskspace];
    
    
    //hide time
    [self.timeElapsedLabel setHidden:YES];
    
    [self startRecording];
}

//displays the last time a recording was made
//-(void) setLastRecordingText{
//    
//    NSString* last;
//    NSString* date;
//    last = @"Last recording date: ";
//    date = [self getDate];
//    NSString* str = [NSString stringWithFormat: @"%@ %@", last, date]; //concatenate the strings
//    lastRecordingText.text = str;
//    
//    [self saveToUserDefaults:str];
//}

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
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH-mm-ss"]; //format the date string. Keep the '-'s in time, '.' and ':' gives issues when uploading to dropbox
    
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
    
    // uint64_t actualFreeSpace = totalFreeSpace/(1024*1024); //convert to megabytes
    //    uint64_t freeSpaceMinutes = actualFreeSpace/2; //convert to minutes
    
    
    // Remaining memory percentage, amount of minutes remaining,
    uint64_t percentageSpaceRemaining = (totalFreeSpace * 100/totalSpace);
    self.percentageDiskSpaceRemainingLabel.text = [NSString stringWithFormat:@"%llu%%", percentageSpaceRemaining];
    
    
    unsigned int totalTimeInSec = (unsigned int)round(totalRecordTime);
    self.numberOfMinutesRecorded.text =[[NSString alloc] initWithFormat:@"%02u:%02u:%02u", totalTimeInSec/3600, (totalTimeInSec/60)%60, totalTimeInSec%60];
}


//BUTTONS
- (IBAction)trackProgressTapped:(id)sender {
    [self showProgress];
}

//record button tapped
- (IBAction)recordTapped:(id)sender {
    /*
     * When record button is tapped, Audio monitor should be started
     */
    [self startRecording];
    
}

//comment added
- (IBAction)commentEndEditing:(id)sender {
    
    comment = self.textfieldComment.text;
    
}

-(void)startRecording{
    
    if (!isMonitoring)
    {
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setActive:YES error:nil];
        
        [self initAudioMonitorAndRecord];
        
        // Start monitoring
        // Disable record button
        [self.recordButton setEnabled:NO];
    }
    
    // Recorder needs to be initialized each time due to the file url
    // property being readonly. New file url must be set for each recording
    // Setup audio file
    [self setOutputFileUrl];
    
    // Setup Audio Session and Recorder
    [self initRecorder];
    
    NSLog(@"Starting the recorder. File name: %@",outputFileURL);
    // Start recording
    [recorder record];
    isRecording = YES;
    
    // Enable stop button and disable play button
    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];
    
    
    //show time
    self.timeElapsedLabel.text = @"00:00:00";
    [self.timeElapsedLabel setHidden:NO];
    
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
    NSLog(@"Starting the recorder. File name: %@",outputFileURL);
    [recorder record];
    isRecording = YES;
    
    
    // Set buttons
    [self.recordButton setEnabled:NO];
    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];
    [self.textfieldComment setEnabled:YES];
    
}

- (void)updateSlider {
    
    unsigned int elasedTimeinSec = (unsigned int)round(audioMonitor.currentTime); // time monitored
    unsigned int elasedRecordedTime = (unsigned int)round(recorder.currentTime);  //time recorded
    NSString *string = [NSString stringWithFormat:@"%02u:%02u:%02u",
                        elasedTimeinSec / 3600, (elasedTimeinSec / 60) % 60, elasedTimeinSec % 60];
    
    
    self.timeElapsedLabel.text = string;
    
    // If recording has gone on for more than given time, start new recording
    // In seconds
    double allowedElapsedTime = MAX_RECORDTIME;
    if (elasedRecordedTime >= allowedElapsedTime && isRecording)
    {
        // Stop old recording and start new one to decrease upload file sizes
        NSLog(@"Maximum recorder time exceeded. Starting a new recording.");
        [self stopRecorder];
        [self startNewRecording];
        [self setNumberOfFilesRemainingForUpload];
    }
}

//stops the recorder and deactivates the audio session
- (IBAction)stopTapped:(id)sender {
    
    previousMode = currentMode;
    [self stopRecorder];
    [self stopAudioMonitorAndAudioMonitorTimer];
    [recordingTimer invalidate];
    [self updateDisplay];
    
}

-(void)updateDisplay{
    // Update count of recordings
    [self setNumberOfFilesRemainingForUpload];
    
    // Update display of the free space on the device
    [self setFreeDiskspace];
    
    //reset buttons
    [self resetModeButtons];
    currentMode = @"";
    
    //hide time
    [self.timeElapsedLabel setHidden:YES];
    
    
}

- (void)stopAudioMonitorAndAudioMonitorTimer
{
    /*
     * Stops audioMonitor and audioMonitorController selector (on a timer)
     */
    
    NSLog(@"Stopping Audio Monitor. Time monitored: %f ", audioMonitor.currentTime);
    
    [audioMonitor stop];
    [audioMonitorTimer invalidate];
    isMonitoring = NO;

    
    // Give up audio session
    
    //if any I/O is running first stop them
    if([recorder isRecording]){
        [recorder stop];
    }
    
    if([backgroundPlayer isPlaying]){
        [backgroundPlayer stop];
    }
    
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
- (IBAction)uploadFile:(id)sender
{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Started.." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [alert show];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];


    indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
    [indicator startAnimating];
    [alert addSubview:indicator];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [self startUploadProgress:[NSNumber numberWithInt:numberOfRecordingsForUpload]];

    [self uploadFiles]; //upload the audio files

}


//uploads the file
-(IBAction)uploadFiles {
    /*
     * Iterates through documents directory, searches for files beginning with
     * "Recording", and uploads files.
     */
    
    if ([[DBSession sharedSession] isLinked]) {
        // Dropbox destination path
        NSString *destDir = @"/";
        
        // Get file manager
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // Get directory path
        NSString *documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:documentsDir error:nil];
        
        // Iterate through contents, if starts with "Recording", upload
        NSString *filePath;
        
        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.restClient.delegate = self;
        
        // upload metadata file
        
        if(recordingInfoFile != NULL){
            [self.restClient uploadFile:[NSString stringWithFormat:@"comments/%@-info.csv",fullName] toPath:destDir withParentRev:nil  fromPath:recordingInfoFile];
        }
        
        //upload log file
        [self uploadLogFile];
        
        filesToUpload = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (filePath in dirContents)
        {

            if ([filePath containsString:@"Recording"] || [filePath containsString:@"ReadingTest"])
            {
                
            
                [filesToUpload addObject:filePath];

            }

        }
        
        //call file upload for the first file
        if([filesToUpload count] > 0){
            nextFile = 0;
            [self uploadRecordingFile:nextFile];
        }else{
            //no files to upload
            [self resetUploadProgressView];
        }

        
    }else{
        NSLog(@"Linking to dropbox.");
        [[DBSession sharedSession] linkFromController:self];
        [self resetUploadProgressView];
    }


}



-(void)uploadLogFile{

    NSString *logfileName =[NSString stringWithFormat:@"%@.log",fullName];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if(logfileName != NULL  && [filemanager fileExistsAtPath:logFilePath] ){
        if([[filemanager attributesOfItemAtPath:logFilePath error:NULL] fileSize] >= MAX_FILE_SIZE){
            [self.restClient uploadFileChunk:nil offset:0 fromPath:logFilePath];
        }else{
            [self.restClient uploadFile:logfileName toPath:@"/logs/" withParentRev:nil fromPath:logFilePath];
        }
    }
}


-(void)uploadRecordingFile:(NSInteger)index{
    
    NSString* path = [filesToUpload objectAtIndex:index];
    
    if(path !=NULL && ![path  isEqual: @""]){
        NSString *documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *localPath = [documentsDir stringByAppendingPathComponent:path];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:localPath error: NULL];
        //if file size is > 5 MB upload in chunks
        if([attrs fileSize] >  MAX_FILE_SIZE){
            [self.restClient uploadFileChunk:nil offset:0 fromPath:localPath];
        }else{
            [self.restClient uploadFile:path toPath:@"/" withParentRev:nil fromPath:localPath];
        }
    }else if ([filesToUpload count] > nextFile){
        [self uploadNextFile];
    }
    else{
        [self resetUploadProgressView];
    }
}

-(void)removeFileFromArray{
    [filesToUpload removeObjectAtIndex:nextFile];
    nextFile++;
}


- (void)uploadNextFile
{
    // if more files are there to upload
    nextFile++;
    if(numberOfRecordingsForUpload!=0 && [filesToUpload count] > nextFile ){
        [self uploadRecordingFile:nextFile];
    }else{
        [self resetUploadProgressView];
    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"File uploaded successfully to path: %@ from path: %@", metadata.path, srcPath);
    
    // Delete file after upload
    //dont delete the <name>-info.csv file and <name>.log file
    NSError *error;
    
    if(srcPath != recordingInfoFile && srcPath !=logFilePath){
        BOOL success = [fileManager removeItemAtPath:srcPath error:&error];
        // Display success message if all recordings successfully uploaded
        // Update count of recordings
        [self setNumberOfFilesRemainingForUpload];
        
        // numberOfRecordingsForUpload=1 because we are checking before deleting the file
        if (success && numberOfRecordingsForUpload == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Success" message: @"All Files uploaded successfully!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        else if(!success){
            NSString *errorText = [@"Could not delete file -:" stringByAppendingString:[error localizedDescription]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Failed" message:errorText delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        //upload next file
        [self uploadNextFile];
    }
    
}

- (void)fileUploadFailed:(NSString *)errorText error:(NSError *)error {
    //if authentication error
    NSString *errorDisplaytext;
    if(error.code == 401){
        errorDisplaytext = @"cannot login to the dropbox. Please sign in again";
        [self.restClient cancelAllRequests];
        [self resetUploadProgressView];
        [self didPressLink];
    }else if(error.code == -1009){
        //not connected to wifi
        errorDisplaytext = @"Unable to upload files. Device is not connected to the internet. Please check your internet connection and try again.";
    }else if (error.code == -1005){
        errorDisplaytext = @"Couldnt upload all the files. Connection to the network was lost. Please check your internet connection and try again later.";
        
    }else if(error.code == -1001){
        //timeout
        errorDisplaytext = @"The file upload cannot be completed due to an operation timeout. Please check your internet connection try again later.";
    }
    else{
        //other errors
        errorDisplaytext = errorText;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Failed" message:errorDisplaytext delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self.restClient  cancelAllRequests];
    uploadAttemptsForFile = 0;
    totalFailedAttempts = 0;
    nextFile = 0;
    [filesToUpload removeAllObjects];
    [self resetUploadProgressView];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    totalFailedAttempts ++;
    // if the error is a timeout, retry
    if( (error.code == -1001 || error.code == -1005) && totalFailedAttempts < ALLOWED_UPLOAD_FAILS){

        if (uploadAttemptsForFile < MAX_UPLOAD_FAILS_PER_FILE)
        {
            uploadAttemptsForFile++;
            [self.restClient uploadFile:[[NSFileManager defaultManager] displayNameAtPath:[error.userInfo valueForKey:@"sourcePath"]] toPath:[error.userInfo valueForKey:@"destinationPath"] withParentRev:nil fromPath:[error.userInfo valueForKey:@"sourcePath"]];
        }else{
            uploadAttemptsForFile = 0;
            [self.restClient cancelFileUpload:[error.userInfo valueForKey:@"sourcePath"]];
            NSLog(@"Cancel file upload for %@ due to upload failures of several attempts.",[error.userInfo valueForKey:@"sourcePath"]);
            [self uploadNextFile];
        }
    }else{
        //display the error and cancel requests.
        NSString *errorText = error.localizedDescription;
        [self fileUploadFailed:errorText error:error];
         NSLog(@"File upload failed with error: %@", error);
    }
}

- (void)restClient:(DBRestClient *)client uploadFileChunkFailedWithError:(NSError *)error {
    
    totalFailedAttempts ++;
    
    //if 10 chunks fails cancel the file
    if( (error.code == -1001 || error.code==-1005) && totalFailedAttempts < ALLOWED_UPLOAD_FAILS){
        
        //re attempt each chunk for 10 times
        if(uploadAttemptsForFile < MAX_UPLOAD_FAILS_PER_FILE)
        {
            uploadAttemptsForFile++;
            NSString* uploadId = [error.userInfo objectForKey:@"upload_id"];
            unsigned long long offset = [[error.userInfo objectForKey:@"offset"]unsignedLongLongValue];
            [self.restClient uploadFileChunk:uploadId offset:offset fromPath:[error.userInfo valueForKey:@"fromPath"]];
        }else{
            uploadAttemptsForFile = 0;
            [self.restClient cancelFileUpload:[error.userInfo valueForKey:@"fromPath"]];
             NSLog(@"Cancel file upload for %@ due to failures of several chunks.",[error.userInfo valueForKey:@"fromPath"]);
            [self uploadNextFile];
        }
    }else{
        //display the error and cancel requests
        NSString *errorText = error.localizedDescription;
        [self fileUploadFailed:errorText error:error];
        NSLog(@"File upload failed with error: %@", error);
    }
}

- (void)restClient:(DBRestClient *)client uploadedFileChunk:(NSString *)uploadId newOffset:(unsigned long long)offset
          fromFile:(NSString *)localPath expires:(NSDate *)expiresDate {
    
    NSLog(@"uploadedFileChunk: %@, newOffset: %llu, fromFile: %@, expires: %@", uploadId, offset, localPath, expiresDate);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:localPath error: NULL];
    
    if (offset >= [attrs fileSize]) {
        // all data has been uploaded
        [self.restClient uploadFile:[fileManager displayNameAtPath:localPath] toPath:@"/" withParentRev:nil fromUploadId:uploadId];
        //chunk file upload create a folder structure according to the local path save the file there, hence moving the file back to root path
        NSLog(@"File %@ succefully uploaded.", [fileManager displayNameAtPath:localPath] );
      //  [self.restClient moveFrom:localPath toPath:[NSString stringWithFormat:@"/%@" , [fileManager displayNameAtPath:localPath]]];
        [self finishChunkUpload:localPath];
    } else {
        // more data to upload
        [self.restClient uploadFileChunk:uploadId offset:offset fromPath:localPath];
    }
    
}

- (void)restClient:(DBRestClient *)client uploadFileChunkProgress:(CGFloat)progress {
    
    NSLog(@"uploadFileChunkProgress: %f", progress);
    
}



//upload file in chunk callback
- (void)finishChunkUpload: (NSString*)localPath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"File uploaded successfully to path: %@", localPath);
    
    NSError *error;
    
    if(localPath != recordingInfoFile && localPath !=logFilePath){
        
        BOOL success = [fileManager removeItemAtPath:localPath error:&error];
        // Display success message if all recordings successfully uploaded
        // Update count of recordings
        [self setNumberOfFilesRemainingForUpload];
        
        // numberOfRecordingsForUpload=1 because we are checking before deleting the file
        if (success && numberOfRecordingsForUpload == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Success" message: @"All Files uploaded successfully!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        else if(!success){
            NSString *errorText = [@"Could not delete file -:" stringByAppendingString:[error localizedDescription]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Failed" message:errorText delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        // upload the next file
        [self uploadNextFile];
    }
}


/*
 * Calculates and sets Label of number of files remaining for uplaod
 */
- (void)setNumberOfFilesRemainingForUpload {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory error:nil];
    NSString *filePath;
    int numOfRecordings = 0;
    for (filePath in filePathsArray)
    {
        if ([filePath containsString:@"Recording"] || [filePath containsString:@"ReadingTest"])
        {
            numOfRecordings++;
        }
    }
    
    self->numberOfRecordingsForUpload = numOfRecordings;
    self.numberOfRecordingsForUploadLabel.text = [NSString stringWithFormat:@"%i", numOfRecordings];
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
    [self saveUsername:fullName];
    self.labelUsername.text = [NSString stringWithFormat:@"User: %@", fullName];
    if (recordingInfoFile == nil) {
        [self initInfoFile]; // load file to record recording metadata
        [self initLogFile:fullName];
    }
}



-(void)addItemViewController:(DevelopmentInterfaceViewController *)controller passDevelopmentSettings:(DevelopmentSettings *)developmentSettings
{
    [self setDevelopmentSettingsFromInput:developmentSettings];
    
    //load new values
    [self setUserSpecificSettings];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"DevelopmentSettings"]){
        DevelopmentSettings *settings = [DevelopmentSettings new];
        settings.AUDIOMONITOR_THRESHOLD = AUDIOMONITOR_THRESHOLD;
        settings.MAX_SILENCETIME = MAX_SILENCETIME;
        settings.MAX_MONITORTIME = MAX_MONITORTIME;
        settings.MAX_RECORDTIME = MAX_RECORDTIME;
        settings.MIN_RECORDTIME = MIN_RECORDTIME;
        settings.silenceTime = silenceTime;
        settings.dt = dt;
        
        DevelopmentInterfaceViewController *dvc = [segue destinationViewController];
        dvc.settings = settings;
        dvc.delegate = self;
    }
    
    
}

- (void)setDevelopmentSettingsFromInput: (DevelopmentSettings *)settings
{
    AUDIOMONITOR_THRESHOLD  = settings.AUDIOMONITOR_THRESHOLD;
    MAX_SILENCETIME  = settings.MAX_SILENCETIME;
    MAX_MONITORTIME  = settings.MAX_MONITORTIME;
    MAX_RECORDTIME  = settings.MAX_RECORDTIME;
    MIN_RECORDTIME  = settings.MIN_RECORDTIME;
    silenceTime  = settings.silenceTime;
    dt  = settings.dt;
}

// save user name
- (IBAction)saveUsername:(NSString*)username {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:username forKey:@"username"];
    [defaults synchronize];
}

- (IBAction)getUsername{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    fullName = [defaults objectForKey:@"username"];
}

-(void)loadRecordedTime{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    cribTime = [defaults floatForKey:@"cribTime"];
    supTime = [defaults floatForKey:@"supTime"];
    unsupTime = [defaults floatForKey:@"unsupTime"];
    siblingTime = [defaults floatForKey:@"siblingTime"];
    totalRecordTime += cribTime + supTime + unsupTime + siblingTime;
    unsigned int totalTimeInSec = (unsigned int)round(totalRecordTime);
    self.numberOfMinutesRecorded.text =[[NSString alloc] initWithFormat:@"%02u:%02u:%02u", totalTimeInSec/3600, (totalTimeInSec/60)%60, totalTimeInSec%60];
}

-(void)saveRecordedTime{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setFloat:cribTime forKey:@"cribTime"];
    [defaults setFloat:supTime forKey:@"supTime"];
    [defaults setFloat:unsupTime forKey:@"unsupTime"];
    [defaults setFloat:siblingTime forKey:@"siblingTime"];
    [defaults synchronize];
}


- (NSInteger)getWeekOfYear{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    weekNumber = (NSInteger)[defaults objectForKey:@"weekOfYear"];
    return weekNumber;
}

-(void) saveWeekOfYear:(NSInteger)weekOfYear{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:weekOfYear forKey:@"weekOfYear"];
    [defaults synchronize];
}

//set user specific settings

-(void)setUserSpecificSettings{
    
    //disable advanced settings if the username is not admin
    if([fullName  isEqual: @"admin"]){
        [self.statusLabel setHidden:YES];
        [self.audioLevelLabel setHidden:NO];
        [self.playButton setHidden:NO];
        //TODO hide advanced settings
    }else{
        [self.statusLabel setHidden:YES];
        [self.audioLevelLabel setHidden:YES];
        [self.playButton setHidden:YES];
    }
    
    //show only the buttons relevant to test group
    userGroup = [[NSUserDefaults standardUserDefaults] integerForKey:@"usergroup"];
    if(userGroup == 1){
        //all three tests need to be done. hence no alterations to the UI
        [self.buttonSupOn setHidden:NO];
        [self.buttonCribOn setHidden:NO];
        [self.buttonUnsupOn setHidden:NO];
        [self.buttonReadingTest setHidden:NO];
        [self.buttonTrackProgress setHidden:NO];
        [self.labelTimeRecorded setHidden:NO];
        [self.numberOfMinutesRecorded setHidden:NO];
        [self.buttonRecordSibling setTitle:@"Record Sibling" forState:UIControlStateNormal];
        
        self.buttonRecordSibling.frame = CGRectMake(167,175,140, 40);
        self.buttonReadingTest.frame = CGRectMake(167, 241, 140, 40);
        self.labelComment.frame = CGRectMake(29, 332, 84, 21);
        self.textfieldComment.frame = CGRectMake(167,323 , 140, 30);
        
        
    }else if(userGroup ==2){
        //only the recodring of sibling is required
        [self.buttonSupOn setHidden:YES];
        [self.buttonCribOn setHidden:YES];
        [self.buttonUnsupOn setHidden:YES];
        [self.buttonReadingTest setHidden:NO];
        [self.buttonTrackProgress setHidden:NO];
        [self.labelTimeRecorded setHidden:NO];
        [self.numberOfMinutesRecorded setHidden:NO];
        [self.buttonRecordSibling setTitle:@"Record" forState:UIControlStateNormal];
        
        self.buttonRecordSibling.frame = CGRectMake(23,109,140, 40);
        self.buttonReadingTest.frame = CGRectMake(23, 175, 140, 40);
        self.labelComment.frame = CGRectMake(23, 241, 84, 21);
        self.textfieldComment.frame = CGRectMake(167,241 , 140, 30);
    }
    
    //load names of children saved in the system
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    diagnosedUsers = [defaults arrayForKey:@"diagnosedUsers"];
    undiagnosedUsers = [defaults arrayForKey:@"undiagnosedUsers"];
}


-(void) initRecordingModeButtons{
    
    [self.buttonCribOn setTag:0];
    [self.buttonSupOn setTag:1];
    [self.buttonUnsupOn setTag:2];
    [self.buttonRecordSibling setTag:3];
    [self.buttonCribOn  addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSupOn  addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonUnsupOn  addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonRecordSibling addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonCribOff addTarget:self action:@selector(stopTapped:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)resetModeButtons{
    
    [self.buttonCribOn setEnabled:YES];
    [self.buttonCribOff setEnabled:NO];
    [self.buttonSupOn setEnabled:YES];
    [self.buttonUnsupOn setEnabled:YES];
    [self.buttonRecordSibling setEnabled:YES];
    [self.buttonCribOn setSelected:NO];
    [self.buttonSupOn setSelected:NO];
    [self.buttonUnsupOn setSelected:NO];
    [self.buttonRecordSibling setSelected:NO];
    
    
    //clear comment field
    self.textfieldComment.text =@"";
    [self.textfieldComment setEnabled:NO];
}

- (void)start:(id)sender {
    previousMode = currentMode;
    [self resetModeButtons];
    switch ([sender tag]) {
        case 0:
            currentMode = @"CRIB";
            [self.buttonCribOn setSelected:YES];
            [self.buttonCribOff setEnabled:YES];
            [self.buttonSupOn setSelected:NO];
            [self.buttonUnsupOn setSelected:NO];
            [self.buttonRecordSibling setSelected:NO];
            break;
        case 1:
            currentMode = @"SUPERVISED";
            [self.buttonCribOn setSelected:NO];
            [self.buttonCribOff setEnabled:YES];
            [self.buttonSupOn setSelected:YES];
            [self.buttonUnsupOn setSelected:NO];
            [self.buttonRecordSibling setSelected:NO];
            break;
        case 2:
            currentMode = @"UNSUPERVISED";
            [self.buttonCribOn setSelected:NO];
            [self.buttonCribOff setEnabled:YES];
            [self.buttonSupOn setSelected:NO];
            [self.buttonUnsupOn setSelected:YES];
            [self.buttonRecordSibling setSelected:NO];
            break;
        case 3:
            currentMode = @"SIBLING";
            [self.buttonCribOn setSelected:NO];
            [self.buttonCribOff setEnabled:YES];
            [self.buttonSupOn setSelected:NO];
            [self.buttonUnsupOn setSelected:NO];
            [self.buttonRecordSibling setSelected:YES];
            break;
        default:
            break;
    }
    
    //initially previous mode is null
    
    if(previousMode == nil || [previousMode isEqualToString:@""]){
        previousMode = currentMode;
    }
    
    
    /*
     * When record button is tapped, Audio monitor should be started
     */
    
    if (!isMonitoring)
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [self initAudioMonitorAndRecord];
        
    }
    else{
        [self stopAndRecord];
    }
    
    // Enable stop button and disable play button
    [self.buttonCribOff setEnabled:YES];
    [self.textfieldComment setEnabled:YES];
    comment = @"";
    
    //show time
    self.timeElapsedLabel.text = @"00:00:00";
    [self.timeElapsedLabel setHidden:NO];
}

-(void)modeChanged:(id)sender{
    
    selectedSender = sender;
    
    //if more than one children participating to the study direct to namepicker page
    if(([undiagnosedUsers count] >1 && [sender tag]<3) || ([diagnosedUsers count] >1 && [sender tag] ==3)){
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        NamePickerController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NamePickerController"];
        vc.delegate = self;
        
        if([sender tag] == 3){
            vc.userType =2;
        }else{
            vc.userType =1;
        }
        [self presentViewController:vc animated:YES completion:nil];
        
    }else{
        // no need to select the names
        if([sender tag] == 3){
            if([diagnosedUsers count] ==1) {
                childNames = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"diagnosedUsers"] objectAtIndex:0];
            }
        }else{
            if ([undiagnosedUsers count] ==1 ) {
                childNames = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"undiagnosedUsers"] objectAtIndex:0];
            }
        }
        [self start:sender];
    }
    
    
}



//methods to check battery status. These are used to compare microphones.

-(void)recordBatteryStatus{
    
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelChanged:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
    if(measuresFilePath == nil) {
        NSString *documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSString *file = [NSString stringWithFormat:@"batterylevel.csv"];
        NSString *filePath = [documentsDir stringByAppendingPathComponent:file];
        measuresFilePath = filePath;
        NSError *error = nil;
        BOOL success = [@"" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if(success == NO) {
            NSLog(@"-- cannot create measures files %@", error);
            return;
        }
        
    }
    
}


- (void)updateBatteryState
{
    UIDeviceBatteryState currentState = [UIDevice currentDevice].batteryState;
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    
    NSString *deviceInfo=[NSString stringWithFormat:@"time:, %d, monitor-time:, %f, record:, %f ,deviceBatteryState:, %ld, deviceBatteryLevel:, %f",  (int)[[NSDate date] timeIntervalSince1970], [audioMonitor currentTime], [recorder currentTime], (long)currentState, batteryLevel];
    
    NSString *csvLine = [deviceInfo stringByAppendingString:@"\n"];
    NSData *csvData = [csvLine dataUsingEncoding:NSUTF8StringEncoding];
    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:measuresFilePath];
    [fh seekToEndOfFile];
    [fh writeData:csvData];
    [fh closeFile];
    
}

- (void)batteryLevelChanged:(NSNotification *)notification
{
    [self updateBatteryState];
}

- (void)batteryStateChanged:(NSNotification *)notification
{
    [self updateBatteryState];
}


//track amount of recordings done for the week
-(void) updateRecordingTime:(NSString*)recordingMode : (double)duration
{
    //Get current week number
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
    NSInteger currentWeek = [components weekOfYear];

    
    if (weekNumber != (int)currentWeek ){
        //start of next week. reset times
        cribTime = 0;
        supTime  = 0;
        unsupTime = 0;
        siblingTime = 0;
        [self saveRecordedTime];
        weekNumber = currentWeek;
        [self saveWeekOfYear:weekNumber];
        NSLog(@"Starting the week number %d", (int)currentWeek);
    }
    
    
    if (weekNumber == currentWeek ){
        
        if ( [recordingMode  isEqual: @"CRIB"]){
            cribTime += duration;
        }
        else if ( [recordingMode  isEqual: @"SUPERVISED"]){
            supTime += duration;
        }else if ( [recordingMode  isEqual: @"UNSUPERVISED"]){
            unsupTime += duration;
        }else if( [recordingMode isEqual:@"SIBLING"]){
            siblingTime +=duration;
        }
    }
    
    //save to user defaults to make persistant
    [self saveRecordedTime];
    
    NSLog(@"Updated recording time crib: %f, sup: %f, unsup: %f, sibl: %f ", cribTime, supTime, unsupTime, siblingTime);
}


//show the amount of recordings done within the current week
-(void)showProgress{
    
    NSMutableString *message = [NSMutableString string];
    
    
    //calculate total crib mode recording time
    
    unsigned int timeInSec = (unsigned int)round(cribTime);
    
    [message appendString:[NSString stringWithFormat:@"CRIB Mode\t\t\t\t %02u:%02u:%02u",
                           timeInSec / 3600, (timeInSec/60)%60, timeInSec % 60]];
    
    
    
    timeInSec = (unsigned int)round(supTime);
    [message appendString:[NSString stringWithFormat:@"\nSUPERVISED Mode\t\t %02u:%02u:%02u",
                           timeInSec / 3600, (timeInSec/60)%60, timeInSec % 60]];
    
    
    timeInSec = (unsigned int)round(unsupTime);
    
    
    
    [message appendString:[NSString stringWithFormat:@"\nUN-SUPERVISED Mode\t %02u:%02u:%02u",
                           timeInSec / 3600, (timeInSec/60)%60, timeInSec % 60]];
    
    timeInSec = (unsigned int)round(siblingTime);
    
    
    [message appendString:[NSString stringWithFormat:@"\nRecordings of sibling\t\t %02u:%02u:%02u",
                           timeInSec / 3600, (timeInSec/60)%60, timeInSec % 60]];
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSString *title = [NSString stringWithFormat:@"Hours Recorded During the Week starting from %@", [dateFormat stringFromDate:[self getFirstDayofWeek]]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message:message delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    
    
    [alert show];
    
}


-(void)initInfoFile{
    
    //    if(recordingInfoFile == nil) {
    NSString *documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString *infoFileName = [NSString stringWithFormat:@"%@-info.csv",fullName];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:infoFileName];
    recordingInfoFile = filePath;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:recordingInfoFile]) {
        [[NSFileManager defaultManager] createFileAtPath:recordingInfoFile contents:nil attributes:nil];
    }
    //    }
}

-(void)updateMetadataFile{
    
    if (recordingInfoFile == nil) {
        [self initInfoFile]; // load file to record recording metadata
    }
    
//    NSDate *today = [NSDate date];
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    
    
    NSString *info=[NSString stringWithFormat:@"Date:, %@, User:, %@_%@, Mode:, %@, File:, %@, Comments:, %@, Duration:, %f",
                    [self getDate],
                    fullName, childNames,
                    previousMode,
                    fileName,
                    comment,
                    totalRecordTime];
    
    //clear the comment variable after saving
   // comment = nil;
    
    NSString *csvLine = [info stringByAppendingString:@"\n"];
    NSData *csvData = [csvLine dataUsingEncoding:NSUTF8StringEncoding];
    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:recordingInfoFile];
    [fh seekToEndOfFile];
    [fh writeData:csvData];
    [fh closeFile];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textfieldComment resignFirstResponder];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    
    if(userGroup == 1){
        self.view.frame = CGRectMake(0,-50,self.view.frame.size.width,self.view.frame.size.height);
    }else if (userGroup==2) {
        self.view.frame = CGRectMake(0,-70,self.view.frame.size.width,self.view.frame.size.height);
    }
    [UIView commitAnimations];
    
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


//to dismiss the keyboard when tapped anywhere
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self.textfieldComment endEditing:YES];
    [self textFieldShouldReturn:self.textfieldComment];
}


-(NSDate*)getFirstDayofWeek{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDate *startOfTheWeek;
    NSTimeInterval interval;
    [cal rangeOfUnit:NSWeekCalendarUnit
           startDate:&startOfTheWeek
            interval:&interval
             forDate:now];
    //startOfWeek holds now the first day of the week, according to locale (monday vs. sunday)
    
    NSDateFormatter *dateFormat_first = [[NSDateFormatter alloc] init];
    [dateFormat_first setDateFormat:@"yyyy-MM-dd"];
    return startOfTheWeek;
}


//methods to show upload progress
-(void)startUploadProgress:(NSNumber *)numberOfFiles{
    uploadProgressValue =0.0f;
    [self.progressViewUpload setHidden:NO];
    [self.labelUploadProgress setHidden:NO];
    [self.uploadButton setEnabled:NO];
    [self increaseUploadProgress:numberOfFiles];
    
    //start to play silent background audio to keep on uploading
    [self startSilentAudioFile];
    
}
-(void)increaseUploadProgress:(NSNumber*)numberOfFiles{
    
    if(self.progressViewUpload.progress < 1 && numberOfFiles > 0){
        uploadProgressValue = ([numberOfFiles integerValue]-numberOfRecordingsForUpload)/(float)[numberOfFiles integerValue];
        self.progressViewUpload.progress = uploadProgressValue;
        [self performSelector:@selector(increaseUploadProgress:) withObject:numberOfFiles  afterDelay:0.1];
        
    }else if (uploadProgressValue == 1 || numberOfRecordingsForUpload ==0 ){
        [self resetUploadProgressView];
    }
    

}
-(void)resetUploadProgressView{
    uploadProgressValue = 0;
    self.progressViewUpload.progress = 0;
    [self.progressViewUpload setHidden:YES];
    [self.labelUploadProgress setHidden:YES];
    [self.uploadButton setEnabled:YES];
    [self stopSilentAudioFile];
}

-(IBAction)readingTestTapped:(id)sender{
    
    if(isMonitoring){
        //currentMode =@"READING";
        previousMode = currentMode;
        [self stopRecorder];
        [self stopAudioMonitorAndAudioMonitorTimer];
        [recordingTimer invalidate];
        [self updateDisplay];
    }
}


/**
 establishing a link and launching the authenticating process with dropbox,
 **/
- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}


-(void)getSelectedChild:(NSSet *)names
{
    // data will come here from NamePickerController
    [self start:selectedSender];
    childNames = [[names allObjects] componentsJoinedByString:@"_"];
}



-(void)initLogFile:(NSString*)deviceName{
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logfileName =[NSString stringWithFormat:@"%@.log",deviceName];
        logFilePath = [documentsDirectory stringByAppendingPathComponent:logfileName];
        freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}


/**play silent audio in background to keep the upload running
 **/
-(void)startSilentAudioFile
{
    
    if(![backgroundPlayer isPlaying]){
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"silence" ofType:@"mp3"]];
        
        //set audio session for background audio
        NSError *sessionError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        backgroundPlayer.numberOfLoops = -1;
        [backgroundPlayer play];
        
        NSLog(@"Silent audio started");
    }
}

-(void)stopSilentAudioFile
{

    if([backgroundPlayer isPlaying] && ![recorder isRecording]){
        // Give up audio session
        [backgroundPlayer stop];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
         NSLog(@"Silent audio stopped");
    }
}

@end

//
//  ViewController.m
//  VoiceRecorder
//
//  Created by Spencer King on 9/30/14.
//  Copyright (c) 2014 University of Notre Dame. All rights reserved.
//

#import "ViewController.h"
#import <DropboxSDK/DropboxSDK.h>

//DBRestClient is used to access Dropbox after linking  
@interface ViewController () <DBRestClientDelegate> {
    //declare instances for recording and playing
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    NSString *fileName;
    NSArray *pathComponents;
    NSURL *outputFileURL;
    
}
@property (nonatomic, strong) DBRestClient *restClient;
@end

@implementation ViewController
@synthesize stopButton, playButton, recordButton, linkButton, uploadButton, storageText, currentText;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self freeDiskspace]; //will set a text field to the current free space when the app is started
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    // Do any additional setup after loading the view, typically from a nib.
    //disable the stop and play buttons when the app launches
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    
}

//set up the filename
-(void)setFilename {
    
    //name the file with the recording date, later add device ID
    fileName = @"test";//[self getDate];
    
    //set the audio file
    //this is for defining the URL of where the sound file will be saved on the device
    pathComponents = [NSArray arrayWithObjects:
                      [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                      fileName,
                      nil];
    
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
}

//for linking to dropbox
- (IBAction)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"linking");
    }
    NSLog(@"already linked");
    [self uploadFile]; //upload the test file
}

//function to initialize the recorder
//Assistance from: http://www.appcoda.com/ios-avfoundation-framework-tutorial/
- (void)recorderInit {
    
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

//upload to Dropbox
- (IBAction)uploadFile {
    
    //create a test file for uploading
    /*NSString *text = @"Hello world.";
    NSString *filename = @"working-draft.txt";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    //NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];*/
    //NSLog(@"write file");
    
    NSString *localPath = [outputFileURL absoluteString];
    
    // Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:fileName toPath:destDir withParentRev:nil fromPath:localPath];
    //NSLog(@"upload file");
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//https://developer.apple.com/library/ios/documentation/cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
//this function returns the date, which will be used for the recording file name
- (NSString*)getDate {
    //initialize variables
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString        *dateString;
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"]; //format the date string
    
    dateString = [dateFormatter stringFromDate:[NSDate date]]; //get the date string

    currentText.text = dateString; //test to make sure date is correct
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
    storageText.text = str; //display the amount of free space
    return totalFreeSpace;
}


- (IBAction)recordTapped:(id)sender {
    
    [self setFilename]; //sets the filename
    [self recorderInit]; //initialize the recorder
    
    //make sure to stop the audio player before recording
    //REMOVE IN FINAL VERSION, NOT POSSIBLE FOR SOMETHING TO BE PLAYING
    if (player.playing) {
        [player stop];
    }
    
    //if the app is not already recording, start recording
    if (!recorder.recording){
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil]; //we need an active audio session to record
        
        //start the recording
        [self recorderInit]; //initialize the recorder
        [recorder record];
        [recordButton setTitle:@"Pause" forState:UIControlStateNormal];
         currentText.text = @"recording"; //test text
    }
    else{
        //pauses the recording
        [recorder pause];
        [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    }
         
    [stopButton setEnabled:YES];
    [playButton setEnabled:NO];
}

         
//stops the recorder and deactivates the audio session
- (IBAction)stopTapped:(id)sender {
    [recorder stop];
    currentText.text = @"stopped"; //test text
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    //[self uploadFile]; //upload the recording
    }




//initializes the audio player and assigns a sound file to it
//CUT THIS FROM THE FINAL VERSION, NO NEED TO PLAYBACK FILES
- (IBAction)playTapped:(id)sender {
    if (!recorder.recording){
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
            [player setDelegate:self];
            [player play];
            currentText.text = @"playing"; //test text
    }
}

//upload button pressed
- (IBAction)uploadTapped:(id)sender {
    [self uploadFile]; //upload the test file

}



- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finished playing the recording"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}




/*
//Uploading to a web server, copied directly from a stackoverflow thread
//I get an error about permissions, presumably on the server side
//Tested using my cse30246 account on Prof. Weninger's server
//http://stackoverflow.com/questions/17268025/upload-recorded-audio-file-in-objective-c-using-php
- (void)uploadFile {
    NSData *file1Data = [[NSData alloc] initWithContentsOfFile:[recorder.url path]];
    NSString *urlString = @"http://dsg1.crc.nd.edu/~sking8/uploadFile.php";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"AudioFile3.m4a\"\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:file1Data]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Return String= %@",returnString);
}
 */
@end

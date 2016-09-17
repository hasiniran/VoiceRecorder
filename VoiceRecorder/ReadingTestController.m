//
//  UIViewController+ReadingTestController.m
//  VoiceRecorder
//
//  Created by Randy on 9/13/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "ReadingTestController.h"
#import <AVFoundation/AVFoundation.h>


@interface ReadingTestController (){
    AVAudioRecorder *recorder;
    AVAudioSession *session;
    BOOL isRecording;
    NSUserDefaults *defaults;
    NSString        *dateString;
    NSString* fileName;
}

@end

@implementation ReadingTestController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(100,100, 500,800);
    self.pageViewController.view.backgroundColor=[UIColor blueColor];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    //start recording
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startWalkthrough:(id)sender {
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}



- (IBAction)recordTapped:(id)sender {
    
    [self record];
    
}
- (IBAction)cancelTapped:(id)sender {
}
- (IBAction)stopTapped:(id)sender {
    //stop recording
    
    if([self.stopButton.titleLabel.text  isEqual: @"Stop"]){
        
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        isRecording = NO;
    }
    [self dismissViewControllerAnimated:NO completion:nil];

}

-(void)record{
    //initialize the recorder
    
    if(!isRecording){
        
        //set the output file url
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"]; //format the date string
        dateString = [dateFormatter stringFromDate:[NSDate date]]; //get the date string
        
        fileName = [NSString stringWithFormat:@"ReadingTest %@_%@ test1 %@.m4a", [defaults objectForKey:@"username"], [defaults objectForKey:@"siblingname"],dateString];
        
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
    
    if (!recorder.recording) {
        // Start recording
        [recorder record];
        [self.recordButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.recorderStatusLabel.text =@"Recording...";
        
    } else {
        // Pause recording
        [recorder pause];
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        self.recorderStatusLabel.text =@"Recorder is paused.";
    }
    
    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    isRecording = true;
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [self.stopButton setEnabled:NO];
}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeLeft; // or Right of course
//}
//
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}

@end

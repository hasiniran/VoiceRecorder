//
//  UIViewController+ReadingTest4Controller.m
//  VoiceRecorder
//
//  Created by Randy on 9/19/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "ReadingTest4Controller.h"
#import <AVFoundation/AVFoundation.h>

@implementation ReadingTest4Controller{
    AVAudioRecorder *recorder;
    AVAudioSession *session;
    BOOL isRecording;
    NSUserDefaults *defaults;
    NSString  *dateString;
    NSString* fileName;
    NSInteger currentPage;
    int storyNumber;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    storyNumber = arc4random_uniform(2);
    
    if(storyNumber ==0){
        self.titleLabel.text = @"Jack and Rachel";
        self.pageTitles = @[ @"Jack and Rachel are going fishing. \n \nRachel is in such a rush that she drops her glasses and gets her shirt caught in the zipper of her jacket.", @"They fish from the old bridge. \n\n All of a sudden they hear a loud noise. \n\n Oh! It's only the dog chasing a frog.", @"Jack and Rachel catch thirteen fish.\n\n1...2...3...four...five...6...7..8..9..10..11..12..thirteen! \n\nThey laugh because they are very, very, very happy.", @"They go back to Jack's house. \n\n Jack's mother cooks the fish."];
    }else if (storyNumber ==1){
         self.titleLabel.text = @"A Bad Night for Jerry";
        self.pageTitles = @[@"Jerry is playing with his drum, ball and wagon.\n\nHe is making too much noise.\n\nHis mother makes him stop.\n\nIt is time to take a bath", @"Jerry is taking a bath.\n\nOh, no!\n\nHe loses the soap.\n\nHe cannot find it because it is outside the bathtub.\n\nSee the soap.\n\nIt is on the floor.",@"Now he is brushing his teeth with his toothbrush.\n\nLook, he spills toothpaste on his brand new blue pajamas.", @"Nothing else can happen tonight, thinks Jerry.\n\nHe yawns and reaches to turn out the new yellow light.\n\nOh,no!\n\nHe knocks over the yellow light.",@"After a bad nigh, Jerry is finally sleeping.\n\nHis daddy covers him with the sheet.\n\nWhoops! His foot rips the sheet."];
    }
    
    
    // Create page view controller

//    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
//    self.pageViewController.dataSource = self;
//    
//     StoryPageViewController  *startingViewController = [self viewControllerAtIndex:0];
//    NSArray *viewControllers = @[startingViewController];
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//    
//    // Change the size of page view controller
//    self.pageViewController.view.frame = CGRectMake(0,0, 600,self.view.frame.size.height/2+100);
//    self.pageViewController.view.backgroundColor=[UIColor blueColor];
//    self.pageViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
//    
////    [self addChildViewController:_pageViewController];
//    [self.view addSubview:_pageViewController.view];
//    self.pageViewController.view.center = self.view.center;
//    [self.pageViewController didMoveToParentViewController:self];
//    
    //show instructions
    
//    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Read aloud the displayed passage." message:@"Click pause to pause the recording and record to continue recording. Click Stop to exit the test." delegate:nil cancelButtonTitle:Nil otherButtonTitles:@"Start Test" , nil];
//
//    [alert setDelegate:self];
//    alert.tag =1;
//    [alert show];
    
    currentPage=0;
    [self showPage:currentPage];
    defaults = [NSUserDefaults standardUserDefaults];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//- (StoryPageViewController *)viewControllerAtIndex:(NSUInteger)index
//{
//    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
//        return nil;
//    }
//    
//    // Create a new view controller and pass suitable data.
//    StoryPageViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StoryPageContentController"];
//    pageContentViewController.titleText = self.pageTitles[index];
//    pageContentViewController.pageIndex = index;
//    return pageContentViewController;
//}
//
//#pragma mark - Page View Controller Data Source
//
//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
//{
//    NSUInteger index = ((StoryPageViewController*) viewController).pageIndex;
//    
//    if ((index == 0) || (index == NSNotFound)) {
//        return nil;
//    }
//    
//    index--;
//    return [self viewControllerAtIndex:index];
//}
//
//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
//{
//    NSUInteger index = ((StoryPageViewController*) viewController).pageIndex;
//    
//    if (index == NSNotFound) {
//        return nil;
//    }
//    
//    index++;
//    if (index == [self.pageTitles count]) {
//        return nil;
//    }
//    return [self viewControllerAtIndex:index];
//}
//
//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
//{
//    return [self.pageTitles count];
//}
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
//{
//    return 0;
//}


- (IBAction)recordTapped:(id)sender {
    
    [self record];
    
}
- (IBAction)cancelTapped:(id)sender {
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Are you sure you want to cancel the current test?" message:@" If you select YES, ongoing recording will be stopped and the recorded test will be deleted. If you want to stop the recorder without deleting the record click STOP instead. " delegate:nil cancelButtonTitle:Nil otherButtonTitles:@"YES", @"NO" , nil];
    alert.cancelButtonIndex=1;
    alert.tag = 2;
    [alert setDelegate:self];
    [alert show];
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if( alertView.tag ==2){
    if( buttonIndex ==0){
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        isRecording = NO;
        
        [self dismissViewControllerAnimated:NO completion:nil];
        
        //TODO: remove the file
    }
    }
    else if(alertView.tag==1){
        [self record];
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
    [defaults setObject:dateString  forKey:@"Test4LastTaken"];
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

-(void)record{
    //initialize the recorder
    
    if(!isRecording){
        
        //set the output file url
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"]; //format the date string
        dateString = [dateFormatter stringFromDate:[NSDate date]]; //get the date string
        
        fileName = [NSString stringWithFormat:@"ReadingTest %@_%@ story_%d %@.m4a", [defaults objectForKey:@"username"], [defaults objectForKey:@"siblingname"],storyNumber,dateString];
        
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

-(void)showPage:(NSInteger)pageNumber{
    self.pageText.text = self.pageTitles[pageNumber];
    
    //enable, disable page navigation buttons
    if(pageNumber == 0){
        [self.previousPageButton setEnabled:NO];
        [self.nextPageButton setEnabled:YES];
    }else if (pageNumber == self.pageTitles.count-1){
        [self.previousPageButton setEnabled:YES];
        [self.nextPageButton setEnabled:NO];
    }else{
        [self.previousPageButton setEnabled:YES];
        [self.nextPageButton setEnabled:YES];
    }
}
- (IBAction)nextPageTapped:(id)sender {
    if(currentPage < self.pageTitles.count){
       currentPage++;
       [self showPage:currentPage];
    }
}
- (IBAction)previousPageTapped:(id)sender {
    
    if(currentPage > 0){
        currentPage--;
        [self showPage:currentPage];
    }
}
- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
}

@synthesize delegate;
-(void)viewWillDisappear:(BOOL)animated
{
    [delegate setLastTakenDate:dateString:@"Test4"];
    
}

@end

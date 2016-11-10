//
//  EmotionViewController.m
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 10/18/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "EmotionViewController.h"


@implementation EmotionViewController:UIViewController{
    NSString* currentEmotion;
    NSInteger currentEmotionalIntensity;
    NSString* recordingFilePath;
    NSString* emotionCSVFilePath;
    bool isEmotionSelected;
    NSString* username;
    ViewController* parentView;
    
    UIView *popupView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init variables
    isEmotionSelected=NO;
    parentView = (ViewController*)self.delegate;
    
    
    //set tags for buttons
    [self.buttonEmotion1 setTag:0];
    [self.buttonEmotion2 setTag:1];
    [self.buttonEmotion3 setTag:2];
    
    //load emotion.csv file
    [self loadEmotionsCSVFile];
    
}


-(void)loadEmotionsCSVFile{
    
    //if file doesnt exist create file
    
    username= ((ViewController*)self.parentViewController).getUsername; // TODO: get through getter method
    
    if(username!=NULL){
        
        NSLog(@"username: %@", username);
        
        NSString *documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSString *fileName = [NSString stringWithFormat:@"%@-emotions.csv",username];
        NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
        emotionCSVFilePath = filePath;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }
    }
    
}

-(void)writeToFile:(NSString*)emotion : (NSInteger)intensity : (NSString*)start : (NSString*)end{
    
    if(emotionCSVFilePath == NULL || [emotionCSVFilePath  isEqual: @""]){
        [self loadEmotionsCSVFile];
    }
    
    NSString* recordingFileName = [((ViewController*)self.parentViewController) getRecordingFileName];
    
    if(recordingFileName != NULL && ![recordingFileName isEqualToString:@""]){
        
        //create csv string
        
        NSString *info=[NSString stringWithFormat:@"File:,%@,Emotion:,%@,Intensity:,%d,Start:,%@,End:,%@",
                        recordingFileName,
                        emotion,
                        intensity,
                        start,
                        end];
        
        NSLog(info);
        
        //write to file
        NSString *csvLine = [info stringByAppendingString:@"\n"];
        NSData *csvData = [csvLine dataUsingEncoding:NSUTF8StringEncoding];
        NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:emotionCSVFilePath];
        [fh seekToEndOfFile];
        [fh writeData:csvData];
        [fh closeFile];
    }
}




-(NSString*) getAssociatedEmotion: (id)sender{
    
    
    switch ([sender tag]) {
        case 0:
            return @"Positive";
            break;
            
        case 1:
            return @"Neutral";
            break;
            
        case 2:
            return @"Negative";
            break;

        default:
            return @"";
            break;
    }
}

-(void)disableButtonsExcept:(id)sender{
    switch ([sender tag]) {
        case 0:
            [self.buttonEmotion2 setEnabled:NO];
            [self.buttonEmotion3 setEnabled:NO];
            break;
            
        case 1:
            [self.buttonEmotion1 setEnabled:NO];
            [self.buttonEmotion3 setEnabled:NO];
            break;
            
        case 2:
            [self.buttonEmotion1 setEnabled:NO];
            [self.buttonEmotion2 setEnabled:NO];
            break;
                   break;
            
        default:
            
            break;
    }
    
}

-(void)resetEmotionButtons{
    
    NSString* timestamp = [(ViewController*)self.parentViewController getDate];
    currentEmotion = @"";
    currentEmotionalIntensity =0;
    
    //write to csv file if not already
    if(isEmotionSelected){
        [self writeToFile:currentEmotion : currentEmotionalIntensity :@"" :timestamp];
    }
    
    [self.buttonEmotion1 setEnabled:YES];
    [self.buttonEmotion2 setEnabled:YES];
    [self.buttonEmotion3 setEnabled:YES];
    [self.buttonEmotion1 setSelected:NO];
    [self.buttonEmotion2 setSelected:NO];
    [self.buttonEmotion3 setSelected:NO];
    self.LabelSelectedEmotion.text = @"Select the emotional status of the child.";
    
    //switch off blinking
    [self.buttonEmotion1.layer removeAllAnimations];
    [self.buttonEmotion2.layer removeAllAnimations];
    [self.buttonEmotion3.layer removeAllAnimations];
    [self.LabelSelectedEmotion.layer removeAllAnimations];
}


- (void)emotionSelected:(id)sender {
    //if button is not selected, select
    
    //prompt intensity for positive and negative
    if(![sender isSelected]){
        
        [sender setSelected:YES];
        currentEmotion = [self getAssociatedEmotion:sender];
        
        //disable other buttons
        [self disableButtonsExcept:sender];
        
        isEmotionSelected = YES;

        
        if([sender tag] == 0 || [sender tag] ==2){
        
          [self selectIntensity];
        }else{
            currentEmotionalIntensity = -1;
            //write to csv file
            NSString* timestamp = [(ViewController*)self.parentViewController getDate];
            
            self.LabelSelectedEmotion.text = [NSString stringWithFormat:@"Tap again when the child stops showing %@ emotions.",    currentEmotion];
            [self writeToFile:currentEmotion : currentEmotionalIntensity : timestamp:@""];
        }
        
        //blink the button to indicate its switched on
        
        [sender setAlpha:0.4];
        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction animations:^{
            [sender setAlpha:1];
        } completion:nil];
        [self.LabelSelectedEmotion setAlpha:0.4];
        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            [self.LabelSelectedEmotion setAlpha:1];
        } completion:nil];
        
        
    }else{
        
//        [sender setSelected:NO];
        //reset buttons
        [self resetEmotionButtons];
        
        isEmotionSelected = NO;
    }
}

- (IBAction)emotion1Tapped:(id)sender {
    
    [self emotionSelected:sender];
    
}
- (IBAction)emotion2Tapped:(id)sender {
    [self emotionSelected:sender];
}
- (IBAction)emotion3Tapped:(id)sender {
    [self emotionSelected:sender];
}




-(void) showSliderPopup{
    UISlider *slider=[[UISlider alloc]initWithFrame:CGRectMake(10, 0, 300, 300)];
    CGAffineTransform trans=CGAffineTransformMakeRotation(M_PI_2);
    slider.transform=trans;
    slider.minimumValue=1;
    slider.maximumValue=100;
    slider.continuous=NO;
    [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *highlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100,100 )];
    highlabel.text = @"HIGH";
    
    
    popupView=[[UIView alloc]initWithFrame:CGRectMake(10, 10, 300, 350)]; // set popup frame your require position
    [popupView addSubview:slider];
    [popupView addSubview:highlabel];
    [self.view addSubview:popupView];
}

- (void)addLabelsToSlider:(UISlider*)slider{
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:20];
    label.text = @"Very Low";
    [label sizeToFit];
    label.center = CGPointMake(5, slider.frame.size.height-label.frame.size.height/2 + 15);
    [slider addSubview:label];
    
    
    UILabel *highlabel = [[UILabel alloc] init];
    highlabel.font = [UIFont systemFontOfSize:20];
    highlabel.text = @"Very High";
    [highlabel sizeToFit];
    highlabel.center = CGPointMake((slider.frame.size.width/10)*10 - 5,  slider.frame.size.height-label.frame.size.height/2 + 15);
    [slider addSubview:highlabel];
    
    UILabel *avglabel = [[UILabel alloc] init];
    avglabel.font = [UIFont systemFontOfSize:20];
    avglabel.text = @"Average";
    [avglabel sizeToFit];
    avglabel.center = CGPointMake((slider.frame.size.width/10)*5 - 5,  slider.frame.size.height-label.frame.size.height/2 + 15);
    [slider addSubview:avglabel];
    
    
    //    for(int i=0;i<=100;i+=10){
    //
    //        UILabel *label = [[UILabel alloc] init];
    //        label.font = [UIFont systemFontOfSize:10];
    //        if( i == o){
    //        label.text = [NSString stringWithFormat:@"%d",i];
    //        [label sizeToFit];
    //        CGFloat labelX = (slider.frame.size.width/10)*i/10;
    //        CGFloat labelY = slider.frame.size.height-label.frame.size.height/2 + 15;
    //        label.center = CGPointMake(labelX, labelY);
    //        [slider addSubview:label];
    //    }
}

-(void)selectIntensity{
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 500, 350)];
    
    ASValueTrackingSlider  *slider = [[ASValueTrackingSlider  alloc] initWithFrame:CGRectMake(tempView.bounds.size.width/2-200, tempView.bounds.size.height/2, 400, 70)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tempView.bounds.size.width/2-200, tempView.bounds.size.height/2-100, 400, 50)];
    label.text = @"How intense is the current emotional state?";
    
    //    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor clearColor]];
    slider.minimumValue = 1.0;
    slider.maximumValue = 10.0;
    slider.continuous = YES;
    slider.value = 5.0;
    [self addLabelsToSlider:slider];
    
    slider.dataSource = self;
    slider.popUpViewCornerRadius = 12.0;
    [slider setMaxFractionDigitsDisplayed:3];
    slider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
    slider.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
    slider.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
    
    [tempView addSubview:slider];
    [tempView addSubview:label];
    [alertView setContainerView:tempView];
    [alertView show];
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button value: %d.", (int)slider.value);
        currentEmotionalIntensity =(int)slider.value;
        [alertView close];
        
        //write to csv file
        NSString* timestamp = [(ViewController*)self.parentViewController getDate];

        self.LabelSelectedEmotion.text = [NSString stringWithFormat:@"Tap again when the child stops showing %@ emotions.",    currentEmotion];
        [self writeToFile:currentEmotion : currentEmotionalIntensity : timestamp:@""];

    }];
}



//-(UIView*)tickMarksViewForSlider:(UISlider*)slider View:(UIView *)view
//{
//    // set up vars
//    int ticksDivider = (slider.maximumValue > 10) ? 10 : 1;
//    int ticks = (int) slider.maximumValue / ticksDivider;
//    int sliderWidth = 364;
//    float offsetOffset = (ticks < 10) ? 1.7 : 1.1;
//    offsetOffset = (ticks > 10) ? 0 : offsetOffset;
//    float offset = sliderWidth / ticks - offsetOffset;
//    float xPos = 0;
//    
//    // initialize view to return
//    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y+1,
//                            slider.frame.size.width, slider.frame.size.height);
//    view.backgroundColor = [UIColor clearColor];
//    
//    // make a UIImageView with tick for each tick in the slider
//    for (int i=0; i < ticks; i++)
//    {
//        if (i == 0) {
//            xPos += offset+5.25;
//        }
//        else
//        {
//            UIView *tick = [[UIView alloc] initWithFrame:CGRectMake(xPos, 3, 2, 16)];
//            tick.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
//            tick.layer.shadowColor = [[UIColor whiteColor] CGColor];
//            tick.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
//            tick.layer.shadowOpacity = 1.0f;
//            tick.layer.shadowRadius = 0.0f;
//            [view insertSubview:tick belowSubview:slider];
//            xPos += offset - 0.4;
//        }
//    }
//    
//    // return the view
//    return view;
//}

#pragma mark - ASValueTrackingSliderDataSource

- (NSString *)slider:(ASValueTrackingSlider *)slider stringForValue:(float)value;
{
    value = roundf(value);
    NSString *s;
    if (value < 2) {
        s = @"Very Low";
    } else if (value >= 2 && value < 4) {
        s = @" Low";
    }else if (value >= 4 && value < 6) {
        s = @"Average";
    }else if (value >= 6 && value < 8) {
        s = @"High";
    }
    else if (value >=8) {
        s = @"Very High";
    }
    
    return s;
}


-(void)recordingModeSwitched{

    //reset buttons
    [self resetEmotionButtons];
    isEmotionSelected = NO;
}


@end

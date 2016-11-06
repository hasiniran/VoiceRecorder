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
    [self.buttonEmotion4 setTag:3];
    [self.buttonEmotion5 setTag:4];
    
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

-(void)writeToFile:(NSString*)emotion : (NSString*)start : (NSString*)end{
    
    if(emotionCSVFilePath == NULL || [emotionCSVFilePath  isEqual: @""]){
        [self loadEmotionsCSVFile];
    }
    
    NSString* recordingFileName = [((ViewController*)self.parentViewController) getRecordingFileName];
    
    if(recordingFileName != NULL && ![recordingFileName isEqualToString:@""]){
    
    //create csv string
    
    NSString *info=[NSString stringWithFormat:@"File:,%@,Emotion:,%@,Start:,%@,End:,%@",
                    recordingFileName,
                    currentEmotion,
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



-(void)resetButtons{
    
}


-(NSString*) getAssociatedEmotion: (id)sender{
  
    
    switch ([sender tag]) {
        case 0:
            return @"Angry";
            break;
            
            case 1:
            return @"Sad";
            break;
            
        case 2:
            return @"Anxious";
            break;
            
            case 3:
            return @"Happy";
            break;
            
        case 4:
            return @"Neutral";
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
            [self.buttonEmotion4 setEnabled:NO];
            [self.buttonEmotion5 setEnabled:NO];
           
            break;
            
        case 1:
            [self.buttonEmotion1 setEnabled:NO];
            [self.buttonEmotion3 setEnabled:NO];
            [self.buttonEmotion4 setEnabled:NO];
            [self.buttonEmotion5 setEnabled:NO];
            
           
            break;
            
        case 2:
            [self.buttonEmotion1 setEnabled:NO];
            [self.buttonEmotion2 setEnabled:NO];
            [self.buttonEmotion4 setEnabled:NO];
            [self.buttonEmotion5 setEnabled:NO];
            
            break;
            
        case 3:
            [self.buttonEmotion1 setEnabled:NO];
            [self.buttonEmotion2 setEnabled:NO];
            [self.buttonEmotion3 setEnabled:NO];
            [self.buttonEmotion5 setEnabled:NO];
      
            break;
            
        case 4:
            [self.buttonEmotion1 setEnabled:NO];
            [self.buttonEmotion2 setEnabled:NO];
            [self.buttonEmotion3 setEnabled:NO];
            [self.buttonEmotion4 setEnabled:NO];

            break;
            
        default:
        
            break;
    }

}

-(void)resetEmotionButtons{
    [self.buttonEmotion1 setEnabled:YES];
    [self.buttonEmotion2 setEnabled:YES];
    [self.buttonEmotion3 setEnabled:YES];
    [self.buttonEmotion4 setEnabled:YES];
    [self.buttonEmotion5 setEnabled:YES];
    [self.buttonEmotion1 setSelected:NO];
        [self.buttonEmotion2 setSelected:NO];
        [self.buttonEmotion3 setSelected:NO];
        [self.buttonEmotion4 setSelected:NO];
        [self.buttonEmotion5 setSelected:NO];
    self.LabelSelectedEmotion.text = @"Start the recorder. Tap an emotion to select.";
}


- (void)emotionSelected:(id)sender {
    //if button is not selected, select
    
    if(![sender isSelected]){
        
        [sender setSelected:YES];
        NSString* timestamp = [(ViewController*)self.parentViewController getDate];
        currentEmotion = [self getAssociatedEmotion:sender];
        self.LabelSelectedEmotion.text = [NSString stringWithFormat:@"%@ selected. Tap again when the child stops showing %@.",    currentEmotion, currentEmotion];
        
        //disable other buttons
        [self disableButtonsExcept:sender];
        
        //write to csv file
        [self writeToFile:currentEmotion : timestamp:@""];
        
    }else{
        
        [sender setSelected:NO];
        NSString* timestamp = [(ViewController*)self.parentViewController getDate];
        currentEmotion = @"";
        
        //write to csv file
        [self writeToFile:currentEmotion :@"" :timestamp];
        //reset buttons
        [self resetEmotionButtons];
        
    }
}

- (IBAction)emotion1Tapped:(id)sender {
    
    [self emotionSelected:sender];
    [self selectIntensity];

    
    
}
- (IBAction)emotion2Tapped:(id)sender {
       [self emotionSelected:sender];
}
- (IBAction)emotion3Tapped:(id)sender {
        [self emotionSelected:sender];
}
- (IBAction)emotion4Tapped:(id)sender {
        [self emotionSelected:sender];
}
- (IBAction)emotion5Tapped:(id)sender {
        [self emotionSelected:sender];
}



-(void) showSliderPopup{
    UISlider *slider=[[UISlider alloc]initWithFrame:CGRectMake(10, 0, 300, 300)];
    CGAffineTransform trans=CGAffineTransformMakeRotation(M_PI_2);
    slider.transform=trans;
    slider.minimumValue=1;
    slider.maximumValue=100;
    slider.continuous=NO;
    [slider addTarget:self action:@selector(sliderChanhge:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *highlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100,100 )];
    highlabel.text = @"HIGH";
    
    
    popupView=[[UIView alloc]initWithFrame:CGRectMake(10, 10, 300, 350)]; // set popup frame your require position
    [popupView addSubview:slider];
    [popupView addSubview:highlabel];
    [self.view addSubview:popupView];
}

- (void)addLabelsToSlider:(UISlider*)slider{
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @"Very Low";
    [label sizeToFit];
    label.center = CGPointMake(5, slider.frame.size.height-label.frame.size.height/2 + 15);
    [slider addSubview:label];
    
    
    UILabel *highlabel = [[UILabel alloc] init];
    highlabel.font = [UIFont systemFontOfSize:10];
    highlabel.text = @"Very High";
    [highlabel sizeToFit];
    highlabel.center = CGPointMake((slider.frame.size.width/10)*10 - 5,  slider.frame.size.height-label.frame.size.height/2 + 15);
    [slider addSubview:highlabel];
    

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
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 250, 150)];

    ASValueTrackingSlider  *slider = [[ASValueTrackingSlider  alloc] initWithFrame:CGRectMake(tempView.bounds.size.width/2-100, tempView.bounds.size.width/2-10, 200, 10)];

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
//    
//    JMMarkSlider *firstSlider = [[JMMarkSlider alloc]initWithFrame:CGRectMake(tempView.bounds.size.width/2-100, tempView.bounds.size.width/2-10, 200, 10)];
//     firstSlider.markColor = [UIColor colorWithWhite:1 alpha:0.5];
//    firstSlider.markPositions = @[@10,@20,@30,@40,@50,@60,@70,@80,@90,@100];
//    firstSlider.markWidth = 1.0;
//    firstSlider.selectedBarColor = [UIColor greenColor];
//    firstSlider.unselectedBarColor = [UIColor blackColor];
    
    [tempView addSubview:slider];
    [alertView setContainerView:tempView];
    [alertView show];
}



-(UIView*)tickMarksViewForSlider:(UISlider*)slider View:(UIView *)view
{
    // set up vars
    int ticksDivider = (slider.maximumValue > 10) ? 10 : 1;
    int ticks = (int) slider.maximumValue / ticksDivider;
    int sliderWidth = 364;
    float offsetOffset = (ticks < 10) ? 1.7 : 1.1;
    offsetOffset = (ticks > 10) ? 0 : offsetOffset;
    float offset = sliderWidth / ticks - offsetOffset;
    float xPos = 0;
    
    // initialize view to return
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y+1,
                            slider.frame.size.width, slider.frame.size.height);
    view.backgroundColor = [UIColor clearColor];
    
    // make a UIImageView with tick for each tick in the slider
    for (int i=0; i < ticks; i++)
    {
        if (i == 0) {
            xPos += offset+5.25;
        }
        else
        {
            UIView *tick = [[UIView alloc] initWithFrame:CGRectMake(xPos, 3, 2, 16)];
            tick.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
            tick.layer.shadowColor = [[UIColor whiteColor] CGColor];
            tick.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            tick.layer.shadowOpacity = 1.0f;
            tick.layer.shadowRadius = 0.0f;
            [view insertSubview:tick belowSubview:slider];
            xPos += offset - 0.4;
        }
    }
    
    // return the view
    return view;
}

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



@end

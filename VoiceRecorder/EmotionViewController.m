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


@end

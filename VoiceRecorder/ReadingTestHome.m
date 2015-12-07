//
//  ReadingTestHome.m
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 11/11/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "ReadingTestHome.h"

@interface ReadingTestHome (){
    NSString* siblingName;
}

@end

@implementation ReadingTestHome

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // set the child name
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    siblingName = [defaults objectForKey:@"siblingname"];
    if(siblingName !=NULL){
       self.textfieldName.text = siblingName;
    }
    
    self.textfieldName.delegate =self;
    
    // set last taken timstamps
    
    NSString *lastTaken1 = [defaults objectForKey:@"Test1LastTaken"];
    NSString *lastTaken2 = [defaults objectForKey:@"Test2LastTaken"];
    
    if(lastTaken1 == NULL) lastTaken1 = @"Never";
    if (lastTaken2== NULL) lastTaken2 = @"Never";

    self.labelTest1LastTaken.text = [NSString stringWithFormat:@"Last taken : %@", lastTaken1];
    self.labelTest2LastTaken.text = [NSString stringWithFormat:@"Last taken : %@", lastTaken2];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)nameEntered:(id)sender {
    if(self.textfieldName.text != NULL && ![self.textfieldName.text  isEqual: @""]){
        //save the name to ns defaults to populate the field later
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:self.textfieldName.text forKey:@"siblingname"];
        [defaults synchronize];
    }
    
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"siblingname"]);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [self.textfieldName resignFirstResponder];
    return YES;
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    
        return UIInterfaceOrientationMaskPortrait;
}

@end

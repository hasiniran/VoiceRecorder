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
    NSArray* siblingNames;
}

@end

@implementation ReadingTestHome

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // set the child name
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    siblingName = [defaults objectForKey:@"siblingname"];
    
    siblingNames =[defaults arrayForKey:@"diagnosedUsers"];
    
//    
//    if(siblingName !=NULL){
//       self.textfieldName.text = siblingName;
//    }else{
//        [self.buttonTest1 setEnabled:NO];
//        [self.buttonTest2 setEnabled:NO];
//    }
//
    siblingName = [siblingNames objectAtIndex:0]; //default
    self.textfieldName.delegate =self;
    [[NSUserDefaults standardUserDefaults] setValue:siblingName forKey:@"siblingname"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
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


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    
    
    if ([[segue identifier] isEqualToString:@"ReadingTest1"]){

        ReadingTest1Controller *view = [segue destinationViewController];
        view.delegate = self;
    }else if ([[segue identifier] isEqualToString:@"ReadingTest2"]){
        ReadingTest2Controller *view =[segue destinationViewController];
        view.delegate = self;
    }else if ([[segue identifier] isEqualToString:@"ReadingTest3"]){
        ReadingTest3Controller *view = [segue destinationViewController];
        view.delegate = self;
    }
}

- (IBAction)nameEntered:(id)sender {
//    if(self.textfieldName.text != NULL && ![self.textfieldName.text  isEqual: @""]){
//        //save the name to ns defaults to populate the field later
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setValue:self.textfieldName.text forKey:@"siblingname"];
//        [defaults synchronize];
//        [self.buttonTest1 setEnabled:YES];
//        [self.buttonTest2 setEnabled:YES];
//
//    }else{
//        [self.buttonTest1 setEnabled:NO];
//        [self.buttonTest2 setEnabled:NO];
//    }
    //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"siblingname"]);
}


//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    //hide the keyboard
//    [self.textfieldName resignFirstResponder];
//    return YES;
//}

//to dismiss the keyboard when tapped anywhere
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    
//    [self.textfieldName endEditing:YES];
//    [self textFieldShouldReturn:self.textfieldName];
//}
//

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    
        return UIInterfaceOrientationMaskPortrait;
}


//uipickerview implementations


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [siblingNames count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [siblingNames objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

    siblingName = [siblingNames objectAtIndex:row];
    [[NSUserDefaults standardUserDefaults] setValue:siblingName forKey:@"siblingname"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"Helvetica" size:20]];
    }
    tView.text = [siblingNames objectAtIndex:row];
    
    return tView;
}

-(void)setLastTakenDate:(NSString *)date:(NSString *)test{
    
    if([test  isEqualToString:@"Test1"]){
        self.labelTest1LastTaken.text = [NSString stringWithFormat:@"Last taken : %@", date];
    }else if ([test isEqualToString:@"Test2"]){
       self.labelTest2LastTaken.text = [NSString stringWithFormat:@"Last taken : %@", date];
    }
}


@end

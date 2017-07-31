//
//  DevelopmentInterfaceViewController.m
//  VoiceRecorder
//
//  Created by Charles Shinaver on 2/15/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "DevelopmentInterfaceViewController.h"

@interface DevelopmentInterfaceViewController () <UITextFieldDelegate>{
    NSInteger usergroup;
    
}

@end

@implementation DevelopmentInterfaceViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
    
    //settings are alowed only for admin user
    
//    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Authorization Required" message:@"Enter the PIN to change settings" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
//    [alert setDelegate:self];
//    [alert show];
    [self enableSettings];

   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Quick fix to autherize changing settings.
 **/
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* pin= [alertView textFieldAtIndex:0].text;
    
    if ([pin isEqual:@"admin123"]) {
       //display settings
        [self enableSettings];
    }else{
        [self.textfieldDeviceName setEnabled:NO];
        [self.uiPickerStudyGroup setUserInteractionEnabled:NO];
        [self.buttonSetSettings setEnabled:NO];
        [self.audioMonitorThresholdTextField setEnabled:NO];
        [self.maxSilenceTimeTextField setEnabled:NO];
        [self.maxRecordTimeTextField setEnabled:NO];
        [self.maxMonitorTimeTextField setEnabled:NO];
        [self.minRecordTimeTextField setEnabled:NO];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)enableSettings {
    
    //set visible
    [self.textfieldDeviceName setEnabled:YES];
    [self.uiPickerStudyGroup setUserInteractionEnabled:YES];
    [self.buttonEditNameList setEnabled:YES];
    [self.buttonSetSettings setEnabled:YES];
    [self.audioMonitorThresholdTextField setEnabled:YES];
    [self.maxSilenceTimeTextField setEnabled:YES];
    [self.maxRecordTimeTextField setEnabled:YES];
    [self.maxMonitorTimeTextField setEnabled:YES];
    [self.minRecordTimeTextField setEnabled:YES];
    // Do any additional setup after loading the view.
    self.audioMonitorThresholdTextField.text = [NSString stringWithFormat:@"%.04lf", self.settings.AUDIOMONITOR_THRESHOLD];
    self.maxSilenceTimeTextField.text = [NSString stringWithFormat:@"%.02lf", self.settings.MAX_SILENCETIME];
    self.maxMonitorTimeTextField.text = [NSString stringWithFormat:@"%.02lf", self.settings.MAX_MONITORTIME];
    self.maxRecordTimeTextField.text = [NSString stringWithFormat:@"%.02lf", self.settings.MAX_RECORDTIME];
    self.minRecordTimeTextField.text = [NSString stringWithFormat:@"%.02lf", self.settings.MIN_RECORDTIME];
    
    [self.textfieldDeviceName setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"fullname"]];
    
    usergroup = [[NSUserDefaults standardUserDefaults] integerForKey:@"usergroup"];
    
    [self.uiPickerStudyGroup selectRow:(usergroup-1) inComponent:0 animated:NO];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.audioMonitorThresholdTextField)
    {
        self.settings.AUDIOMONITOR_THRESHOLD = textField.text.doubleValue;
    }
    else if (textField == self.maxSilenceTimeTextField)
    {
        self.settings.MAX_SILENCETIME = textField.text.doubleValue;
    }
    else if (textField == self.maxMonitorTimeTextField)
    {
        self.settings.MAX_MONITORTIME = textField.text.doubleValue;
    }
    else if (textField == self.maxRecordTimeTextField)
    {
        self.settings.MAX_RECORDTIME = textField.text.doubleValue;
    }
    else if (textField == self.minRecordTimeTextField)
    {
        self.settings.MIN_RECORDTIME = textField.text.doubleValue;
    }
    [textField resignFirstResponder];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    return YES;
}

- (IBAction)setDevelopmentSettings:(id)sender {
    //save user defaults
    [[NSUserDefaults standardUserDefaults] setInteger:usergroup forKey:@"usergroup"];
    [self.delegate addItemViewController:self passDevelopmentSettings:self.settings];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 move the screen upwards when displaying keyboard
 **/
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentResponder =textField;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,-100,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
        case 0:
            title = @"Group 1";
            break;
        case 1:
            title = @"Group 2";
            break;
    }
    return title;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    if (row == 0) {
        usergroup =1;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"usergroup"];
    }else if (row ==1){
        usergroup =2;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"usergroup"];
    }
    
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    }
    switch(row) {
        case 0:
            tView.text = @"Group 1";
            break;
        case 1:
            tView.text = @"Group 2";
            break;
    }

    return tView;
}

//to dismiss the keyboard when tapped anywhere
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.currentResponder endEditing:YES];

}
- (IBAction)backButtonTapped:(id)sender {
     [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)resignOnTap:(id)iSender {
    [self.currentResponder resignFirstResponder];
}


@end

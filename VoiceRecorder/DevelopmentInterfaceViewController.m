//
//  DevelopmentInterfaceViewController.m
//  VoiceRecorder
//
//  Created by Charles Shinaver on 2/15/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "DevelopmentInterfaceViewController.h"

@interface DevelopmentInterfaceViewController () <UITextFieldDelegate>

@end

@implementation DevelopmentInterfaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.audioMonitorThresholdTextField.text = [NSString stringWithFormat:@"%.02lf", self.settings.AUDIOMONITOR_THRESHOLD];
    self.maxSilenceTimeTextField.text = [NSString stringWithFormat:@"%.02lf", self.settings.MAX_SILENCETIME];
    self.maxMonitorTimeTextField.text = [NSString stringWithFormat:@"%.02lf", self.settings.MAX_MONITORTIME];
    self.maxRecordTimeTextField.text = [NSString stringWithFormat:@"%.02lf", self.settings.MAX_RECORDTIME];
    self.minRecordTimeTextField.text = [NSString stringWithFormat:@"%.02lf", self.settings.MIN_RECORDTIME];
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
    return NO;
}

- (IBAction)setDevelopmentSettings:(id)sender {

    

    [self.delegate addItemViewController:self passDevelopmentSettings:self.settings];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

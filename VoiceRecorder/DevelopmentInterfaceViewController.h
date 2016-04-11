//
//  DevelopmentInterfaceViewController.h
//  VoiceRecorder
//
//  Created by Charles Shinaver on 2/15/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DevelopmentSettings.h"

@class DevelopmentInterfaceViewController;
@protocol DevelopmentInterfaceViewControllerDelegate <NSObject>
- (void)addItemViewController:(DevelopmentInterfaceViewController *)controller passDevelopmentSettings:(DevelopmentSettings *)developmentSettings;
@end

@interface DevelopmentInterfaceViewController : UIViewController

@property (nonatomic, assign) id currentResponder;
@property (weak, nonatomic) IBOutlet UITextField *audioMonitorThresholdTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxSilenceTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxMonitorTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxRecordTimeTextField;

@property (weak, nonatomic) IBOutlet UITextField *minRecordTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *textfieldDeviceName;
@property (weak, nonatomic) IBOutlet UIPickerView *uiPickerStudyGroup;
@property (weak, nonatomic) IBOutlet UIButton *buttonEditNameList;

@property (weak, nonatomic) IBOutlet UIButton *buttonBack;

@property (weak, nonatomic) IBOutlet UIButton *buttonSetSettings;
- (IBAction)setDevelopmentSettings:(id)sender;
@property (nonatomic, weak) id <DevelopmentInterfaceViewControllerDelegate> delegate;
@property DevelopmentSettings *settings;



@end

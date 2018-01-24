//
//  AddUsersViewController.h
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 2/27/16.
//  Copyright (c) 2016 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddUsersViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableUndiagnosed;
@property (weak, nonatomic) IBOutlet UITableView *tableDiagnosed;

@property (weak, nonatomic) IBOutlet UITextField *textfieldUndiagnosed;
@property (weak, nonatomic) IBOutlet UITextField *textfieldDiagnosed;

@property (weak, nonatomic) IBOutlet UIButton *addUndiagnosed;
@property (weak, nonatomic) IBOutlet UIButton *addDiagnosed;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonEditUndiagnosedTable;
@property (weak, nonatomic) IBOutlet UIButton *buttonEditDiagnosedTable;


@end

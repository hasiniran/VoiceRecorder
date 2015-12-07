//
//  NamePickerController.h
//  VoiceRecorder
//
//  Created by Randy on 12/2/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol senddataProtocol <NSObject>

-(void)getSelectedChild:(NSString *)name;

@end

@interface NamePickerController : UIViewController

@property (weak, nonatomic) IBOutlet UIPickerView *uiPickerViewNames;
@property(nonatomic,assign)id delegate;

@end

//
//  NamePickerController.h
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 02/26/16.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol senddataProtocol <NSObject>

-(void)getSelectedChild:(NSSet *)name;

@end

@interface NamePickerController : UIViewController
//
//@property (weak, nonatomic) IBOutlet UIPickerView *uiPickerViewNames;
@property(nonatomic,assign)id delegate;
@property(nonatomic, assign)NSInteger userType; // 1 for undiagnosed, 2 for diagnosed user catagory

@end

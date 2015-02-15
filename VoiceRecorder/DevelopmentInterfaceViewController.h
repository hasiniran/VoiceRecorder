//
//  DevelopmentInterfaceViewController.h
//  VoiceRecorder
//
//  Created by Charles Shinaver on 2/15/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DevelopmentInterfaceViewController;
@protocol DevelopmentInterfaceViewControllerDelegate <NSObject>
- (void)addItemViewController:(DevelopmentInterfaceViewController *)controller passDevelopmentSettings:(NSDictionary *)developmentSettings;
@end

@interface DevelopmentInterfaceViewController : UIViewController
- (IBAction)setSettings:(id)sender;
@property (nonatomic, weak) id <DevelopmentInterfaceViewControllerDelegate> delegate;

@end

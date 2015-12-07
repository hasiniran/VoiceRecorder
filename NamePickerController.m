//
//  NamePickerController.m
//  VoiceRecorder
//
//  Created by Randy on 12/2/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "NamePickerController.h"

@interface NamePickerController (){
    NSArray* _names;
    NSString *selectedName;
}

@end

@implementation NamePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.uiPickerViewNames.delegate = self;
    self.uiPickerViewNames.dataSource = self;
    _names = @[@"Elizabeth", @"Zane", @"Zaybriella"];
    selectedName = @"Elizabeth";
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
}f
*/


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
        case 0:
            title = @"Elizabeth";
            break;
        case 1:
            title = @"Zane";
            break;
        case 2:
            title = @"Zaybriella";
            break;
    }
    return title;
}

//- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    
//    //Here, like the table view you can get the each section of each row if you've multiple sections
//    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
//    
//    //Now, if you want to navigate then;
//    // Say, OtherViewController is the controller, where you want to navigate:
//    OtherViewController *objOtherViewController = [OtherViewController new];
//    [self.navigationController pushViewController:objOtherViewController animated:YES];
//    
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    selectedName = [_names objectAtIndex:row];
    
}

@synthesize delegate;
-(void)viewWillDisappear:(BOOL)animated
{
    [delegate getSelectedChild:selectedName
     ];
    
}

- (IBAction)selectTapped:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    //    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
}


- (NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
}
@end

//
//  DevelopmentInterfaceViewController.m
//  VoiceRecorder
//
//  Created by Charles Shinaver on 2/15/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "DevelopmentInterfaceViewController.h"

@interface DevelopmentInterfaceViewController ()

@end

@implementation DevelopmentInterfaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)setSettings:(id)sender {
    NSArray *keys = [[NSArray alloc]initWithObjects:@"test", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:@"Test thing", nil];
    NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    [self.delegate addItemViewController:self passDevelopmentSettings:myDictionary];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

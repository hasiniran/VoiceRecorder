//
//  NamePickerController.m
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 02/26/16.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "NamePickerController.h"

@interface NamePickerController (){
    NSArray* _names;
    NSMutableSet* selectedNames;
}

@end

@implementation NamePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    _names = [[NSUserDefaults standardUserDefaults] arrayForKey:@"diagnosedUsers"];

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




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_names count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_names objectAtIndex:indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(selectedNames == NULL){
        selectedNames = [[NSMutableSet alloc] init];
    }
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedNames removeObject:[_names objectAtIndex:indexPath.row]];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedNames addObject:[_names objectAtIndex:indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell* uncheckCell = [tableView
//                                    cellForRowAtIndexPath:indexPath];
//    uncheckCell.accessoryType = UITableViewCellAccessoryNone;
}



@synthesize delegate;
-(void)viewWillDisappear:(BOOL)animated
{
  [delegate getSelectedChild:selectedNames];
    
}

- (IBAction)backTapped:(id)sender {
    
    if(selectedNames.count > 0){
    
        [self dismissViewControllerAnimated:NO completion:nil];
        //    [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please select names of children you wish to record." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}


- (NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
}
@end

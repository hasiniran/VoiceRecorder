//
//  AddUsersViewController.m
//  VoiceRecorder
//
//  Created by Hasini Yatawatte on 2/27/16.
//  Copyright (c) 2016 University of Notre Dame. All rights reserved.
//

#import "AddUsersViewController.h"

@interface AddUsersViewController (){
    NSMutableArray *diagnosedUsers;
    NSMutableArray *undiagnosedUsers;
}

@end

@implementation AddUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableUndiagnosed setTag:0];
    [self.tableDiagnosed setTag:1];
    [self.textfieldUndiagnosed setTag:2];
    [self.textfieldDiagnosed setTag:3];
    [self.buttonEditUndiagnosedTable setTag:4];
    [self.buttonEditDiagnosedTable setTag:5];
    
    undiagnosedUsers = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"undiagnosedUsers"]];
    diagnosedUsers = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"diagnosedUsers"]];
    
    [self.textfieldUndiagnosed setDelegate:self];
    [self.textfieldDiagnosed setDelegate:self];
    [self.tableDiagnosed sizeToFit];
    [self.tableUndiagnosed sizeToFit];
    
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
- (IBAction)backButtonTapped:(id)sender {
      [self dismissViewControllerAnimated:NO completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(tableView == self.tableUndiagnosed){
        return undiagnosedUsers.count;
    }else if (tableView == self.tableDiagnosed){
        return diagnosedUsers.count;
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    NSArray *dataArray;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    dataArray = (tableView == self.tableUndiagnosed) ? undiagnosedUsers:diagnosedUsers;

    cell.textLabel.text = [dataArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:30.0];
    
    return cell;
}





-(IBAction)editTable:(id)sender{
    UITableView *table;
    if([sender tag] == 4) {
        table = self.tableUndiagnosed;
    }else if ([sender tag] == 5){
        table = self.tableDiagnosed;
    }
    
    if(table.editing)
    {
        [table setEditing:NO animated:NO];
        [table reloadData];
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else
    {
        [table setEditing:YES animated:YES];
        [table reloadData];
        [sender setTitle:@"Save" forState:UIControlStateNormal];
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray* dataArray = (tableView == self.tableUndiagnosed) ? undiagnosedUsers:diagnosedUsers;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dataArray removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        
        NSSet *nameSet;
        
        if(tableView == self.tableUndiagnosed) {
            nameSet = [[NSSet alloc] initWithArray:dataArray];
            [[NSUserDefaults standardUserDefaults] setObject:[nameSet allObjects] forKey:@"undiagnosedUsers"];
        }else if(tableView == self.tableDiagnosed){
            nameSet = [[NSSet alloc] initWithArray:dataArray];
            [[NSUserDefaults standardUserDefaults] setObject:[nameSet allObjects] forKey:@"diagnosedUsers"];
        }
        
    }
}

- (IBAction)addUndiagnosedTapped:(id)sender {
    if(self.textfieldUndiagnosed.text.length > 0){
        [undiagnosedUsers addObject:self.textfieldUndiagnosed.text];
        [self.tableUndiagnosed reloadData];
        NSSet *nameSet = [[NSSet alloc] initWithArray:undiagnosedUsers];
        [[NSUserDefaults standardUserDefaults] setObject:[nameSet allObjects] forKey:@"undiagnosedUsers"];
    }
}


- (IBAction)addDiagnosedTapped:(id)sender {
    if(self.textfieldDiagnosed.text.length > 0){
        [diagnosedUsers addObject:self.textfieldDiagnosed.text];
        [self.tableDiagnosed reloadData];
        [self.tableDiagnosed sizeToFit];
        [[NSUserDefaults standardUserDefaults] setObject:[[[NSSet alloc] initWithArray:diagnosedUsers] allObjects] forKey:@"diagnosedUsers"];
    }
}


- (IBAction)textfieldEditDidBegin:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,-50,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
}

//to dismiss the keyboard when tapped anywhere
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textfieldUndiagnosed endEditing:YES];
    [self.textfieldDiagnosed endEditing:YES];
    [self textFieldShouldReturn:self.textfieldUndiagnosed];
    [self textFieldShouldReturn:self.textfieldDiagnosed];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    (textField==self.textfieldUndiagnosed) ? [self.textfieldUndiagnosed resignFirstResponder]:[self.textfieldDiagnosed resignFirstResponder];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   
}

- (CGFloat)   tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 40;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView.editing){
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


@end

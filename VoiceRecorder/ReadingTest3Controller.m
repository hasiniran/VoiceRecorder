//
//  UIViewController+ReadingTest3Controller.m
//  VoiceRecorder
//
//  Created by Randy on 9/12/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "ReadingTest3Controller.h"

@interface ReadingTest3Controller(){
        NSUserDefaults *defaults;
}

@end

@implementation ReadingTest3Controller

- (void)viewDidLoad
{
    
    // create the data model
    
    self.pageTitles = @[@"House", @"Tree", @"Window",
                        @"Telephone", @"Cup", @"Knife", @"Spoon",
                        @"Girl", @"Ball",
                        @"Wagon",@"Shovel",
                        @"Monkey", @"Zipper", @"Scissors", @"Duck",@"Quack", @"Yellow",
                        @"Vacuum",
                        @"Watch", @"Plane", @"Swimming", @"Watches", @"Lamp",@"Car",@"Blue",
                        @"Rabbit", @"Carrot", @"Orange",
                        @"Fishing", @"Chair", @"Feather",
                        @"Pencil", @"Bathtub",@"Bath",
                        @"Ring",@"Finger",@"Thumb",
                        @"Jumping", @"Pajamas", @"Flowers", @"Brush", @"Drum", @"Frog", @"Green",
                        @"Clown", @"Balloons",
                        @"Crying", @"Glasses", @"Slide", @"Stars",@"Five"];
    
    self.pageImages = @[@"house.png", @"tree.png", @"window.png",
                        @"telephone.png", @"cup.png",@"knife.png", @"spoon.png",
                        @"girl.png", @"ball.png",
                        @"wagon.png",@"shovel.png",
                        @"monkey.png", @"zipper.png", @"scissors.png", @"duck.png",@"quack.png", @"yellow.png",
                        @"vacuum.png",
                        @"watch.png", @"plane.png", @"swimming.png", @"watches.png", @"lamp.png",@"car.png",@"blue.png",
                        @"rabbit.png", @"carrot.png", @"orange.png",
                        @"fishing.png", @"chair.png", @"feather.png",
                        @"pencil.png", @"bathtub.png",@"bath.jpg",
                        @"ring.png",@"fingers.png",@"thumb.png",
                        @"jump.png", @"pajamas.png", @"flowers.png", @"brush.png", @"drum.png", @"frog.png", @"green.jpg",
                        @"clown.png", @"balloons.png",
                        @"crying.png", @"glasses.png", @"slide.png", @"stars.png",@"five.png"];
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
}


- (BOOL)shouldAutorotate {
    return NO;
}
- (IBAction)helpButtonTapped:(id)sender {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Reading Test Instructions" message:@"1. Click Record to start recording. \n 2. Read the word displayed on the screen aloud. \n 3. Swipe to go the next word. \n 4. Click stop when the test is finished. " delegate:nil cancelButtonTitle:Nil otherButtonTitles:@"OK" , nil];
    alert.cancelButtonIndex=1;
    [alert setDelegate:self];
    [alert show];
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

}

- (NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
}
@end

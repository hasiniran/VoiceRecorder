//
//  UIViewController+StoryViewController.m
//  VoiceRecorder
//
//  Created by Randy on 9/9/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "StoryViewController.h"

@interface StoryViewController(){
    NSInteger numberOfPages;
}

@end



@implementation StoryViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self->numberOfPages = 5;
    
    
    
//    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
//    
//    self.pageController.dataSource = self;
//    [[self.pageController view] setFrame:[[self view] bounds]];
//    
//    StoryPageViewController *initialViewController = [self viewControllerAtPage:0];
//    
//    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
//    
//    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
//    
//    [self addChildViewController:self.pageController];
//    [[self view] addSubview:[self.pageController view]];
//    [self.pageController didMoveToParentViewController:self];
    
    
    
    _pageTitles = @[@"Over 200 Tips and Tricks", @"Discover Hidden Features", @"wewewewew"];
    _pageImages = @[@"readingtest_0.jpg", @"readingtest_0.jpg", @"readingtest_0.jpg"];
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    
//    NSInteger pageNumber = [(StoryPageViewController *)viewController pageNumber];
//    
//    if(pageNumber == 0){
//        return nil;
//    }
//    
//    pageNumber--;
//    
//    return [self viewControllerAtPage: pageNumber];
    
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
    
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
//    
//    NSInteger pageNumber = [(StoryPageViewController *)viewController pageNumber];
//    
//    
//    pageNumber++;
//    
//    if (pageNumber == numberOfPages) {
//        return nil;
//    }
//    
//    return [self viewControllerAtPage:pageNumber];
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
    
}


//-(StoryPageViewController*)viewControllerAtPage:(NSUInteger)pagenumber{
//    
//    StoryPageViewController* pageViewController = [[StoryPageViewController alloc] initWithNibName:@"StoryPageViewController" bundle:nil];
//    pageViewController.pageNumber = pagenumber;
//    return pageViewController;
//    
//}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}



- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}


@end

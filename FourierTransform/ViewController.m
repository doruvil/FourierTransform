//
//  ViewController.m
//  FourierTransform
//
//  Created by Lion User on 26/11/2013.
//  Copyright (c) 2013 Lion User. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

@synthesize allViewControllers;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UIPageControl *pageControl = [UIPageControl appearanceWhenContainedIn:[ViewController class], nil];
	
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
      
    MainScreenViewController *mainScreenController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainScreenViewController"];
    AmplitudeViewController *amplitudeController = [self.storyboard instantiateViewControllerWithIdentifier:@"AmplitudeViewController"];
    PhaseViewController *phaseController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhaseViewController"];    
    FourierLogViewController *fourierLogController = [self.storyboard instantiateViewControllerWithIdentifier:@"FourierLogViewController"];
    ImageAfterInvFFTViewController *originalImageWithGrayscale = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageAfterInvFFTViewController"];
    

    self.allViewControllers  = [NSArray arrayWithObjects:mainScreenController,amplitudeController,phaseController,fourierLogController,originalImageWithGrayscale, nil];
    NSArray *viewControllers = [NSArray arrayWithObject:[allViewControllers objectAtIndex:0]];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    [self.pageController setEditing:FALSE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIViewController *)getViewControllerAtIndex:(NSUInteger)index
{
    return (UIViewController *)[allViewControllers objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    MainScreenViewController *sharedStore = [MainScreenViewController sharedStore];
    if (!sharedStore.isFFTApplied) {
        return nil;
    }
    
    NSUInteger pageIndex = [allViewControllers indexOfObject:viewController];
    
    if (pageIndex == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    pageIndex--;
    
    return [self getViewControllerAtIndex:pageIndex];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
        
    NSUInteger pageIndex = [allViewControllers indexOfObject:viewController];
    pageIndex++;
    
    if (pageIndex == 5) {
        return nil;
    }
    return [self getViewControllerAtIndex:pageIndex];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 5;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

@end

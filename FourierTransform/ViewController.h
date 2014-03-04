//
//  ViewController.h
//  FourierTransform
//
//  Created by Lion User on 26/11/2013.
//  Copyright (c) 2013 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPChildViewController.h"
#import "MainScreenViewController.h"
#import "AmplitudeViewController.h"
#import "PhaseViewController.h"
#import "FourierLogViewController.h"
#import "ImageAfterInvFFTViewController.h"


@interface ViewController : UIViewController <UIPageViewControllerDataSource>
{
    //int pageIndex;
}

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSArray *allViewControllers;



@end

//
//  AmplitudeViewController.m
//  FourierTransform
//
//  Created by Lion User on 27/11/2013.
//  Copyright (c) 2013 Lion User. All rights reserved.
//

#import "AmplitudeViewController.h"

@interface AmplitudeViewController ()

@end

@implementation AmplitudeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadCorrectImage];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [self loadCorrectImage];
}

- (void)loadCorrectImage
{
    MainScreenViewController *sharedStore = [MainScreenViewController sharedStore];   
    if (!sharedStore.isFFTApplied) {
        self.amplitudeImageView.image = [UIImage imageNamed: @"question_mark.jpg"];
    } else {
        self.amplitudeImageView.image = sharedStore.fftAmplitudeImage;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  MainScreenViewController.h
//  FourierTransform
//
//  Created by Lion User on 27/11/2013.
//  Copyright (c) 2013 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Pixels.h"

typedef struct {
    double real;
    double imag;
}COMPLEX_NUMBER;

@interface MainScreenViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImage *originalImage;
    int imgWidth,imgHeight;
    COMPLEX_NUMBER *complexValuesFromImage;
        
}

@property (nonatomic, strong) UIImagePickerController *imgPicker;
@property (weak, nonatomic) IBOutlet UIImageView *originalImageView;
@property (strong, nonatomic) UIImage *resultImage;
@property (strong, nonatomic) UIImage *resultMagnitudeImage;

@property (assign) BOOL isFFTApplied;
@property (assign) COMPLEX_NUMBER *complexFFTValues;
@property (assign) COMPLEX_NUMBER *complexAfterInvFFTValues;

@property (strong, nonatomic) UIImage *fftAmplitudeImage;
@property (strong, nonatomic) UIImage *fftPhaseImage;
@property (strong, nonatomic) UIImage *fftLogImage;



+ (MainScreenViewController *)sharedStore;
- (IBAction)applyFFTAction:(id)sender;
@end

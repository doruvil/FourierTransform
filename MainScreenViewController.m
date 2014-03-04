//
//  MainScreenViewController.m
//  FourierTransform
//
//  Created by Lion User on 27/11/2013.
//  Copyright (c) 2013 Lion User. All rights reserved.
//

#import "MainScreenViewController.h"
#import "GKImagePicker.h"


static MainScreenViewController *sharedStore = nil;

@interface MainScreenViewController ()<GKImagePickerDelegate>

  @property (nonatomic, strong) GKImagePicker *imagePicker;
  @property (nonatomic, strong) UIPopoverController *popoverController;


@end

@implementation MainScreenViewController
@synthesize imgPicker,originalImageView;
@synthesize imagePicker;
@synthesize popoverController;


+ (MainScreenViewController *) sharedStore {
    @synchronized(self) {
        if(sharedStore == nil) {
            sharedStore = [[self alloc] init];
        }
    }return sharedStore;
}

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
    MainScreenViewController *sharedStore = [MainScreenViewController sharedStore];
    sharedStore.isFFTApplied = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)applyFFTAction:(id)sender {
    COMPLEX_NUMBER *complexFFFResult = [self FFT2DUsingComplexInput:complexValuesFromImage usingWidth:imgWidth usingHeight:imgHeight usingDirection:TRUE];

    [self FFTPlotUsingShiftedFFTValues:[self FFTShiftUsing:complexFFFResult]];
    
    COMPLEX_NUMBER *complexPixelValues = [self inverseFFTUsingFFTResult:complexFFFResult];
    
    
    unsigned char *outputPixelsOriginalImageData = (unsigned char *)malloc(sizeof(unsigned char) * imgWidth * imgHeight);
    for (int i = 0; i < imgWidth; i++){
        for (int j = 0;  j < imgHeight; j++) {
            COMPLEX_NUMBER exactValueComplex = complexPixelValues[(i * (imgWidth)) + j];
            unsigned char pixelValue = (unsigned char)exactValueComplex.real;
           
            outputPixelsOriginalImageData[(i * (imgWidth)) + j] = pixelValue;
        }
    }
    UIImage *resultImageAfterInvFFT = [self createImageFromPixels:outputPixelsOriginalImageData];
    
    MainScreenViewController *sharedStore = [MainScreenViewController sharedStore];
    sharedStore.isFFTApplied = TRUE;
    sharedStore.complexFFTValues = complexFFFResult;
    sharedStore.complexAfterInvFFTValues = complexPixelValues;
    sharedStore.resultImage = resultImageAfterInvFFT;
}

- (UIImage *)createImageFromPixels:(unsigned char *)inPixelsData
{
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(inPixelsData,
                                                 imgWidth,
                                                 imgHeight,
                                                 8,
                                                 imgWidth,
                                                 grayColorSpace,
                                                 kCGImageAlphaNone);
    

    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage * resultImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(grayColorSpace);
    CGContextRelease(context);
    CGImageRelease(cgImage);
    return resultImage;
}

- (IBAction)selectPhoto:(UIButton *)sender
{
   
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.allowsEditing = YES;
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imgPicker animated:YES completion:NULL];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    MainScreenViewController *sharedStore = [MainScreenViewController sharedStore];
    sharedStore.isFFTApplied = FALSE;
    
    UIImage *chosenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.originalImageView.image = chosenImage;
    originalImage = chosenImage;
    
    imgWidth = (int)originalImage.size.width;
    imgHeight = (int)originalImage.size.height;
    
    COMPLEX_NUMBER *complexValuesInput = (COMPLEX_NUMBER *) malloc(imgWidth * imgHeight * sizeof(COMPLEX_NUMBER));

    unsigned char *grayPixels = [originalImage grayscalePixels];
    
    for (int i = 0; i < imgWidth; i++) {
        
        for (int j = 0; j < imgHeight; j++) {
            NSNumber *currentValue = [NSNumber numberWithUnsignedChar:grayPixels[(i * (imgWidth)) + j]];
            COMPLEX_NUMBER newComplexNumber;
            newComplexNumber.real = [currentValue doubleValue];
            newComplexNumber.imag = 0.0;
            complexValuesInput[(i * (imgWidth)) + j] = newComplexNumber;
        }
    }
    
    complexValuesFromImage = complexValuesInput;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - FFT methods

- (COMPLEX_NUMBER *)FFT2DUsingComplexInput:(COMPLEX_NUMBER *)inComplexInput usingWidth:(int)nx usingHeight:(int)ny usingDirection:(BOOL)dir
{
    
    int i,j;
    int m; // Power of 2 for current number of points
    double *real;
    double *imag;
    COMPLEX_NUMBER *complexFFTOutput = (COMPLEX_NUMBER *) malloc(imgWidth * imgHeight * sizeof(COMPLEX_NUMBER));
    
    complexFFTOutput = inComplexInput;
        
    real = (double *) malloc(nx * sizeof(double));
    imag = (double *) malloc(nx * sizeof(double));
    if (real == nil || imag == nil) {
        return nil;
    }
    
    for (j = 0;  j < ny; j++) {
        for (i = 0; i < nx; i++) {
           
            COMPLEX_NUMBER complexNumber = inComplexInput[(i * (imgWidth)) + j];
            real[i] = complexNumber.real;
            imag[i] = complexNumber.imag;

        }
        //Calling 1D FFT Function for Rows
        m = log2(nx);
        [self FFT1DusingDir:dir andSize:m andArrayX:real andArrayY:imag];
        for (i = 0; i < nx ; i ++) {
            COMPLEX_NUMBER newComplexNumber;
            newComplexNumber.real = real[i];
            newComplexNumber.imag = imag[i];
            complexFFTOutput[(i * (imgWidth)) + j] = newComplexNumber;
        }
    }
    
    free(real);
    free(imag);
    
    // Transform the coloumns
    real = (double *) malloc(ny * sizeof(double));
    imag = (double *) malloc(ny * sizeof(double));
    
    for (i = 0; i < nx; i++){
        for (j = 0;  j < ny; j++) {
            COMPLEX_NUMBER complexNumber = complexFFTOutput[(i * (imgWidth)) + j];
            real[j] = complexNumber.real;
            imag[j] = complexNumber.imag;
        }
        //Calling 1D FFT Function for Coloumns
        m = log2(ny);
        
        [self FFT1DusingDir:dir andSize:m andArrayX:real andArrayY:imag];
        for (j = 0; j < ny ; j ++) {
            COMPLEX_NUMBER newComplexNumber;
            newComplexNumber.real = real[j];
            newComplexNumber.imag = imag[j];
            complexFFTOutput[(i * (imgWidth)) + j] = newComplexNumber;
        }
    }

    free(real);
    free(imag);

    return complexFFTOutput;
}

- (COMPLEX_NUMBER *)inverseFFTUsingFFTResult:(COMPLEX_NUMBER *)inFourier
{
  
    COMPLEX_NUMBER *ComplexInvVFFT  = [self FFT2DUsingComplexInput:inFourier usingWidth:imgWidth usingHeight:imgHeight usingDirection:FALSE];
   
    return ComplexInvVFFT;
}

/*-------------------------------------------------------------------------
 This computes an in-place complex-to-complex FFT
 x and y are the real and imaginary arrays of 2^m points.
 dir = 1 gives forward transform
 dir = -1 gives reverse transform
 Formula: forward
           N-1
           ---
         1 \         - j k 2 pi n / N
 X(K) = --- > x(n) e                  = Forward transform
         N /                            n=0..N-1
           ---
           n=0
 
 Formula: reverse
         N-1
         ---
         \          j k 2 pi n / N
 X(n) =   > x(k) e                  = Inverse transform
         /                             k=0..N-1
         ---
         k=0
 */

- (void) FFT1DusingDir:(BOOL)dir andSize:(int)m andArrayX:(double *)inX andArrayY:(double *)inY
{
    long nn,i,i1,j,k,i2,l,l1,l2;
    double c1,c2,tx,ty,t1,t2,u1,u2,z;
    //Calculate the number of points
    nn = 1;
    for (i = 0; i < m ; i++) {
        nn *= 2;
    }
    // Do the bit reversal
    
    i2 = nn >> 1;
    j = 0;
    
    for (i = 0; i < nn - 1; i++) {
        if (i < j) {
            tx = inX[i];
            ty = inY[i];
            inX[i] = inX[j];
            inY[i] = inY[j];
            inX[j] = tx;
            inY[j] = ty;
        }
        k = i2;
        while (k <= j) {
            j -= k;
            k >>= 1;
        }
        j += k;
    }
    //Compute the FFT
    c1 = -1.0;
    c2 = 0.0;
    l2 = 1;
    for (l = 0; l < m; l++) {
        l1 = l2;
        l2 <<= 1;
        u1 = 1.0;
        u2 = 0.0;
        for (j = 0; j < l1; j++) {
            for (i = j;  i < nn; i += l2) {
                i1 = i + l1;
                t1 = (u1 * inX[i1]) - (u2 * inY[i1]);
                t2 = (u1 * inY[i1]) + (u2 * inX[i1]);
                inX[i1] = inX[i] - t1;
                inY[i1] = inY[i] - t2;
                inX[i] += t1;
                inY[i] += t2;
            }
            z = u1 * c1 - u2 * c2;
            u2 = u1 * c2 + u2 * c1;
            u1 = z;
        }
        c2 = sqrt((1.0 - c1)/2.0);
        if(dir)
        {
            c2 = -c2;
        }
        c1 = sqrt((1.0 + c1)/2.0);
    }
    //Scaling for forward transform
    if (dir) {
        for (i = 0; i < nn; i++) {
            inX[i] /= (double)nn;
            inY[i] /= (double)nn;
        }
    }
}

- (COMPLEX_NUMBER *)FFTShiftUsing:(COMPLEX_NUMBER *)inComplexFFTValues {
        
    COMPLEX_NUMBER *FFTValuesShifted = (COMPLEX_NUMBER *) malloc(imgWidth * imgHeight * sizeof(COMPLEX_NUMBER));
    
    for (int i = 0; i < imgWidth; i++)
        for (int j = 0; j < imgHeight; j++) {
            COMPLEX_NUMBER newlocalComplexNumber;
            newlocalComplexNumber.real = 0;
            newlocalComplexNumber.imag = 0;
            FFTValuesShifted[i * imgWidth + j] = newlocalComplexNumber;
        }
    
    for (int i = 0; i <= (imgWidth / 2)-1; i++) {
        for (int j = 0; j <= (imgHeight / 2)-1; j++) {

            FFTValuesShifted[(i + (imgWidth / 2)) * imgWidth + (j + imgHeight / 2)] = inComplexFFTValues[i * imgWidth + j];
            FFTValuesShifted[i * imgWidth + j] = inComplexFFTValues[(i + (imgWidth / 2)) * imgWidth + (j + (imgHeight / 2))];
            FFTValuesShifted[(i + (imgWidth / 2)) * imgWidth + j] = inComplexFFTValues[i * imgWidth + j + imgHeight / 2];
            FFTValuesShifted[i * imgWidth + (j + (imgHeight / 2))] = inComplexFFTValues[(i + (imgWidth / 2)) * imgWidth + j];
        }
    }
    return FFTValuesShifted;
}

- (int)indexInVectorUsingX:(int)inX andUsingY:(int)inY
{
    return inX * imgWidth + inY;
}

- (void)FFTPlotUsingShiftedFFTValues:(COMPLEX_NUMBER *)inShiftedComplexFFTValues
{
    int i,j;
    double *FFTLog = (double *) malloc(imgWidth * imgHeight * sizeof(double));
    double *FFTPhaseLog = (double *) malloc(imgWidth * imgHeight * sizeof(double));
    
    double *FourierMagnitude = (double *) malloc(imgWidth * imgHeight * sizeof(double));
    double *FourierPhase = (double *) malloc(imgWidth * imgHeight * sizeof(double));
    
    unsigned char *FFTNormalized = (unsigned char *) malloc(imgWidth * imgHeight * sizeof(unsigned char));
    unsigned char *FFTPhaseNormalized = (unsigned char *) malloc(imgWidth * imgHeight * sizeof(unsigned char));
    
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            COMPLEX_NUMBER exactValueComplex = inShiftedComplexFFTValues[(i * (imgWidth)) + j];
            FourierMagnitude[(i * (imgWidth)) + j] = [self magnitudeUsingComplexStruct:exactValueComplex];
            FourierPhase[(i * (imgWidth)) + j] = [self phaseUsingComplexStruct:exactValueComplex];
            FFTLog[(i * (imgWidth)) + j] = log(1 + FourierMagnitude[(i * (imgWidth)) + j]);
           
            FFTPhaseLog[(i * (imgWidth)) + j] = log(1 + ABS(FourierPhase[(i * (imgWidth)) + j]));
        }
    }
    
    double max = FourierMagnitude[0];
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            if (FourierMagnitude[(i * (imgWidth)) + j] > max) {
                max = FourierMagnitude[(i * (imgWidth)) + j];
            }
        }
    }
    
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            FourierMagnitude[(i * (imgWidth)) + j] = FourierMagnitude[(i * (imgWidth)) + j] / max;
        }
    }
    
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            
            FFTNormalized[(i * (imgWidth)) + j] = (unsigned char)(500 * FourierMagnitude[(i * (imgWidth)) + j]);
        }
    }
    
    // Create the amplitude FFT Image
    MainScreenViewController *sharedStore = [MainScreenViewController sharedStore];
    sharedStore.fftAmplitudeImage = [self createImageFromPixels:FFTNormalized];

    max = FFTLog[0];
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            if (FFTLog[(i * (imgWidth)) + j] > max) {
                max = FFTLog[(i * (imgWidth)) + j];
            }
        }
    }
    
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            FFTLog[(i * (imgWidth)) + j] = FFTLog[(i * (imgWidth)) + j] / max;
        }
    }
    
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            FFTNormalized[(i * (imgWidth)) + j] = (unsigned char)(2000 * FFTLog[(i * (imgWidth)) + j]);
        }
    }
    
    //  Create the log image
    sharedStore.fftLogImage = [self createImageFromPixels:FFTNormalized];
    
    FFTPhaseLog[0] = 0;
    max = FFTPhaseLog[imgWidth + 1];
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            if (FFTPhaseLog[(i * (imgWidth)) + j] > max) {
                max = FFTPhaseLog[(i * (imgWidth)) + j];
            }
        }
    }
    
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            FFTPhaseLog[(i * (imgWidth)) + j] = FFTPhaseLog[(i * (imgWidth)) + j] / max;
        }
    }
    
    for (i = 0; i < imgWidth; i++) {
        for (j = 0; j < imgHeight; j++) {
            FFTPhaseNormalized[(i * (imgWidth)) + j] = (unsigned char)(255 * FFTPhaseLog[(i * (imgWidth)) + j]);
        }
    }
    //  Create the phase image
    sharedStore.fftPhaseImage = [self createImageFromPixels:FFTPhaseNormalized];

}

- (double)magnitudeUsingComplexStruct:(COMPLEX_NUMBER)inNumber;
{
    return (double)sqrt((inNumber.real * inNumber.real) + (inNumber.imag * inNumber.imag));
}

- (double)phaseUsingComplexStruct:(COMPLEX_NUMBER)inNumber;
{
    return (double)atan(inNumber.imag / inNumber.real);
}

@end

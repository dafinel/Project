//
//  AugumentRealityViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 28/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "AugumentRealityViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreMotion/CoreMotion.h>
#import "AugmentedRealityController.h"

#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

@interface AugumentRealityViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ARDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CLLocationManager *manager;

@property (nonatomic, strong) AugmentedRealityController *arController;
@end

@implementation AugumentRealityViewController

 GMSPanoramaView *panoView_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    panoView_ = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    [panoView_ moveNearCoordinate:CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude)];
    [panoView_ sizeToFit];
    self.view = panoView_;
    
    if(!_arController) {
        _arController = [[AugmentedRealityController alloc] initWithView:[self view] parentViewController:self withDelgate:self];
    }
    
    [_arController setMinimumScaleFactor:0.5];
    [_arController setScaleViewsBasedOnDistance:YES];
    [_arController setRotateViewsBasedOnPerspective:YES];
    [_arController setDebugMode:NO];
    
}

-(void)didUpdateHeading:(CLHeading *)newHeading {
    
    [panoView_ setCamera:[GMSPanoramaCamera cameraWithHeading:newHeading.trueHeading pitch:0 zoom:1.0]];
    
}

-(void)didUpdateLocation:(CLLocation *)newLocation {
    
    
}

-(void)didUpdateOrientation:(UIDeviceOrientation)orientation {
    
}

#pragma mark - Core Motion

- (CMMotionManager *)motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    }
    return _motionManager;
}

#pragma mark - street view

- (IBAction)view:(UIButton *)sender {
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    uiipc.allowsEditing = YES;
    panoView_ = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    uiipc.view = panoView_;
   // uiipc.cameraOverlayView = panoView_;
    //self.view = panoView_;
    [panoView_ moveNearCoordinate:CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude)];
    [self presentViewController:uiipc animated:YES completion:NULL];
   
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    // when image is changed, we must delete files we've created (if any)
  
}

- (UIImage *)image
{
    return self.imageView.image;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

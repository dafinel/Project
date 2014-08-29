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

@interface AugumentRealityViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic ) CLLocationCoordinate2D coord;


@end

@implementation AugumentRealityViewController

 GMSPanoramaView *panoView_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CLLocationDegrees lat = self.location.latitude;
    CLLocationDegrees lon = self.location.longitude;
    self.coord = CLLocationCoordinate2DMake(lat,lon);
    
}

#pragma mark - Core Motion

- (CMMotionManager *)motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 0.1;
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
    //self.view = panoView_;
    [panoView_ moveNearCoordinate:CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude)];
    [self presentViewController:uiipc animated:YES completion:NULL];
   
    /*if (!self.motionManager.isDeviceMotionActive) {
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                    
                                                   // [panoView_ updateCamera:[GMSPanoramaCameraUpdate rotateBy:-motion.attitude.roll] animationDuration:0];
                                                    
                                                }];
    }
     */
    

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

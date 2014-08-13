//
//  LoginViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 08/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "LoginViewController.h"
#import "MyAplicationViewController.h"
#import "MapViewController.h"
#import "ForgotPasswordViewController.h"
#import <CoreLocation/CoreLocation.h>

#define kBaseURL @"http://localhost:3000/"
#define kLocations @"users"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic  ) IBOutlet UITextField *userTextinput;
@property (weak, nonatomic  ) IBOutlet UITextField *passwordTextInput;
@property (nonatomic, strong) NSString *userAndPassword;
@property (weak, nonatomic  ) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic        ) BOOL doSegue;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)importData {
    NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:self.userAndPassword]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setRequestCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSDictionary* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if ([responseArray count]) {
                User *user =[[User alloc] initWithDictionary:responseArray];
                self.user = user;
                [[NSUserDefaults standardUserDefaults]setValue:self.user._id forKey:@"_id"];
                [self.spinner stopAnimating];
                self.doSegue = YES;
            
            } else {
                //error;
            }
        }
    }];
    
   // NSURLSessionDataTask *dataTask = [session dataTaskWithURL: url];
    
    [dataTask resume];
    
}

#pragma mark - IBAction

- (IBAction)loginAction:(UIButton *)sender {
    self.doSegue = NO;
    [self.spinner startAnimating];
    self.userAndPassword = [NSString stringWithFormat:@"/%@/%@",self.userTextinput.text,self.passwordTextInput.text];
    [self importData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    while (!self.doSegue) {
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"forgotPassword"]) {
        if ([segue.destinationViewController isKindOfClass:[ForgotPasswordViewController class]]) {
           
        }
    } else if ([segue.identifier isEqualToString:@"login"]) {
     if ([segue.destinationViewController isKindOfClass:[UITabBarController class]]) {
         UITabBarController *tbvc = (UITabBarController *)segue.destinationViewController;
        if ([tbvc.viewControllers[0] isKindOfClass:[MapViewController class]]) {
            MapViewController *myvc = (MapViewController *)tbvc.viewControllers[0];
          //  CLLocation *location= [self.locationManager location];
            //self.user.curentLocation = [location coordinate];
            NSLog(@"login: %f, %f",self.user.curentLocation.latitude,self.user.curentLocation.longitude );
            myvc.user = self.user;
        
            
        }
     }
    }
}


@end

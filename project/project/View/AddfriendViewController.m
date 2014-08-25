//
//  AddfriendViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 19/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "AddfriendViewController.h"

//#define kBaseURL @"http://localhost:3000/"
#define kBaseURL @"http://nodews-locatemeserver.rhcloud.com"
#define kLocations @"users"

@interface AddfriendViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;

@end

@implementation AddfriendViewController

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)addfiendAction:(UIButton *)sender {
    NSString *udid = [[NSUserDefaults standardUserDefaults]stringForKey:@"_id"];
    udid = [NSString stringWithFormat:@"/%@/%@",udid,self.mailTextField.text];
    NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:udid]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { //5
        if (!error) {
            
        }
    }];
    [dataTask resume];
    
    
}


#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */


@end

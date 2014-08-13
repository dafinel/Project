//
//  SendLocation.m
//  project
//
//  Created by Andrei-Daniel Anton on 12/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "SendLocation.h"

#define kBaseURL @"http://localhost:3000/"
#define kLocations @"users"

@interface SendLocation()<CLLocationManagerDelegate>
@end

@implementation SendLocation


- (void)startMonitoring {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    NSMutableDictionary *c = [NSMutableDictionary dictionary];
    NSNumber *lat = [NSNumber numberWithDouble:(double)location.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:(double)location.coordinate.longitude];
    [c setObject:lat forKey:@"latitude"];
    [c setObject:lon forKey:@"latitude"];
    [self updateLocationOnServer:c];
    
    
}

- (void)updateLocationOnServer:(NSDictionary *)dic {
    NSUUID *u = [UIDevice currentDevice].identifierForVendor;
    NSString *udid = [NSString stringWithFormat:@"/%@",[u UUIDString]];
    NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:udid]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:NULL];
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { //5
        if (!error) {
           
        }
    }];
    [dataTask resume];
    
}

@end

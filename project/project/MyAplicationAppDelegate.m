//
//  MyAplicationAppDelegate.m
//  project
//
//  Created by Andrei-Daniel Anton on 07/08/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "MyAplicationAppDelegate.h"
#import "SendLocation.h"

#define kBaseURL @"http://localhost:3000/"
#define kLocations @"users"

@interface MyAplicationAppDelegate()<CLLocationManagerDelegate>

@end

@implementation MyAplicationAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
   // SendLocation *loc = [[SendLocation alloc] init];
    //[loc startMonitoring];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startMonitoringSignificantLocationChanges];
    // Override point for customization after application launch.
    return YES;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    NSMutableDictionary *c = [NSMutableDictionary dictionary];
    NSNumber *lat = [NSNumber numberWithDouble:(double)location.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:(double)location.coordinate.longitude];
    [c setObject:lat forKey:@"latitude"];
    [c setObject:lon forKey:@"longitude"];
    [self updateLocationOnServer:c];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startMonitoringSignificantLocationChanges];
    
}

- (void)updateLocationOnServer:(NSDictionary *)dic {
    NSString *udid = [[NSUserDefaults standardUserDefaults]stringForKey:@"_id"];
    udid = [NSString stringWithFormat:@"/%@",udid];
    NSLog(@"%@",udid);
    NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:udid]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
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

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

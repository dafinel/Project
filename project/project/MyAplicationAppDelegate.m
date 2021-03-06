//
//  MyAplicationAppDelegate.m
//  project
//
//  Created by Andrei-Daniel Anton on 07/08/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "MyAplicationAppDelegate.h"
#import "SendLocation.h"
#import <GoogleMaps/GoogleMaps.h>




//#define kBaseURL @"http://localhost:3000/"
#define kBaseURL @"http://nodews-locatemeserver.rhcloud.com"
#define kLocations @"users"
#define SEND_DATA @"send data"
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)

@interface MyAplicationAppDelegate()<CLLocationManagerDelegate,NSURLSessionDelegate>

@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic)UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong)NSURLSession *flickrDownloadSession;
@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();

@end

@implementation MyAplicationAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GMSServices provideAPIKey:@"AIzaSyDMKrOZXP3iBcLW33KSMsGMAP-FLEqy5gE"];
    
    self.locationTracker = [[LocationTracker alloc]init];
    [self.locationTracker startLocationTracking];
    
    //Send the best location to server every 60 seconds
    //You may adjust the time interval depends on the need of your app.
    NSTimeInterval time = 60.0;
	self.locationUpdateTimer =
    [NSTimer scheduledTimerWithTimeInterval:time
                                     target:self
                                   selector:@selector(updateLocation)
                                   userInfo:nil
                                    repeats:YES];
    
    return YES;
}

-(void)updateLocation {
    NSLog(@"updateLocation");
    
    [self.locationTracker updateLocationToServer];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}



@end

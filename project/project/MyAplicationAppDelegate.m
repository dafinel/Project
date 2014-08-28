//
//  MyAplicationAppDelegate.m
//  project
//
//  Created by Andrei-Daniel Anton on 07/08/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "MyAplicationAppDelegate.h"
#import "SendLocation.h"

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
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
  //  if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]){
        //[[LocationController sharedInstance] startMonitoringSignificantLocationChanges];
    //    return YES;
    //} else {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.activityType = CLActivityTypeOtherNavigation;
        [self.locationManager startMonitoringSignificantLocationChanges];
        
        self.locationManager = _locationManager;
        // Override point for customization after application launch.
        return YES;
    //}
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
     self.location = [locations lastObject];
  //  if (![self.location isEqual:self.lastLocation]) {
        self.lastLocation = self.location;
        NSMutableDictionary *c = [NSMutableDictionary dictionary];
        NSNumber *lat = [NSNumber numberWithDouble:(double)self.location.coordinate.latitude];
        NSNumber *lon = [NSNumber numberWithDouble:(double)self.location.coordinate.longitude];
        NSString *data = [NSString stringWithFormat:@"%@",[NSDate date]];
        [c setObject:lat forKey:@"latitude"];
        [c setObject:lon forKey:@"longitude"];
        [c setObject:data forKey:@"date"];
        [[NSUserDefaults standardUserDefaults] setObject:c forKey:@"locationToSend"];
    
        BOOL isInBackground = NO;
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        {
            isInBackground = YES;
        }
        if (isInBackground)
        {
            [self sendBackgroundLocationToServer:c];
        }
        else
        {
           [self updateLocationOnServer:c];
        }
        
   // }
    
    
}

-(void)sendBackgroundLocationToServer:(NSDictionary *)location {

    // REMEMBER. We are running in the background if this is being executed.
    // We can't assume normal network access.
    // bgTask is defined as an instance variable of type UIBackgroundTaskIdentifier
    
    // Note that the expiration handler block simply ends the task. It is important that we always
    // end tasks that we have started.
    
    _bgTask = [[UIApplication sharedApplication]
              beginBackgroundTaskWithExpirationHandler:
              ^{
                  [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                   }];
                  
                  // ANY CODE WE PUT HERE IS OUR BACKGROUND TASK
                  
                  // For example, I can do a series of SYNCHRONOUS network methods (we're in the background, there is
                  // no UI to block so synchronous is the correct approach here).
                  
                  // ...
                    [self startFlickrFetch:location];
                    NSLog(@"location to server");
    
                  // AFTER ALL THE UPDATES, close the task
                  
                  if (_bgTask != UIBackgroundTaskInvalid)
                  {
                      [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
                       _bgTask = UIBackgroundTaskInvalid;
                  }
}

- (void)updateLocationOnServer:(NSDictionary *)dic {
    NSString *udid = [[NSUserDefaults standardUserDefaults]stringForKey:@"_id"];
    udid = [NSString stringWithFormat:@"/%@",udid];
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

#pragma mark -Background update


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfig.allowsCellularAccess = NO;
    sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT; // want to be a good background citizen!
    
    NSLog(@"here");
    
    NSString *udid = [[NSUserDefaults standardUserDefaults]stringForKey:@"_id"];
    udid = [NSString stringWithFormat:@"/%@",udid];
    NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:udid]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"locationToSend"];
    NSData* data;
    if (dic) {
      data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:NULL];
    }
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                            completionHandler(UIBackgroundFetchResultNoData);
                                                        } else {
                                                                                                                    }
                                                    }];
    [task resume];

}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
     self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}


- (void)startFlickrFetch:(NSDictionary *)dic {
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            
            NSString *udid = [[NSUserDefaults standardUserDefaults]stringForKey:@"_id"];
            udid = [NSString stringWithFormat:@"/%@",udid];
            NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:udid]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = @"PUT";
            NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:NULL];
            request.HTTPBody = data;
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
          /*  NSURLSessionDataTask *task = [self.flickrDownloadSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { //5
                if (!error) {
                    
                }
            }];

            */
           // NSURLSessionUploadTask *task = [self.flickrDownloadSession uploadTaskWithRequest:request fromFile:url];
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithRequest:request];
            task.taskDescription = SEND_DATA;
            [task resume];
        } else {
            for (NSURLSessionUploadTask *task in uploadTasks) {
                [task resume];
            }
        }
    }];
}

- (NSURLSession *)flickrDownloadSession {
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken; // dispatch_once ensures that the block will only ever get executed once per application launch
        dispatch_once(&onceToken, ^{
            // notice the configuration here is "backgroundSessionConfiguration:"
            // that means that we will (eventually) get the results even if we are not the foreground application
            // even if our application crashed, it would get relaunched (eventually) to handle this URL's results!
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:SEND_DATA];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self    // we MUST have a delegate for background configurations
                                                              delegateQueue:nil];   // nil means "a random, non-main-queue queue"
        });
    }
    return _flickrDownloadSession;
    
}

#pragma mark - NSURLSessionDownloadDelegate

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    // we shouldn't assume we're the only downloading going on ...
    if ([downloadTask.taskDescription isEqualToString:SEND_DATA]) {
        // ... but if this is the Flickr fetching, then process the returned data
        
    }
}


- (void)flickrDownloadTasksMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            // we're doing this check for other downloads just to be theoretically "correct"
            //  but we don't actually need it (since we only ever fire off one download task at a time)
            // in addition, note that getTasksWithCompletionHandler: is ASYNCHRONOUS
            //  so we must check again when the block executes if the handler is still not nil
            //  (another thread might have sent it already in a multiple-tasks-at-once implementation)
            if (![downloadTasks count]) {  // any more Flickr downloads left?
                // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            } // else other downloads going, so let them call this method when they finish
        }];
    }
}


// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // we don't support resuming an interrupted download task
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // we don't report the progress of a download in our UI, but this is a cool method to do that with
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
    NSLog(@"Went to Background");
    // Need to stop regular updates first
    [self.locationManager stopUpdatingLocation];
    // Only monitor significant changes
    [self.locationManager startMonitoringSignificantLocationChanges];
    
}
- (void)willEnterForeground:(UIApplication *)application
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.locationManager startMonitoringSignificantLocationChanges];
}



@end

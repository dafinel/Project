//
//  User.m
//  project
//
//  Created by Andrei-Daniel Anton on 08/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "User.h"
#import "Location.h"


//#define kBaseURL @"http://localhost:3000/"
#define kBaseURL @"http://nodews-locatemeserver.rhcloud.com"
#define kLocations @"users"

#define safeSet(d,k,v) if (v) d[k] = v;

@implementation User

#pragma mark - JSON-ification

- (instancetype) initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        _name = dictionary[@"name"];
        _password= dictionary[@"password"];
        __id = dictionary[@"_id"];
        _mail = dictionary[@"mail"];
        _curentLocation = [self curentlocation:[[dictionary valueForKeyPath:@"curent_location.latitude"]doubleValue]
                andLongitude:[[dictionary valueForKeyPath:@"curent_location.longitude"] doubleValue]];
        //_friends = [NSMutableArray arrayWithArray:dictionary[@"friends"]];
        _friends = [self createFriendsList:dictionary[@"friends"]];
       // _locationHistory = [NSMutableArray arrayWithArray:dictionary[@"location_history"]];
        _locationHistory = [self createLocationHistory:dictionary[@"location_history"]];
        _cereri = [NSMutableArray arrayWithArray:dictionary[@"cereri"]];
        _meetings = [self createMeetings:dictionary[@"meetings"]];
    }
    return self;
}

- (CLLocationCoordinate2D) curentlocation:(double)lat andLongitude:(double)longit {
    CLLocationDegrees latitude = lat;
    CLLocationDegrees longitude = longit;
    CLLocationCoordinate2D c =CLLocationCoordinate2DMake(latitude, longitude);
    return c;
}

- (NSDictionary *)putCurrentLocation {
    NSMutableDictionary *c = [NSMutableDictionary dictionary];
    NSNumber *lat = [NSNumber numberWithDouble:(double)self.curentLocation.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:(double)self.curentLocation.longitude];
    [c setObject:lat forKey:@"latitude"];
    [c setObject:lon forKey:@"latitude"];
    
    return c;
}

- (NSMutableArray *)createMeetings:(NSArray *)array {
    NSMutableArray *meetings =[[NSMutableArray alloc]init];
    for (NSDictionary *dic in array) {
        NSMutableDictionary *dictionary = [dic mutableCopy];
        NSString *friendName = [self getFriendName:dic[@"with"]];
        [dictionary setObject:friendName forKey:@"with"];
        [meetings addObject:dictionary];
    }
    return meetings;
}

- (NSMutableArray *)createLocationHistory:(NSArray *)array {
    NSMutableArray *location = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in array) {
        Location *loc = [[Location alloc] init];
        loc.latitude = [[dic valueForKey:@"latitude"] doubleValue];
        loc.longitude = [[dic valueForKey:@"longitude"] doubleValue];
        loc.date = [NSString stringWithFormat: @"%@",[dic valueForKey:@"date"]];
        [location addObject: loc];
    }

    return location;
}

- (NSMutableArray *)createFriendsList:(NSArray *)array {
    NSMutableArray *friends =[NSMutableArray array];
    for (NSDictionary *dic in array) {
        if ([[dic valueForKey:@"accepted"]isEqualToString:@"yes"]) {
            [friends addObject:[dic valueForKey:@"_id"]];
        }
    }

    
    return friends;
}

- (NSDictionary*) toDictionary
{
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    safeSet(jsonable, @"name", self.name);
    safeSet(jsonable, @"password", self.password);
    safeSet(jsonable, @"mail", self.mail);
    safeSet(jsonable, @"friends", self.friends);
    safeSet(jsonable, @"location_history", self.locationHistory);
    safeSet(jsonable, @"curentlocation", [self putCurrentLocation]);
    safeSet(jsonable, @"_id", self._id);
    return jsonable;
}

- (NSString *)getFriendName:(NSString *)s {
   __block NSMutableString *friendName;
    __block BOOL ok = NO;
    NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:[NSString stringWithFormat:@"/%@",s]]];
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
                // dispatch_async(dispatch_get_main_queue(), ^{
                // User *user =[[User alloc] initWithDictionary:responseArray];
               
                friendName = responseArray[@"name"];
                ok = YES;
                // });
                
                
                
            } else {
                //error;
                
            }
        }
    }];
    
    [dataTask resume];
    while (!ok) {
        
    }
    return friendName;
}





@end

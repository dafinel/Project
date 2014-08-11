//
//  User.m
//  project
//
//  Created by Andrei-Daniel Anton on 08/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "User.h"

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
        _friends = [NSMutableArray arrayWithArray:dictionary[@"friends"]];
        _locationHistory = [NSMutableArray arrayWithArray:dictionary[@"location_history"]];
        
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




@end

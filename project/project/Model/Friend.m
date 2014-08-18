//
//  Friend.m
//  project
//
//  Created by Andrei-Daniel Anton on 18/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "Friend.h"
#import "User+Annotation.h"
#import "Location.h"

#define kBaseURL @"http://localhost:3000/"
#define kLocations @"users"

@interface Friend()<MKAnnotation>
@end

@implementation Friend


- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.location.latitude;
    coordinate.longitude = self.location.longitude;
    
    return coordinate;
}


@end

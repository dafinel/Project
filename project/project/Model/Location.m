//
//  Location.m
//  project
//
//  Created by Andrei-Daniel Anton on 18/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "Location.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface Location ()
@property (nonatomic, readwrite) NSString *title;
@end

@implementation Location

- (CLLocationCoordinate2D)coordinate {
    self.title = self.date;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.latitude;
    coordinate.longitude = self.longitude;
    
    return coordinate;
}



@end

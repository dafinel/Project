//
//  MeetingOnMapViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 26/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "MeetingOnMapViewController.h"
#import <MapKit/MapKit.h>

@interface MeetingOnMapViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *arrRoutePoints;
@property (nonatomic, strong) MKPolyline *objPolyline;
@end

@implementation MeetingOnMapViewController

#pragma mark - Instantiation

- (void) updateMapViewAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self.meetingLocation];
    [self.mapView showAnnotations:@[self.meetingLocation] animated:YES];
}

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    [self updateMapViewAnnotations];
    
    
    CLLocationCoordinate2D loc1 = self.mapView.userLocation.location.coordinate;
    Location *origin = [[Location alloc] init];
    origin.latitude = loc1.latitude;
    origin.longitude = loc1.longitude;
    
    // Destination Location.
    Location *destination = self.meetingLocation;
    self.arrRoutePoints = [self getRoutePointFrom:origin to:destination];
    [self drawRoute];
    [self centerMap];

}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    if(annotation != mapView.userLocation)
    {
        static NSString *defaultPinID = @"com.invasivecode.pin";
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.animatesDrop = YES;
    }
    else {
        [mapView.userLocation setTitle:@"I am here"];
    }
    
    return pinView;
}

#pragma mark - Draw route

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:204/255. green:45/255. blue:70/255. alpha:1.0];
    polylineView.lineWidth = 10.0;
    
    return polylineView;
}

/* This will get the route coordinates from the google api. */
- (NSArray *)getRoutePointFrom:(Location *)origin to:(Location *)destination
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", origin.latitude, origin.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", destination.latitude, destination.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError *error;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"points:\\\"([^\\\"]*)\\\"" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
    NSString *encodedPoints = [apiResponse substringWithRange:[match rangeAtIndex:1]];
    // NSString* encodedPoints = [apiResponse  stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

- (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedString
{
    [encodedString replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [encodedString length])];
    NSInteger len = [encodedString length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

- (void)drawRoute
{
    int numPoints = [_arrRoutePoints count];
    if (numPoints > 1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [_arrRoutePoints objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        self.objPolyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        
        [self.mapView addOverlay:_objPolyline];
        [self.mapView setNeedsDisplay];
    }
}

- (void)centerMap
{
    MKCoordinateRegion region;
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(int idx = 0; idx < _arrRoutePoints.count; idx++)
    {
        CLLocation* currentLocation = [_arrRoutePoints objectAtIndex:idx];
        
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat;
    region.span.longitudeDelta = maxLon - minLon;
    
    if(!region.center.latitude == 0) {
        [self.mapView setRegion:region animated:YES];
    }
}


@end

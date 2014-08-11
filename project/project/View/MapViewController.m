//
//  MapViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 08/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "MapViewController.h"
#import "User+Annotation.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

#pragma mark - Instantiation

- (void) updateMapViewAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self.user];
    [self.mapView showAnnotations:@[self.user] animated:YES];
}

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapViewAnnotations];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

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
#import <MapKit/MKAnnotationView.h>
#import "Notification.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController

#pragma mark - Instantiation

- (void) updateMapViewAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    //[self.mapView addAnnotation:self.user];
   // [self.mapView showAnnotations:@[self.user] animated:YES];
    self.mapView.showsUserLocation = YES;
}

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self updateMapViewAnnotations];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *view = nil;
    if(annotation != mapView.userLocation)
    {
        static NSString *defaultPinID = @"com.invasivecode.pin";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.animatesDrop = YES;
        view = pinView;
    }
    else {
        //[mapView.userLocation setTitle:@"I am here"];
        [mapView.userLocation setTitle:[NSString stringWithFormat:@"%@",mapView.userLocation.location ]];
    }
    
    return view;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKCircleRenderer *rendered = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
    rendered.strokeColor = [UIColor blueColor];
    rendered.lineWidth = 2.0;
    //rendered.fillColor = [UIColor blueColor];
    return rendered;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationUser
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.user = note.userInfo[USER];
                                                      [self updateMapViewAnnotations];
                                                  }];
    CLLocationCoordinate2D location =CLLocationCoordinate2DMake(47.157755, 27.604026);
    //
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:location radius:200.0];
    [self.mapView addOverlay:circle];
    
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

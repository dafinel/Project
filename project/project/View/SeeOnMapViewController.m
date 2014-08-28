//
//  SeeOnMapViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 18/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "SeeOnMapViewController.h"
#import <MapKit/MapKit.h>
#import "User+Annotation.h"
#import "Friend.h"
#import "Location.h"
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>

//#define kBaseURL @"http://localhost:3000/"
#define kBaseURL @"http://nodews-locatemeserver.rhcloud.com"
#define kLocations @"users"

@interface SeeOnMapViewController () <MKMapViewDelegate , UIAlertViewDelegate,MFMessageComposeViewControllerDelegate,AVAudioRecorderDelegate>
@property (weak, nonatomic  ) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *arrRoutePoints;
@property (nonatomic, strong) MKPolyline *objPolyline;
@property (nonatomic        ) BOOL alertshow;
@property (nonatomic, strong) NSDate *alertViewDate;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@end

@implementation SeeOnMapViewController

#pragma mark - Instantiation

- (void) updateMapViewAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.friends];
    [self.mapView showAnnotations:@[self.user] animated:YES];
}

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.alertshow = NO;
    //[self updateMapViewAnnotations];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
    
    
    CLLocationCoordinate2D loc1 = self.user.curentLocation;
    Location *origin = [[Location alloc] init];
    origin.latitude = loc1.latitude;
    origin.longitude = loc1.longitude;
    [self.mapView addAnnotation:origin];
    
    // Destination Location.
    Friend *fr = [[Friend alloc] init];
    fr = [self.friends firstObject];
    CLLocationCoordinate2D loc2;
    loc2.latitude = fr.location.latitude;
    loc2.longitude = fr.location.longitude;
    Location *destination = [[Location alloc] init];
    destination.latitude = loc2.latitude;
    destination.longitude = loc2.longitude;
    [self.mapView addAnnotation:destination];
    
   // if(_arrRoutePoints) // Remove all annotations
      //  [self.mapView removeAnnotations:[self.mapView annotations]];
    
    self.arrRoutePoints = [self getRoutePointFrom:origin to:destination];
    [self drawRoute];
    [self centerMap];
 
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:annot];
    [self.mapView showAnnotations:@[annot] animated:YES];
   
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    
    if(annotation != mapView.userLocation)
    {
        if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
            static NSString *defaultPinID = @"com.invasivecode.pin";
            pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
            if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                             initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            
            pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            
            CLLocationCoordinate2D loc1 = self.user.curentLocation;
            Location *origin = [[Location alloc] init];
            origin.latitude = loc1.latitude;
            origin.longitude = loc1.longitude;
            
            Friend *fr = [[Friend alloc] init];
            fr = [self.friends firstObject];
            [[NSUserDefaults standardUserDefaults] setValue:fr._id forKey:@"idPrietenToMeet"];
            CLLocationCoordinate2D loc2 = annotation.coordinate;
            Location *destination = [[Location alloc] init];
            destination.latitude = loc2.latitude;
            destination.longitude = loc2.longitude;
            destination.date = [NSString stringWithFormat:@"Meet with %@",fr.name];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:@(destination.latitude) forKey:@"lat"];
            [dic setValue:@(destination.longitude) forKey:@"lon"];
            [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"pinlocation"];
            
          
            self.arrRoutePoints = [self getRoutePointFrom:origin to:destination];
            [self drawRoute];
            [self centerMap];
            [self sendToServerMeeting];


        }
        static NSString *defaultPinID = @"com.invasivecode.pin";
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
    }
    else {
        [mapView.userLocation setTitle:@"I am here"];
    }
    
    return pinView;
}

- (void)sendToServerMeeting {
    
    //alert to enter date
    if (!self.alertshow) {
        self.alertshow = YES;
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Meeting" message:@"select date for meeting" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(av.bounds.origin.x+5, av.bounds.origin.y, av.bounds.size.width - 15, av.bounds.size.height - 20)];
        pickerView.datePickerMode = UIDatePickerModeDateAndTime;
        pickerView.hidden = NO;
        pickerView.date = [NSDate date];
        [pickerView addTarget:self action:@selector(updateTime:) forControlEvents:UIControlEventValueChanged];
        [pickerView sizeToFit];
        [av setValue:pickerView forKey:@"accessoryView"];
        [av show];

    }
    
    
    
}

- (void)updateTime:(id)sender {
     UIDatePicker *picker = (UIDatePicker*)sender;
     self.alertViewDate = picker.date;
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        
    }
    else if(buttonIndex == 1)
    {
        
        NSString *myid = [[NSUserDefaults standardUserDefaults]stringForKey:@"_id"];
        NSString *idprieten = [[NSUserDefaults standardUserDefaults]stringForKey:@"idPrietenToMeet"];
        NSDictionary *loc = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"pinlocation"];
        NSString * udid = [NSString stringWithFormat:@"/meet"];
        NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:udid]];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"PUT";
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:idprieten forKey:@"with"];
        [dic setValue:myid forKey:@"me"];
        [dic setValue:loc[@"lat"] forKey:@"lat"];
        [dic setValue:loc[@"lon"] forKey:@"lon"];
       // NSString *alertdate = [NSString stringWithFormat:@"%f",self.alertViewDate.timeIntervalSince1970];
        double alertdate = self.alertViewDate.timeIntervalSince1970;
        [dic setValue:@(alertdate) forKey:@"date"];
        
        NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:NULL];
        request.HTTPBody = data;
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { //5
            if (!error) {
                // dispatch_async(dispatch_get_main_queue(), ^{
                
                // });
            }
        }];
        [dataTask resume];
        self.alertshow = NO;
        
        [self showSMS:[self getNumberOfPersonWhoMeet:idprieten]];
        
        
    }
}

#pragma mark - Draw route on map

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

#pragma mark -Message delegate

- (IBAction)sendVoiceMessageAction:(UIBarButtonItem *)sender {
    UIAlertView *recordingAlert = [[UIAlertView alloc] initWithTitle:@"Recording" message:@"Recording the Message" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"ok",nil];
    [recordingAlert show];
    
    
}

- (void)showSMS:(NSString *)number {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"Meeting set. Please check! http://projectRunApp://"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:@[number]];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    
}

- (NSString *)getNumberOfPersonWhoMeet:(NSString *)personWhoMeet {
    __block NSString * number;
    __block BOOL ok = NO;
    NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:[NSString stringWithFormat:@"/%@",personWhoMeet]]];
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
                number = responseArray[@"number"];
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

    
    
    return number;
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

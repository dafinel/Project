//
//  SendLocation.h
//  project
//
//  Created by Andrei-Daniel Anton on 12/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SendLocation : NSObject

@property (nonatomic, strong) CLLocationManager *locationManager;

- (void)startMonitoring;

@end

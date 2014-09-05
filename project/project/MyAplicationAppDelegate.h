//
//  MyAplicationAppDelegate.h
//  project
//
//  Created by Andrei-Daniel Anton on 07/08/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "LocationTracker.h"
@interface MyAplicationAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (nonatomic, strong) CLLocationManager *locationManager;


@property LocationTracker * locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;

@end

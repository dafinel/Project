//
//  MyAplicationViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 07/08/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "MyAplicationViewController.h"
#import "Notification.h"

#define kBaseURL @"http://nodews-locatemeserver.rhcloud.com"
#define kLocations @"users"

@interface MyAplicationViewController ()

@end

@implementation MyAplicationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    /*[[NSNotificationCenter defaultCenter] addObserverForName:NotificationUser
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.user = note.userInfo[USER];
                                                  }];
*/
}


@end

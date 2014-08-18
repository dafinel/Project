//
//  FriendListTableViewController.h
//  project
//
//  Created by Andrei-Daniel Anton on 18/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Annotation.h"

@interface FriendListTableViewController : UITableViewController
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray *friends;
@end

//
//  User.h
//  project
//
//  Created by Andrei-Daniel Anton on 08/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *mail;
@property (nonatomic,       ) CLLocationCoordinate2D curentLocation;
@property (nonatomic, strong) NSMutableArray *friends; //array of NSStrings _id
@property (nonatomic, strong) NSMutableArray *locationHistory;
@property (nonatomic, strong) NSMutableArray *cereri;//array of NSDictionary

- (instancetype) initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) toDictionary;

@end

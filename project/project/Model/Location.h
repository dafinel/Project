//
//  Location.h
//  project
//
//  Created by Andrei-Daniel Anton on 18/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Location : NSObject <MKAnnotation>

@property (nonatomic,strong ) NSString *date;
@property (nonatomic ) double latitude;
@property (nonatomic ) double longitude;

@end

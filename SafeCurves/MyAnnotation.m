//
//  MYAnnotation.m
//  ITSMapwithSPeed
//
//  Created by Student on 1/24/14.
//  Copyright (c) 2014 South Dakota State University. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation
- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = self.latitude;
    theCoordinate.longitude = self.longitude;
    return theCoordinate;
}

-(id)initWithLat:(float)lat longitude:(float)lon title:(NSString *)restaurantTitle address:(NSString *)restaurantAddress category:(NSString *)restaurantCategory
{
    self = [super init];
    if ( self != nil)
    {
        self.latitude=lat;
        self.longitude=lon;
        self.address=restaurantAddress;
        self.title=restaurantTitle;
        self.category=restaurantCategory;
    }
	return self;
}

@end


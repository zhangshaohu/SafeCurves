//
//  MYAnnotation.h
//  ITSMapwithSPeed
//
//  Created by Student on 1/24/14.
//  Copyright (c) 2014 South Dakota State University. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject<MKAnnotation>
@property  (nonatomic) float  longitude;
@property  (nonatomic) float latitude;
@property (nonatomic, strong) NSString *locDesc;
@property (nonatomic, strong) NSString *curveType;
@property (nonatomic, strong) NSString *curveDir;
@property (nonatomic) float locSpeedLimit;
@property (nonatomic) float parsedistance;

-(id)initWithLat:(float)lat longitude:(float)lon title:(NSString *)restaurantTitle address:(NSString *)restaurantAddress category:(NSString *)restaurantCategory;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
               



@end

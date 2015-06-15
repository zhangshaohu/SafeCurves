//
//  ViewController.h
//  SafeCurves
//
//  Created by Student on 5/16/14.
//  Copyright (c) 2014 CLOSET. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
@class MyAnnotation;

//Ble
#import "BLE.h"
#import "RBLDetailViewController.h"


@interface ViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,BLEDelegate, RBLDetailViewControllerDelegate>
{
    BLE *bleShield;
    bool isFindingLast;
}
//@property (strong, nonatomic) IBOutlet UILabel *mylatitude;
//@property (strong, nonatomic) IBOutlet UILabel *mylongitude;
@property (weak, nonatomic) IBOutlet MKMapView *myMap;
@property (strong, nonatomic) IBOutlet UILabel *myspeed;
@property (strong, nonatomic) IBOutlet UILabel *mydistance;
@property (strong, nonatomic) IBOutlet UILabel *mytime;

@property (strong, nonatomic) CLLocationManager *mylocation;
@property (nonatomic, readonly) CLLocationDistance distance;
//@property (nonatomic, readonly) CLLocation*userLocation;
@property (nonatomic, strong) MyAnnotation *event;



//ble
@property (strong,nonatomic) NSMutableArray *mDevices;
@property (strong,nonatomic) NSString *lastUUID;

- (IBAction)locateme:(UIButton *)sender;
-(NSMutableArray *)loadAndParseWithFilePath:(NSString *)filePath;
- (void)greenLeftTurn;
- (void)greenRightTurn;
- (void)redLeftTurn;
- (void)redRightTurn;
- (void)halfredLeftTurn;
- (void)halfredRightTurn;
- (void)qredLeftTurn;
- (void)qredRightTurn;
@end

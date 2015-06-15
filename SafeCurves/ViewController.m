//
//  ViewController.m
//  SafeCurves
//
//  Created by Student on 5/16/14.
//  Copyright (c) 2014 CLOSET. All rights reserved.
//

const UInt8 kgreenLeftTurnCommand=0xB0;
const UInt8  kgreenRightTurnCommand=0xB1;
const UInt8 kredLeftTurnCommand=0xB2;
const UInt8  kredRightTurnCommand=0xB3;
const UInt8 khredLeftTurnCommand=0xB4;
const UInt8  khredRightTurnCommand=0xB5;
const UInt8 kqredLeftTurnCommand=0xB6;
const UInt8  kqredRightTurnCommand=0xB7;

#import "ViewController.h"
#import "MyAnnotation.h"





@interface ViewController ()


@property (weak, nonatomic) IBOutlet UIButton *scanButton;
- (IBAction)scanClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
- (IBAction)lastClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


@end

@implementation ViewController
MyAnnotation*event;
NSString * const  UUIDPrefKey = @"UUIDPrefKey";

@synthesize mylocation;
//@synthesize mylongitude;
//@synthesize mylatitude;
@synthesize myspeed;
@synthesize mydistance;
@synthesize mytime;
@synthesize myMap;
- (void)viewDidLoad
{
    [super viewDidLoad];
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    bleShield.delegate = self;
    
    //Retrieve saved UUID from system
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    
    if (self.lastUUID.length > 0)
    {
        self.uuidLabel.text = self.lastUUID;
    }
    else
    {
        self.lastButton.hidden = true;
    }
    
    self.mDevices = [[NSMutableArray alloc] init];
    
	if ([CLLocationManager locationServicesEnabled]) {
        self.mylocation=[[CLLocationManager alloc]init];
        self.mylocation.delegate= self;
        mylocation.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
        mylocation.distanceFilter=kCLDistanceFilterNone;
        [self.mylocation startUpdatingLocation];
    } else {
        NSLog(@"Location sevices are not enabled");
    }
    self.myMap.delegate = self;
    
    [self loadAndParseWithFilePath:@"curve.csv"];
    
}
-(NSMutableArray *)loadAndParseWithFilePath:(NSString *)filePath{
    NSArray *pathFragments = [filePath componentsSeparatedByString:@"."];
    NSString *path = pathFragments[0];
    NSString *type = pathFragments[1];
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:path ofType:type];
    
    NSError *error;
    NSString *csvData = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    NSArray *lines = [csvData componentsSeparatedByString:@"\n"];
    //NSLog(@"%@",lines);
    NSInteger count = lines.count - 1;
    NSMutableArray *allEvents = [NSMutableArray array];
    //MyAnnotation*event;
    //NSLog(@"%ld", (long)count);
    // NSMutableArray *annotations = [NSMutableArray array];*/
    //@autoreleasepool{
    for (NSInteger i = 0; i < count; i++){
        
        NSArray *components = [lines[i] componentsSeparatedByString:@","];
        event=[[MyAnnotation alloc]init];
        event.longitude = [components[0] floatValue];
        event.latitude = [components[1] floatValue];
        event.locDesc=[[NSString alloc]initWithFormat:@"%@",components[2]];
        event.curveType=[[NSString alloc]initWithFormat:@"%@", components[3]];
        event.curveDir=[[NSString alloc]initWithFormat:@"%@", components[4]];
        //NSString*curveDir=event.curveDir;
        event.locSpeedLimit=[components[5] floatValue];
        //NSLog(@"MYL %f %f %@ %f",event.latitude,event.longitude,event.curveDir,event.locSpeedLimit);
        CLLocationCoordinate2D coordinate;
        coordinate.latitude=event.latitude;
        coordinate.longitude=event.longitude;
        
        //NSLog(@"annotation: %f %f",coordinate.latitude,coordinate.longitude);
        MyAnnotation *ann1 = [[MyAnnotation alloc]
                              initWithLat:event.latitude longitude:event.longitude
                              title:event.address address:event.address
                              category:event.curveType
                              ];
        
        NSArray *_annotations = [NSArray arrayWithObject: ann1];
        [self.myMap addAnnotations:_annotations];
        [allEvents addObject:event];}
    return allEvents;
}



-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    //display speed 1 m/s = 2.2369 mph
    NSString *kmph=[[NSString alloc] initWithFormat:@"%3.0f mph",(2.2369*newLocation.speed )] ;
    myspeed.text=kmph;
    
    //display distance
    
    NSString *data = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"curve" ofType:@"csv"] encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [data componentsSeparatedByString:@"\n"];
    //NSLog(@"%@",lines);
    NSInteger count = lines.count - 1;
    // NSLog(@"%ld", (long)count);
    NSMutableArray*arraydistance=[[NSMutableArray alloc]init];
    NSMutableArray*arr_old_distance = [[NSMutableArray alloc]init];
    MyAnnotation*event;
    for (NSInteger i = 0; i < count; i++)
    {
        
        NSArray *components = [lines[i] componentsSeparatedByString:@","];
        event=[[MyAnnotation alloc]init];
        event.longitude = [components[0] floatValue];
        event.latitude = [components[1] floatValue];
        event.locDesc=[[NSString alloc]initWithFormat:@"%@",components[2]];
        event.curveType=[[NSString alloc]initWithFormat:@"%@", components[3]];
        event.curveDir=[[NSString alloc]initWithFormat:@"%@", components[4]];
        event.locSpeedLimit=[components[5] floatValue];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude=event.latitude;
        coordinate.longitude=event.longitude;
        
        CLLocation*curveLocation=[[CLLocation alloc]initWithLatitude:event.latitude longitude:event.longitude];
        //NSLog(@"curve location %@",curveLocation);
        CLLocationDistance distance=[newLocation distanceFromLocation:curveLocation];
        CLLocationDistance olddistance=[oldLocation distanceFromLocation:curveLocation];
        NSString*testdistance=[NSString stringWithFormat:@"%.1f m,",distance];
        //Add testdistance to line;
        NSString *newAddedDistance = [testdistance stringByAppendingFormat:@"%@",lines[i]];
       // NSLog(@"new added %@ %d",newAddedDistance,i);
        
        //obtain distance array;
        [arraydistance addObject:[NSString stringWithFormat:@"%@",newAddedDistance]];
        NSArray *newSortedArray = [arraydistance sortedArrayUsingComparator:^(id firstObject, id secondObject) {
            return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
        }];
        //NSLog(@" new sorted array distance=%@",newSortedArray);
        NSString*bestCurveString=[newSortedArray objectAtIndex:0];
        //NSLog(@"best curve string%@",bestCurveString);
        NSArray *newcomponents = [bestCurveString componentsSeparatedByString:@","];
        MyAnnotation*newCurveEvent;
        newCurveEvent=[[MyAnnotation alloc]init];
        newCurveEvent.parsedistance=[newcomponents[0] floatValue];
        newCurveEvent.longitude = [newcomponents[1] floatValue];
        newCurveEvent.latitude = [newcomponents[2] floatValue];
        newCurveEvent.locDesc=[[NSString alloc]initWithFormat:@"%@",newcomponents[3]];
        newCurveEvent.curveType=[[NSString alloc]initWithFormat:@"%@", newcomponents[4]];
        newCurveEvent.curveDir=[[NSString alloc]initWithFormat:@"%@", newcomponents[5]];
        newCurveEvent.locSpeedLimit=[newcomponents[6] floatValue];
       // NSLog(@"best line %f %f  %f %@ %@ %@  %f" ,newCurveEvent.parsedistance, newCurveEvent.longitude ,newCurveEvent.latitude,newCurveEvent.locDesc,newCurveEvent.curveType,newCurveEvent.curveDir,newCurveEvent.locSpeedLimit);
        [arr_old_distance addObject:[NSString stringWithFormat:@"%.1f m",olddistance]];
        //NSLog(@"old Array distance=%@",arr_old_distance);
        NSArray *sortedoldArray = [arr_old_distance sortedArrayUsingComparator:^(id firstObject, id secondObject) {
            return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
        }];
         //NSLog(@" sorted old array distance=%@",sortedoldArray);
        float oldclosest=[[sortedoldArray objectAtIndex:0] floatValue];
         //NSLog(@"my old closest distance %f", oldclosest);
        float residual_value=(newCurveEvent.parsedistance-oldclosest);
       // NSLog(@"residual %f",residual_value);
        //residual_closest.text=residual_value;
        
        //calculate the S
        //S=vt+(v^2-v1^2)/254*0.34
        //mph=0.4470m/s ft=0.3048 m
        float curveSpeed=newCurveEvent.locSpeedLimit*0.447;
        NSLog(@"vehicle speed and curve speed %f %f",newLocation.speed,curveSpeed);
        float SSD=newLocation.speed*2.5+((newLocation.speed*newLocation.speed)-(curveSpeed*curveSpeed))/(2*3.4);
        NSLog(@"SSD: %.0f",SSD);
        
        if (residual_value<0&&newLocation.speed>0) {
            if (newCurveEvent.parsedistance>=1000)
            {
                float kclosest=newCurveEvent.parsedistance*0.000621371;
                mydistance.text=[[NSString alloc]initWithFormat:@"%.2fmile",kclosest];
                //NSLog(@"Array %.1f mile",kclosest);
            }
            else if(newCurveEvent.parsedistance>=0&&newCurveEvent.parsedistance<1000) {
                CLLocationDistance kclosest=newCurveEvent.parsedistance;
                mydistance.text=[[NSString alloc]initWithFormat:@"%.f m",kclosest];
                //NSLog(@"Array %.1f m",kdistance);
            }
            NSString*time = [[NSString alloc]initWithFormat:@"%.0f s",newCurveEvent.parsedistance/newLocation.speed ];
            mytime.text=time;
            if (newCurveEvent.parsedistance<=150&&newCurveEvent.parsedistance>=5){
                if ((newCurveEvent.curveType=@"leftTurn")) {
                    NSLog(@"new  left turn  curve %@", newCurveEvent.curveType);
                    if (newLocation.speed>curveSpeed) {
                        if (((newLocation.speed-curveSpeed)/0.447)<5) {
                            [self redLeftTurn];
                        }
                        if (((newLocation.speed-curveSpeed)/0.447)<10&&((newLocation.speed-curveSpeed)/0.447)>5){
                            [self halfredLeftTurn];                                        }
                        if (((newLocation.speed-curveSpeed)/0.447)>10) {
                            [self qredLeftTurn];
                        }
                        
                    } else {
                        [self greenLeftTurn];
                    }}
                
                if ((newCurveEvent.curveType=@"rightTurn")) {
                    NSLog(@"new right turn curve %@", newCurveEvent.curveType);
                    if (newLocation.speed>curveSpeed) {
                        if (((newLocation.speed-curveSpeed)/0.447)<5) {
                            [self redRightTurn];
                        }
                        if (((newLocation.speed-curveSpeed)/0.447)<10&&((newLocation.speed-curveSpeed)/0.447)>5){
                            [self halfredRightTurn];                                        }
                        if (((newLocation.speed-curveSpeed)/0.447)>10) {
                            [self qredRightTurn];
                        }
                    } else {
                        [self greenRightTurn];
                    }
                }
            

                
                
                
                
            }
        }
        else{mydistance.text=@"----";
            mytime.text=@"----";
            
            
        }
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)locateme:(UIButton *)sender {
    self.myMap.showsUserLocation=YES;
}
- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (mapView.userTrackingMode == MKUserTrackingModeNone) {
        CLLocationCoordinate2D coordinate = userLocation.location.coordinate;
        MKCoordinateRegion reg =
        MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
        mapView.region = reg;
        
    }
}
- (MKAnnotationView *)mapView:(MKMapView *)myMap viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Don't create annotation views for the user location annotation
    if ([annotation isKindOfClass:[MyAnnotation class]])
    {
        MyAnnotation*thisCurve=(MyAnnotation*)annotation;
        
        //NSLog(@"this curve catorgry%@",thisCurve.category);
        static NSString *cureveAnnotaionIdentifier = @"cureveAnnotaionIdentifier";
        
        // Create an annotation view, but reuse a cached one if available
       
        MKAnnotationView *curveAnnotationView =
        [self.myMap dequeueReusableAnnotationViewWithIdentifier:cureveAnnotaionIdentifier];
        if(curveAnnotationView==nil){
            MKAnnotationView *annotationView = [[MKAnnotationView alloc]
                                                initWithAnnotation:annotation
                                                reuseIdentifier:cureveAnnotaionIdentifier];
            annotationView.canShowCallout = YES;
        
        if ([ thisCurve.category isEqualToString:@"leftTurn"])
        {
           
            annotationView.image = [UIImage imageNamed:@"leftcurve20.png"];
            
            
        }
        else  if ([ thisCurve.category isEqualToString:@"rightTurn"])
        {
            annotationView.image = [UIImage imageNamed:@"rightcurve20.png"];
        }
        annotationView.opaque = NO;
        return annotationView;
    }
        {
            curveAnnotationView.annotation = annotation;
        }

        
        return curveAnnotationView;
    }

    // Use a default annotation view for the user location annotation
    return nil;
}

- (IBAction)scanClick:(id)sender {
    
    if (bleShield.activePeripheral)
    {
        if(bleShield.activePeripheral.isConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    }
    
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    
    isFindingLast = false;
    self.lastButton.hidden = true;
    self.scanButton.hidden = true;
    [self.spinner startAnimating];
    
}


- (IBAction)lastClick:(id)sender {
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    
    isFindingLast = true;
    self.lastButton.hidden = true;
    self.scanButton.hidden = true;
    [self.spinner startAnimating];
}

- (void)greenLeftTurn {
    NSLog(@"green leftturn button was clicked");
    UInt16 buf[3]={kgreenLeftTurnCommand,0x00,0x00};
    NSData*data=[[NSData alloc]initWithBytes:buf length:3];
    [self->bleShield write:data];
}

- (void)greenRightTurn {
    NSLog(@"green rightturn button was clicked");
    UInt16 buf[3]={kgreenRightTurnCommand,0x00,0x00};
    NSData*data=[[NSData alloc]initWithBytes:buf length:3];
    [self->bleShield write:data];}
- (void)redLeftTurn {
    NSLog(@"1 s red leftturn button was clicked");
    UInt16 buf[3]={kredLeftTurnCommand,0x00,0x00};
    NSData*data=[[NSData alloc]initWithBytes:buf length:3];
    [self->bleShield write:data];
}

- (void)redRightTurn {
    NSLog(@"1s red rightturn button was clicked");
    UInt16 buf[3]={kredRightTurnCommand,0x00,0x00};
    NSData*data=[[NSData alloc]initWithBytes:buf length:3];
    [self->bleShield write:data];}
- (void)halfredLeftTurn {
    NSLog(@"0.5s red leftturn button was clicked");
    UInt16 buf[3]={khredLeftTurnCommand,0x00,0x00};
    NSData*data=[[NSData alloc]initWithBytes:buf length:3];
    [self->bleShield write:data];
}

- (void)halfredRightTurn {
    NSLog(@"0.5 red rightturn button was clicked");
    UInt16 buf[3]={khredRightTurnCommand,0x00,0x00};
    NSData*data=[[NSData alloc]initWithBytes:buf length:3];
    [self->bleShield write:data];}
- (void)qredLeftTurn {
    NSLog(@"0.25 red leftturn button was clicked");
    UInt16 buf[3]={kqredLeftTurnCommand,0x00,0x00};
    NSData*data=[[NSData alloc]initWithBytes:buf length:3];
    [self->bleShield write:data];
}

- (void)qredRightTurn {
    NSLog(@"0.25 red rightturn button was clicked");
    UInt16 buf[3]={kqredRightTurnCommand,0x00,0x00};
    NSData*data=[[NSData alloc]initWithBytes:buf length:3];
    [self->bleShield write:data];}
// Called when scan period is over
-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        //to connect to the peripheral with a particular UUID
        if(isFindingLast)
        {
            int i;
            for (i = 0; i < bleShield.peripherals.count; i++)
            {
                CBPeripheral *p = [bleShield.peripherals objectAtIndex:i];
                
                if (p.UUID != NULL)
                {
                    //Comparing UUIDs and call connectPeripheral is matched
                    if([self.lastUUID isEqualToString:[self getUUIDString:p.UUID]])
                    {
                        [bleShield connectPeripheral:p];
                    }
                }
            }
        }
        //Scan for all BLE in range and prepare a list
        else
        {
            [self.mDevices removeAllObjects];
            
            int i;
            for (i = 0; i < bleShield.peripherals.count; i++)
            {
                CBPeripheral *p = [bleShield.peripherals objectAtIndex:i];
                
                if (p.UUID != NULL)
                {
                    [self.mDevices insertObject:[self getUUIDString:p.UUID] atIndex:i];
                }
                else
                {
                    [self.mDevices insertObject:@"NULL" atIndex:i];
                }
            }
            
            //Show the list for user selection
            [self performSegueWithIdentifier:@"showDevice" sender:self];
        }
    }
    else
    {
        [self.spinner stopAnimating];
        
        if (self.lastUUID.length == 0)
        {
            self.lastButton.hidden = true;
        }
        else
        {
            self.lastButton.hidden = false;
        }
        
        self.scanButton.hidden = false;
    }
    
}

//Show device list for user selection
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDevice"])
    {
        RBLDetailViewController *vc =[segue destinationViewController] ;
        vc.BLEDevices = self.mDevices;
        vc.delegate = self;
    }
}

- (void)didSelected:(NSInteger)index
{
    self.scanButton.hidden = true;
    [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:index]];
}


-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    
}

- (void) bleDidDisconnect
{
    self.lastButton.hidden = false;
    self.rssiLabel.hidden = true;
    [self.scanButton setTitle:@"Scan All" forState:UIControlStateNormal];
}

-(void) bleDidConnect
{
    //Save UUID into system
    self.lastUUID = [self getUUIDString:bleShield.activePeripheral.UUID];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.spinner stopAnimating];
    self.lastButton.hidden = true;
    self.scanButton.hidden = false;
    self.uuidLabel.text = self.lastUUID;
    self.rssiLabel.text = @"RSSI: ?";
    self.rssiLabel.hidden = false;
    [self.scanButton setTitle:@"Disconnect" forState:UIControlStateNormal];
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", rssi.stringValue];
    NSLog(@"RSSI: %@",rssi.stringValue);}


-(NSString*)getUUIDString:(CFUUIDRef)ref {
    NSString *str = [NSString stringWithFormat:@"%@",ref];
    return [[NSString stringWithFormat:@"%@",str] substringWithRange:NSMakeRange(str.length - 36, 36)];
}

@end

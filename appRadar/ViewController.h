//
//  ViewController.h
//  appRadar
//
//  Created by Ronaldo on 28/01/15.
//  Copyright (c) 2015 Ronaldo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Radares.h"
#import "AudioController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate>

@property (readonly, nonatomic) CLLocationSpeed speed;
@property (readonly, nonatomic) CLLocationDirection direction;
@property (assign,   nonatomic) CLLocationDistance distance;
@property (nonatomic, strong)   CLLocationManager* locationManager;
@property (nonatomic, strong) Radares *radares;
@property (nonatomic, strong) Radar *radarMaisProximo;
@property (strong, nonatomic) AudioController *audioController;

@property (nonatomic, assign) IBOutlet UILabel *lbSpeed;
@property (nonatomic, assign) IBOutlet UILabel *lbDirection;
@property (nonatomic, assign) IBOutlet UILabel *lbLatitude;
@property (nonatomic, assign) IBOutlet UILabel *lbLongitude;
@property (nonatomic, assign) IBOutlet UILabel *lbDistance;
@property (nonatomic, assign) IBOutlet UILabel *lbError;
@property (nonatomic, assign) IBOutlet UIView *viewQuadrados;


@end


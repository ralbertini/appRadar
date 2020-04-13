//
//  Radares.h
//  appRadar
//
//  Created by Ronaldo on 03/02/15.
//  Copyright (c) 2015 Ronaldo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Radar.h"

@interface Radares : NSObject

@property (nonatomic, strong) NSMutableArray* radaresRaioDefinido;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) RLMRealm *realm;

- (void)importarRadares;
- (NSDictionary*)radarMaisProximo;
- (void)startTimer;

@end

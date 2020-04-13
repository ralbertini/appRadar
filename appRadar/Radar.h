//
//  Radar.h
//  appRadar
//
//  Created by Ronaldo on 03/02/15.
//  Copyright (c) 2015 Ronaldo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@interface Radar : RLMObject

@property NSString *idPk;
@property NSString *latitude;
@property NSString *longitude;
@property NSString *type;
@property NSString *dirType;
@property NSString *direction;
@property NSString *speed;
@property NSString *source;


@end

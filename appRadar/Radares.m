//
//  Radares.m
//  appRadar
//
//  Created by Ronaldo on 03/02/15.
//  Copyright (c) 2015 Ronaldo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Radares.h"

#define threshold_direction_degrees 100

@implementation Radares
@synthesize locationManager;
@synthesize radaresRaioDefinido;
@synthesize realm;

#pragma mark - Timer


- (void)startTimer {
    
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                  target: self
                                                selector: @selector(radarescomDistanciaMenorQueXMetros)
                                                userInfo: nil repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:t forMode: NSDefaultRunLoopMode];
}

#pragma mark - Realm
- (void)cleanTables {
    
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

- (void)importarRadares {
    
    [self cleanTables];
    
    realm = [RLMRealm defaultRealm];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"radares" ofType:@"txt"]; //IGO format
    
    NSString *fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *allLinesString = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    [realm beginWriteTransaction];
    
    NSUInteger idpk = 0;
    
    for (NSString *linha in allLinesString) {
        
        NSArray *itensLinha = [linha componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        if ([[itensLinha objectAtIndex:0] integerValue]) {
            
            Radar *radar = [[Radar alloc] init];
            radar.idPk      = [NSString stringWithFormat:@"%lu",(unsigned long)++idpk];
            radar.longitude = [itensLinha objectAtIndex:0]; //X
            radar.latitude  = [itensLinha objectAtIndex:1]; //Y
            radar.type      = [itensLinha objectAtIndex:2]; //TYPE
            radar.speed     = [itensLinha objectAtIndex:3]; //SPEED
            radar.dirType   = [itensLinha objectAtIndex:4]; //DirType
            radar.direction = [itensLinha objectAtIndex:5]; //Direction
            radar.source    = [NSString stringWithFormat:@"importedFromFile"];
            
            [realm addObject:radar];
        }
    }
    
    [realm commitWriteTransaction];
}

- (NSMutableArray*)todosRadares {
    
    realm = [RLMRealm defaultRealm];
    
    [realm refresh];
    RLMResults *radares = [Radar allObjects];
    
    NSMutableArray *retorno = [[NSMutableArray alloc] initWithCapacity:[radares count]];
    
    for (Radar *radar in radares) {
        [retorno addObject:radar];
    }
    
    return retorno;
}

#pragma mark - Radares
- (void)radarescomDistanciaMenorQueXMetros {
    
    if (!self.radaresRaioDefinido) {
        self.radaresRaioDefinido = [[NSMutableArray alloc] init];
    } else {
        [self.radaresRaioDefinido removeAllObjects];
    }
    
    for (Radar *radar in [self todosRadares]) {
        
        if ([self.locationManager.location
             distanceFromLocation:[[CLLocation alloc] initWithLatitude:[radar.latitude doubleValue]
                                                             longitude:[radar.longitude doubleValue] ]] <= 5000) {
            [self.radaresRaioDefinido addObject:radar];
        }
    }
    
    NSLog(@"Quantidade de radares no raio de %d metros: %lu",5000,(unsigned long)[self.radaresRaioDefinido count]);
   // [self.locationManager stopUpdatingLocation];
   // [self.locationManager startUpdatingLocation];
}

///Retorna o radar mais próximo da posisão atual
- (NSDictionary*)radarMaisProximo {
    
    CLLocationDistance nearRadarDistance = CLLocationDistanceMax;
    Radar *retorno;
    CLLocationDistance dist;
    
    for (Radar *radar in self.radaresRaioDefinido) {
        
        dist = [self.locationManager.location
                distanceFromLocation:[[CLLocation alloc]
                                      initWithLatitude:[radar.latitude doubleValue]
                                      longitude:[radar.longitude doubleValue]]];
        
        if (dist < nearRadarDistance) {
            retorno = radar;
            nearRadarDistance = dist;
        }
    }
    
    NSLog(@"Direction Radar Mais Proximo: %@",retorno.direction);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            retorno,@"radar",
            [NSString stringWithFormat:@"%f",nearRadarDistance],@"distance",
            [self rangeDirections:retorno],@"rangeDirections",
            nil];
}

///Retorna os graus a direita e esquera da Direction do radar mais proxmo
- (NSMutableArray *)rangeDirections:(Radar*)radar {
    
    NSMutableArray *range = [[NSMutableArray alloc] initWithCapacity:threshold_direction_degrees * 2];
    
    NSInteger angle = [radar.direction integerValue] - threshold_direction_degrees;
    
    for (int i = 0; i <= threshold_direction_degrees * 2 ; i++) {
        
        [range addObject:[NSNumber numberWithInt:(360 + angle++) % 360]];
    }
    
    return range;
}

@end

//
//  ViewController.m
//  appRadar
//
//  Created by Ronaldo on 28/01/15.
//  Copyright (c) 2015 Ronaldo. All rights reserved.
//

#import "ViewController.h"
#import "Radares.h"
#import "Radar.h"

#define distancia_minima_radar 500

@interface ViewController ()

@end


@implementation ViewController
@synthesize speed;
@synthesize direction;
@synthesize distance;
@synthesize locationManager;
@synthesize lbDirection;
@synthesize lbSpeed;
@synthesize lbLatitude;
@synthesize lbLongitude;
@synthesize radares;
@synthesize radarMaisProximo;
@synthesize audioController;
@synthesize viewQuadrados;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.viewQuadrados setHidden:NO];
    
    radares = [[Radares alloc] init];
    
    //Importar Radares
    [radares importarRadares];
    
    //Inicia Localizacao Pelo GPS
    [self startStandardUpdates];
    
    //Inicia Timer para busca de novos radares em um determinado raio
    [radares startTimer];
    
    self.audioController = [[AudioController alloc] init];
    
    [self gerarQuadrados];
    [self preencher:400.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startStandardUpdates {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    //locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //[locationManager startUpdatingLocation];
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"didUpdateLocations");
    
    [radares setLocationManager:manager];
    
    CLLocation *loc = [locations objectAtIndex:0];
    
    if (loc.speed > 0) {
        [self.lbSpeed       setText:[NSString stringWithFormat:@"%f",loc.speed*3.6f]];
    } else {
        [self.lbSpeed       setText:@"00"];
    }
    
    [self.lbDirection   setText:[NSString stringWithFormat:@"%f",loc.course]];
    [self.lbLongitude   setText:[NSString stringWithFormat:@"%f",loc.coordinate.longitude]];
    [self.lbLatitude    setText:[NSString stringWithFormat:@"%f",loc.coordinate.latitude]];

    NSDictionary* dictRetorno = [radares radarMaisProximo];
    
    radarMaisProximo = [dictRetorno objectForKey:@"radar"];
    
    [self.lbDistance setText:[NSString stringWithFormat:@"%@",[dictRetorno objectForKey:@"distance"]]];
    
    [self radarAlert:dictRetorno];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:  (CLAuthorizationStatus)status {

    NSLog(@"didChangeAuthorizationStatus");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Erro: %@",error);
    [self.lbError setText:[NSString stringWithFormat:@"%@",error]];
}

- (BOOL)radarAlert:(NSDictionary *)radarInformation {
    
    Radar *radar = [radarInformation objectForKey:@"radar"];
    
    if ([[radarInformation objectForKey:@"distance"] integerValue] <= distancia_minima_radar) {
        
        if (self.locationManager.location.course >= 0) {
           [self.lbError setText:@""];
            
            //Indica se o angulo de direcao esta dentro do range definido em graus a direita e a esquerda

            NSInteger indice = [[radarInformation objectForKey:@"rangeDirections"]
                                indexOfObject:[NSNumber numberWithInt:self.locationManager.location.course]];
            
            if (indice == NSNotFound) {
                
                NSLog(@"Indice não encontrado");
                [self.lbError setText:[NSString stringWithFormat:@"Direcao FORA do intervalor, deveria ser %@",radar.direction]];
                
            } else {
                
                NSLog(@"Posicao no indice: %ld",(long)indice);
                [self.audioController playSystemSound];
                [self.viewQuadrados setHidden:NO];
                [self preencher:[[radarInformation objectForKey:@"distance"] floatValue]];
                [self.lbError setText:@"Direcao VALIDA DENTRO do intervalo"];
            }
        } else {
            NSLog(@"Direcao invalida: %f",self.locationManager.location.course);
            
            [self.lbError setText:[NSString stringWithFormat:@"Direcao INVALIDA, deveria ser %@",radar.direction]];
        }
    }  else {
        NSLog(@"Distancia mínima não atingida");
    }
    return YES;
}

- (void)preencher:(Float32)distancia {
    
    Float32 dist = ((distancia / distancia_minima_radar) * 10000);
    
    for (UIImageView* img in self.viewQuadrados.subviews) {
        
        if (dist >= img.tag) {
            [img setHidden:NO];
        } else {
            [img setHidden:YES];
        }
    }
}

- (void)gerarQuadrados {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    Float32 quantidadeQuadrados = screenWidth / 2;
    
    NSUInteger larguraQuadrado = screenWidth / quantidadeQuadrados;
    
    int x = 0,y = 0;
    Float32 tag = 0;
    
    for (int i = 0; i < quantidadeQuadrados; i++) {
    
        tag+= (100 / quantidadeQuadrados) * 100.0f;
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, y, larguraQuadrado, 45)];
        [v setBackgroundColor:[UIColor blueColor]];
        [v setTag:tag];
        
        [self.viewQuadrados addSubview:v];
        
        x+=larguraQuadrado;
    }
    
}





@end

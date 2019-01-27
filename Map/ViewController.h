//
//  ViewController.h
//  Map
//
//  Created by Admin on 26.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *studentsInCircle2;
@property (weak, nonatomic) IBOutlet UILabel *studentsInCircle1;
@property (weak, nonatomic) IBOutlet UILabel *studentsInCircle3;


- (IBAction)searchAction:(UIBarButtonItem *)sender;
- (IBAction)addAction:(UIBarButtonItem *)sender;


@end


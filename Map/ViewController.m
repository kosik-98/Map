//
//  ViewController.m
//  Map
//
//  Created by Admin on 26.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "UIView+MKAnnotationView.h"
#import "Meeting.h"

@interface ViewController ()

@property (strong, nonatomic) CLGeocoder* geocoder;
@property (strong, nonatomic) MKDirections* directions;
@property (assign, nonatomic) NSMutableArray* studentsArray;
@property (strong, nonatomic) Meeting* meetingPoint;
@property (assign, nonatomic) NSInteger initialRadius;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.geocoder = [[CLGeocoder alloc] init];
    self.studentsArray = [NSMutableArray array];
    self.initialRadius = 1000;
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIColor*)randomColor
{
    CGFloat red = arc4random()%1000 / 1000.f;
    CGFloat green = arc4random()%1000 / 1000.f;
    CGFloat blue = arc4random()%1000 / 1000.f;
    
    UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    return color;
}

-(void)refreshCountOfStudentsInCircles
{
    CLLocation* centerOfCircles = [[CLLocation alloc] initWithLatitude:self.meetingPoint.coordinate.latitude
                                                             longitude:self.meetingPoint.coordinate.longitude];
    
    NSInteger circle1Count = 0;
    NSInteger circle2Count = 0;
    NSInteger circle3Count = 0;
    
    for(id <MKAnnotation> annotation in self.mapView.annotations)
    {
        if([annotation isKindOfClass:[Student class]])
        {
            CLLocation* studentLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
                                                                     longitude:annotation.coordinate.longitude];
            
            CLLocationDistance distance = [centerOfCircles distanceFromLocation:studentLocation];
            
            if(distance <= self.initialRadius)
            {
                circle1Count++;
            }
            else if(distance <= self.initialRadius * 2)
            {
                circle2Count++;
            }
            else if(distance <= self.initialRadius * 3)
            {
                circle3Count++;
            }
        }
    }
    
    self.studentsInCircle1.text = [NSString stringWithFormat:@"Count in 10km circle = %d", circle1Count];
    self.studentsInCircle2.text = [NSString stringWithFormat:@"Count in 20km circle = %d", circle2Count];
    self.studentsInCircle3.text = [NSString stringWithFormat:@"Count in 30km circle = %d", circle3Count];
}

-(void)createCirclesAroundCoordinate:(CLLocationCoordinate2D)centerCoordinate
{
    NSMutableArray* circlesArray = [NSMutableArray array];
    
    for(int i = 0; i < 3; i++)
    {
        MKCircle* circle =[MKCircle circleWithCenterCoordinate:centerCoordinate radius:self.initialRadius*(i+1)];
        [circlesArray addObject:circle];
    }
    
    [self.mapView addOverlays:circlesArray];
}

-(void)createRouteForAnnotation:(id <MKAnnotation>)annotation
{
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
    
    Student* student = annotation;
    
    MKPlacemark* destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.meetingPoint.coordinate];
    MKPlacemark* sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:student.coordinate];
    
    request.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    
    self.directions = [[MKDirections alloc] initWithRequest:request];
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error)
    {
        if(error)
        {
            NSLog(@"%@",[error localizedDescription]);
        }
        else
        {
            NSMutableArray* newOverlays = [NSMutableArray array];
            
            for(MKRoute* route in response.routes)
            {
                [newOverlays addObject:route.polyline];
            }
            
            [self.mapView addOverlays:newOverlays];
        }
    }];
}

#pragma mark - Actions

- (void)actionDescription:(UIButton*)sender
{
    MKAnnotationView* annotationView = [sender superMKAnnotationView];
    
    if(!annotationView)
        return;
    
    CLLocation* location = [[CLLocation alloc] initWithLatitude:annotationView.annotation.coordinate.latitude
                                                      longitude:annotationView.annotation.coordinate.longitude];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error)
    {
        NSString* message;
         
        if(error)
            message = [error localizedDescription];
        else
        {
            CLPlacemark* placemark = [placemarks firstObject];
            message = [placemark.addressDictionary description];
        }
        
        [[[UIAlertView alloc]initWithTitle:@"Location"
                                   message:message
                                  delegate:nil
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:nil] show];
    }];
    
    
}

- (IBAction)searchAction:(UIBarButtonItem *)sender
{
    if(self.mapView.overlays)
    {
        [self.mapView removeOverlays:self.mapView.overlays];
    }
    
    if(self.meetingPoint)
    {
        [self.mapView removeAnnotation:self.meetingPoint];
    }
    else
    {
        self.meetingPoint = [[Meeting alloc] init];
    }
    
    self.meetingPoint.coordinate = self.mapView.region.center;
    self.meetingPoint.title = @"Meeting point";
    
    [self.mapView addAnnotation:self.meetingPoint];
    
    [self createCirclesAroundCoordinate:self.meetingPoint.coordinate];
    [self refreshCountOfStudentsInCircles];
    
    for(Student* student in self.mapView.annotations)
    {
        [self createRouteForAnnotation:student];
    }
    
    
}

- (IBAction)addAction:(UIBarButtonItem *)sender
{
    CLLocationCoordinate2D centerCoordinates = self.mapView.region.center;
    
    if([self.mapView.annotations count] > 0)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    if([self.mapView.overlays count] > 0)
    {
        [self.mapView removeOverlays:self.mapView.overlays];
    }
    
    for(int i = 0; i < 10; i++)
    {
        Student* student = [Student randomStudentAroundCoordinate:centerCoordinates];
        [self.mapView addAnnotation:student];
    }
}


#pragma mark - MKMapViewDelegate


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if([view.annotation isKindOfClass:[Meeting class]])
    {
        if(newState == MKAnnotationViewDragStateEnding)
        {
            newState = MKAnnotationViewDragStateNone;
            
            [self.mapView removeOverlays:self.mapView.overlays];
            
            [self createCirclesAroundCoordinate:self.meetingPoint.coordinate];
            [self refreshCountOfStudentsInCircles];
            
            for(Student* student in self.mapView.annotations)
            {
                [self createRouteForAnnotation:student];
            }
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        
        renderer.lineWidth = 2.f;
        renderer.strokeColor = [self randomColor];
        
        return renderer;
    }
    
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer* renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        
        renderer.strokeColor = [UIColor redColor];
        renderer.lineWidth = 3.f;
        
        return renderer;
    }
    
    return nil;
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString* studentIdentifier = @"studentPin";
    static NSString* meetingIdentifier = @"meetingPin";
    
    if([annotation isKindOfClass:[Student class]])
    {
        MKPinAnnotationView* pin = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:studentIdentifier];
        
        if(!pin)
        {
            pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:studentIdentifier];
            if([(Student <MKAnnotation>*)annotation gender] == Male)
            {
                pin.pinTintColor = [MKPinAnnotationView redPinColor];
            }
            else
            {
                pin.pinTintColor = [MKPinAnnotationView purplePinColor];
            }
            
            pin.animatesDrop = YES;
            pin.canShowCallout = YES;
            
            UIButton* descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [descriptionButton addTarget:self action:@selector(actionDescription:) forControlEvents:UIControlEventTouchUpInside];
            
            pin.rightCalloutAccessoryView = descriptionButton;
        }
        else
        {
            pin.annotation = annotation;
        }
        
        return pin;
    }
    else if([annotation isKindOfClass:[Meeting class]])
    {
        MKPinAnnotationView* pin = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:meetingIdentifier];
        
        if(!pin)
        {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:meetingIdentifier];
            pin.pinTintColor = [MKPinAnnotationView greenPinColor];
            pin.animatesDrop = YES;
            pin.draggable = YES;
            pin.canShowCallout = YES;
        }
        else
        {
            pin.annotation = annotation;
        }
        
        return pin;
    }
    return nil;
}

@end

//
//  Student.m
//  Map
//
//  Created by Admin on 26.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "Student.h"

@implementation Student

+ (Student*)randomStudentAroundCoordinate:(CLLocationCoordinate2D)centerCoordinate
{
    double lat;
    double lon;
    
    Student* student = [[Student alloc] init];
    
    student.title = [NSString stringWithFormat:@"Student %d", arc4random()%100];
    
    if(arc4random()%2)
        lat = centerCoordinate.latitude - arc4random()%100 / 3000.f;
    else
        lat = centerCoordinate.latitude + arc4random()%100 / 3000.f;
    
    if(arc4random()%2)
        lon = centerCoordinate.longitude - arc4random()%100 / 3000.f;
    else
        lon = centerCoordinate.longitude + arc4random()%100 / 3000.f;
    
    student.coordinate = CLLocationCoordinate2DMake(lat, lon);
    student.gender = arc4random()%2;
    
    return student;
}

@end

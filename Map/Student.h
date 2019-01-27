//
//  Student.h
//  Map
//
//  Created by Admin on 26.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum
{
    Male,
    Female
}Gender;

@interface Student : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *subtitle;
@property (assign, nonatomic) Gender gender;

+ (Student*)randomStudentAroundCoordinate:(CLLocationCoordinate2D)centerCoordinate;

@end

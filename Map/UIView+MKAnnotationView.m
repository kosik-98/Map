//
//  UIView+MKAnnotationView.m
//  Map
//
//  Created by Admin on 26.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "UIView+MKAnnotationView.h"

@implementation UIView (MKAnnotationView)

- (MKAnnotationView*)superMKAnnotationView
{
    if([self isKindOfClass:[MKAnnotationView class]])
    {
        return (MKAnnotationView*)self;
    }
    
    if(!self.superview)
    {
        return nil;
    }
    
    return [self.superview superMKAnnotationView];
}

@end

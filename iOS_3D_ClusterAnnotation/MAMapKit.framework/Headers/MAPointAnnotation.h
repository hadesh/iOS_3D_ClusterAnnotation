//
//  MAPointAnnotation.h
//  MAMapKitDemo
//
//  Created by songjian on 13-1-7.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "MAShape.h"
#import <CoreLocation/CLLocation.h>

/**
 *  点标注数据
 */
@interface MAPointAnnotation : MAShape

/**
*  经纬度
*/
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

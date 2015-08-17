//
//  ClusterAnnotation.m
//  officialDemo2D
//
//  Created by yi chen on 14-5-15.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "ClusterAnnotation.h"

@implementation ClusterAnnotation

#pragma mark - compare

- (NSUInteger)hash
{
    NSString *toHash = [NSString stringWithFormat:@"%.5F%.5F%ld", self.coordinate.latitude, self.coordinate.longitude, (long)self.count];
    return [toHash hash];
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}

#pragma mark - Life Cycle

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count
{
    self = [super init];
    if (self)
    {
        _coordinate = coordinate;
        _count = count;
        _pois  = [NSMutableArray arrayWithCapacity:count];
    }
    return self;
}

@end

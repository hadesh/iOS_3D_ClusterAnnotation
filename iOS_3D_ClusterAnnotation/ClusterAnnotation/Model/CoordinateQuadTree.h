//
//  CoordinateQuadTree.h
//  officialDemo2D
//
//  Created by yi chen on 14-5-15.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import "QuadTree.h"

@interface CoordinateQuadTree : NSObject

@property (nonatomic, assign) QuadTreeNode * root;

/// 这里对poi对象的内存管理被四叉树接管了，当clean的时候会释放，外部有引用poi的地方必须再clean前清理。
- (void)buildTreeWithPOIs:(NSArray *)pois;
- (void)clean;

- (NSArray *)clusteredAnnotationsWithinMapRect:(MAMapRect)rect withZoomScale:(double)zoomScale andZoomLevel:(double)zoomLevel;

@end

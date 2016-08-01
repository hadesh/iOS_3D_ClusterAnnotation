iOS_3D_ClusterAnnotation
========================

### 更新
####2016年08月01日
· 地图 4.1.0
· 搜索 4.1.0
· 基础 1.1.0

##MAMapKit 点聚合

### 前述

- [高德官方网站申请key](http://id.amap.com/?ref=http%3A%2F%2Fapi.amap.com%2Fkey%2F).
- 阅读[参考手册](http://api.amap.com/Public/reference/iOS%20API%20v2_3D/).
- 如果有任何疑问也可以发问题到[官方论坛](http://bbs.amap.com/forum.php?gid=1).

### 使用教程

- 调用ClusterAnnotation文件夹下的代码能够实现poi点聚合，使用步骤如下：
- 初始化coordinateQuadTree。
```objc
self.coordinateQuadTree = [[CoordinateQuadTree alloc] init];
```
- 获得poi数组pois后，创建coordinateQuadTree。
 * 项目Demo通过关键字搜索获得poi数组数据，具体见工程。此处从获得poi数组开始说明。
 * 创建四叉树coordinateQuadTree来建立poi的四叉树索引。
 * 创建过程较为费时，建议另开线程。创建四叉树完成后，计算当前mapView下需要显示的annotation。
```objc
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    /* 建立四叉树. */
    [self.coordinateQuadTree buildTreeWithPOIs:respons.pois];
        
    dispatch_async(dispatch_get_main_queue(), ^{
            /* 计算当前mapView区域内需要显示的annotation. */
            NSLog(@"First time calculate annotations.");
            [self addAnnotationsToMapView:self.mapView];
    });
});
```

- 根据CoordinateQuadTree四叉树索引，计算当前zoomLevel下，mapView区域内的annotation。
```objc
- (void)addAnnotationsToMapView:(MAMapView *)mapView
{
    /* 判断是否已建树. */
    if (self.coordinateQuadTree.root == nil)
    {
        return;
    }
    /* 根据当前zoomLevel和zoomScale 进行annotation聚合. */
    double zoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
    /* 基于先前建立的四叉树索引，计算当前需要显示的annotations. */
    NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect
                                withZoomScale:zoomScale
                                 andZoomLevel:mapView.zoomLevel];
   
    /* 更新annotations. */
    [self updateMapViewAnnotationsWithAnnotations:annotations];
}
```
- 更新annotations。对比mapView里已有的annotations，吐故纳新。
```objc
/* 更新annotation. */
- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    /* 用户滑动时，保留仍然可用的标注，去除屏幕外标注，添加新增区域的标注 */
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];
    
    /* 保留仍然位于屏幕内的annotation. */
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    /* 需要添加的annotation. */
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    /* 删除位于屏幕外的annotation. */
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    /* 更新. */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    });
}
```
- 实现MapView的delegate方法，根据anntation生成对应的View。annotationView的位置由其代表的poi平均位置决定，大小由poi数目决定。
```objc
-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
        /* dequeue重用annotationView代码. */
        /* ... */
        
        /* 设置annotationView的属性. */
        annotationView.annotation = annotation;
        annotationView.count = [(ClusterAnnotation *)annotation count];
        
        /* 设置annotationView的callout属性和calloutView代码. */
        /* ... */
        return annotationView;
    }
    return nil;
}
```

- 在mapView显示区域改变时，需要重算并更新annotations。
```obj
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    /* mapView区域变化时重算annotation. */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addAnnotationsToMapView:self.mapView];
    });
}
```


### 架构

##### Controllers
- `<UIViewController>`
  * `BaseMapViewController` 地图基类
    - `AnnotationClusterViewController` poi点聚合
  * `PoiDetailViewController` 显示poi详细信息列表

##### View

* `MAAnnotationView`
  - `ClusterAnnotationView` 自定义的聚合annotationView

##### Models

* `Conform to <MAAnnotation>`
  - `ClusterAnnotation` 记录annotation的信息，如其代表的poi数组、poi的个数、poi平均坐标，并提供两个annotation是否Equal的判断
* `CoordinateQuadTree` 封装的四叉树类
* `QuadTree` 四叉树基本算法

### 截图效果

![ClusterAnnotation2](https://raw.githubusercontent.com/cysgit/iOS_3D_ClusterAnnotation/master/iOS_3D_ClusterAnnotation/Resources/ClusterAnnotation2.png)
![ClusterAnnotation1](https://raw.githubusercontent.com/cysgit/iOS_3D_ClusterAnnotation/master/iOS_3D_ClusterAnnotation/Resources/ClusterAnnotation1.png)

//
//  BaseMapViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "BaseMapViewController.h"

@implementation BaseMapViewController
@synthesize mapView = _mapView;
@synthesize search  = _search;

#pragma mark - Utility

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
}

#pragma mark - AMapSearchDelegate

- (void)search:(id)searchRequest error:(NSString *)errInfo
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [searchRequest class], errInfo);
}

#pragma mark - Initialization

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}

- (void)initSearch
{
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
    self.search.delegate = self;
}

- (void)initTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor blackColor];
    titleLabel.text             = title;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTitle:self.title];

    [self initMapView];
    
    [self initSearch];
}

@end

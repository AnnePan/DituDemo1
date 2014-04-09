//
//  PJOneViewController.h
//  DituDemo1
//
//  Created by hamigua on 14-4-8.
//  Copyright (c) 2014年 com.patk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMKMapView.h"
#import "PJOneViewController.h"
#import "BMapKit.h"

@interface PJOneViewController : UIViewController<BMKMapViewDelegate,BMKSearchDelegate>
{
    CLLocationCoordinate2D _coor;
    BOOL isLoced;//判断是否已经执行过定位
    UIView *nibView;
    BMKSearch* _search;
}

@property (strong,nonatomic) BMKMapView *mapView;
@property(assign,nonatomic)CLLocationCoordinate2D coor;
@property(assign,nonatomic)CLLocationDegrees startCoordainateXText;
@property(assign,nonatomic)CLLocationDegrees startCoordainateYText;
@property(assign,nonatomic)CLLocationDegrees endCoordainateXText;
@property(assign,nonatomic)CLLocationDegrees endCoordainateYText;


@end

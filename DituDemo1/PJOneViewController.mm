//
//  PJOneViewController.m
//  DituDemo1
//
//  Created by hamigua on 14-4-8.
//  Copyright (c) 2014年 com.patk. All rights reserved.
//

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]
#import "PJOneViewController.h"

@interface RouteAnnotation : BMKPointAnnotation
{
	int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
	int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end

@interface UIImage(InternalMethod)

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;

@end

@implementation UIImage(InternalMethod)

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees
{
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
	CGSize rotatedSize;
    
    rotatedSize.width = width;
    rotatedSize.height = height;
    
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	CGContextRotateCTM(bitmap, degrees * M_PI / 180);
	CGContextRotateCTM(bitmap, M_PI);
	CGContextScaleCTM(bitmap, -1.0, 1.0);
	CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end


@interface PJOneViewController ()
{

    BMKPointAnnotation* pointAnnotation;
    BMKGroundOverlay* ground;
    BMKAnnotationView* newAnnotation;

}


@end

@implementation PJOneViewController

@synthesize coor = _coor;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isLoced = NO;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    BMKMapView *mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    mapView.showsUserLocation = YES;
    [_mapView setZoomLevel:11];
//    [self.navigationController setNavigationBarHidden:YES];//可以让地图铺满屏幕
    UIBarButtonItem *barBT = [[UIBarButtonItem alloc]initWithTitle:@"标识" style:UIBarButtonItemStyleDone target:self action:@selector(clickAddPoint)];
    UIBarButtonItem *searchBT = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchPoint)];
    self.navigationItem.leftBarButtonItem = barBT;
    self.navigationItem.rightBarButtonItem = searchBT;
    self.title = @"百度地图";
    _mapView = mapView;
    _search = [[BMKSearch alloc]init];
    [self.view addSubview:_mapView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _search.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _search.delegate = nil; // 不用时，置nil
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark   ----------------

- (NSString*)getMyBundlePath1:(NSString *)filename
{
    NSBundle * libBundle = MYBUNDLE ;
	if ( libBundle && filename ){
		NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
		return s;
        NSLog(@"s = %@",s);
	}
	return nil ;
}


#pragma mark -------大头针和弹出气泡相关--------

// 添加一个标识
-(void)clickAddPoint{
    NSLog(@"......");
    // 添加一个PointAnnotation
//    if (pointAnnotation == nil) {
        [self addPointAnnotation];
//    }
}

//添加标注
- (void)addPointAnnotation
{
    pointAnnotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = 31.02;//控制大头针的位置
    coor.longitude = 121.48;
    pointAnnotation.coordinate = coor;
    pointAnnotation.title = @"潘娟娟";
    pointAnnotation.subtitle = @"上海市陆家嘴站!";
    [_mapView addAnnotation:pointAnnotation];
    NSLog(@"添加标注..");
}
#pragma mark -------路线和导航--------

// 搜索一个位置
-(void)searchPoint{
    
    if (nibView == nil) {
        NSLog(@"找路线并导航。。。");
        nibView=[[[NSBundle mainBundle] loadNibNamed:@"searchView" owner:self options:nil]objectAtIndex:0];
        UIButton *bt = (UIButton*)[nibView viewWithTag:3];
        [bt addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventTouchUpInside];
        nibView.frame=CGRectMake(0, 63, 320, 40); //设置frame
        [self.view addSubview:nibView];
    }else{
        [nibView removeFromSuperview];
        nibView = nil;
    }
    
}

-(void)startSearch{
    NSLog(@"kaishi....sousuo...");
    NSString *startName = ((UILabel*)[nibView viewWithTag:1]).text;
    NSString *endName = ((UILabel*)[nibView viewWithTag:2]).text;
    NSLog(@"startName = %@,endName = %@",startName,endName);
    
    [self addPointAnnotation];
    [self onClickDriveSearch:startName endName:endName];
}

-(void)onClickDriveSearch:(NSString*)startName endName:(NSString*)endName
{
	BMKPlanNode* start = [[BMKPlanNode alloc] init];
	start.name = startName;
	BMKPlanNode* end = [[BMKPlanNode alloc] init];
	end.name = endName;
    
	BOOL flag = [_search transitSearch:@"上海" startNode:start endNode:end];
	if (flag) {
		NSLog(@"search success.");
	}
    else{
        NSLog(@"search failed!");
    }
    
}


#pragma mark  ------定位-------

- (void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    if (!isLoced) {
        NSLog(@"userLocation = %f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
        if (userLocation != nil) {
            NSLog(@"%f %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
            BMKCoordinateRegion region;
            region.center.latitude = userLocation.location.coordinate.latitude;
            region.center.longitude = userLocation.location.coordinate.longitude;
            region.span.latitudeDelta = .5;
            region.span.longitudeDelta =.5;//这个是定位服务的。
            if (mapView) {
                mapView.region = region;
                isLoced = YES;
                
                //添加图片图层覆盖物(第一种)
                if (ground == nil) {
                    CLLocationCoordinate2D coors;
                    coors.latitude = 31.22;
                    coors.longitude = 121.48;
                    ground = [BMKGroundOverlay groundOverlayWithPosition:coors zoomLevel:11 anchor:CGPointMake(0.0f,0.0f) icon:[UIImage imageWithContentsOfFile:[self getMyBundlePath:@"images/test.png"]]];
                    ground = [BMKGroundOverlay groundOverlayWithPosition:coors zoomLevel:11 anchor:CGPointMake(0.0f,0.0f) icon:[UIImage imageNamed:@"test1.png"]];
                    [_mapView addOverlay:ground];
                }

            }
            
            
        }else{
            NSLog(@"获取位置失败");
        }
    }
}

- (NSString*)getMyBundlePath:(NSString *)filename
{
	
	NSBundle * libBundle = MYBUNDLE ;
	if ( libBundle && filename ){
		NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        //        NSLog(@"%@",s);
		return s;
	}
	return nil ;
}




#pragma mark implement BMKMapViewDelegate

// 根据anntation生成对应的View
//- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
//{
//    NSString *AnnotationViewID = @"renameMark";
//    if (newAnnotation == nil) {
//        newAnnotation = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//        // 设置颜色
//		((BMKPinAnnotationView*)newAnnotation).pinColor = BMKPinAnnotationColorPurple;
//        // 从天上掉下效果
//		((BMKPinAnnotationView*)newAnnotation).animatesDrop = YES;
//        // 设置可拖拽
//		((BMKPinAnnotationView*)newAnnotation).draggable = YES;
//        //把大头针换成别的图片
//        ((BMKPinAnnotationView*)newAnnotation).image = [UIImage imageNamed:@"pin.png"];
//        
//        //自定义泡泡图层
//        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 64)];
//        label.text=@"陈双超";
//        label.backgroundColor=[UIColor redColor];
//        BMKActionPaopaoView *popaoview = [[BMKActionPaopaoView alloc] initWithCustomView:label];
//        ((BMKPinAnnotationView*)newAnnotation).paopaoView = popaoview;
//        
//    }
//    return newAnnotation;
//    
//}

- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation

{
    NSLog(@"00000000");
	if ([annotation isKindOfClass:[RouteAnnotation class]]) {
		return [self getRouteAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
	}
	return nil;
}

//当选中一个annotation views时，调用此接口
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    NSLog(@"选中一个annotation views:%f,%f",view.annotation.coordinate.latitude,view.annotation.coordinate.longitude);
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
}

//便签纸的图层
//- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
//{
//    if ([overlay isKindOfClass:[BMKGroundOverlay class]])
//    {
//        BMKGroundOverlayView* groundView = [[BMKGroundOverlayView alloc] initWithOverlay:overlay];
//		return groundView;
//    }
//	return nil;
//}



- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
	return nil;
}
- (void)onGetTransitRouteResult:(BMKSearch*)searcher result:(BMKPlanResult*)result errorCode:(int)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
	array = [NSArray arrayWithArray:_mapView.overlays];
	[_mapView removeOverlays:array];
    if (error == BMKErrorOk) {
		BMKTransitRoutePlan* plan = (BMKTransitRoutePlan*)[result.plans objectAtIndex:0];
		RouteAnnotation* item = [[RouteAnnotation alloc] init];
		item.coordinate = plan.startPt;
		item.title = @"起点";
		item.type = 0;
		[_mapView addAnnotation:item]; // 添加起点标注
		
        
		item = [[RouteAnnotation alloc]init];
		item.coordinate = plan.endPt;
		item.type = 1;
		item.title = @"终点";
		[_mapView addAnnotation:item]; // 终点标注
		
        // 计算路线方案中的点数
		int size = [plan.lines count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
			BMKRoute* route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j++) {
				int len = [route getPointsNum:j];
				planPointCounts += len;
			}
			BMKLine* line = [plan.lines objectAtIndex:i];
			planPointCounts += line.pointsCount;
			if (i == size - 1) {
				i++;
				route = [plan.routes objectAtIndex:i];
				for (int j = 0; j < route.pointsCount; j++) {
					int len = [route getPointsNum:j];
					planPointCounts += len;
				}
				break;
			}
		}
		
        // 构造方案中点的数组，用户构建BMKPolyline
		BMKMapPoint* points = new BMKMapPoint[planPointCounts];
		planPointCounts = 0;
		
        // 查询队列中的元素，构建points数组，并添加公交标注
		for (int i = 0; i < size; i++) {
			BMKRoute* route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j++) {
				int len = [route getPointsNum:j];
				BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
				memcpy(points + planPointCounts, pointArray, len * sizeof(BMKMapPoint));
				planPointCounts += len;
			}
			BMKLine* line = [plan.lines objectAtIndex:i];
			memcpy(points + planPointCounts, line.points, line.pointsCount * sizeof(BMKMapPoint));
			planPointCounts += line.pointsCount;
			
			item = [[RouteAnnotation alloc]init];
			item.coordinate = line.getOnStopPoiInfo.pt;
			item.title = line.tip;
			if (line.type == 0) {
				item.type = 2;
			} else {
				item.type = 3;
			}
			
			[_mapView addAnnotation:item]; // 上车标注
        
			route = [plan.routes objectAtIndex:i+1];
			item = [[RouteAnnotation alloc]init];
			item.coordinate = line.getOffStopPoiInfo.pt;
			item.title = route.tip;
			if (line.type == 0) {
				item.type = 2;
			} else {
				item.type = 3;
			}
			[_mapView addAnnotation:item]; // 下车标注
    
			if (i == size - 1) {
				i++;
				route = [plan.routes objectAtIndex:i];
				for (int j = 0; j < route.pointsCount; j++) {
					int len = [route getPointsNum:j];
					BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
					memcpy(points + planPointCounts, pointArray, len * sizeof(BMKMapPoint));
					planPointCounts += len;
				}
				break;
			}
		}
        
        // 通过points构建BMKPolyline
		BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:points count:planPointCounts];
		[_mapView addOverlay:polyLine]; // 添加路线overlay
		delete []points;
        
        [_mapView setCenterCoordinate:result.startNode.pt animated:YES];
	}
}

- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
	BMKAnnotationView* view = nil;
	switch (routeAnnotation.type) {
		case 0:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 1:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 2:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 3:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 4:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
				view.canShowCallout = TRUE;
			} else {
				[view setNeedsDisplay];
			}
			
			UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
			view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
			view.annotation = routeAnnotation;
			
		}
			break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
				view.canShowCallout = TRUE;
			} else {
				[view setNeedsDisplay];
			}
			
			UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_waypoint.png"]];
			view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
			view.annotation = routeAnnotation;
        }
            break;
		default:
			break;
	}
	
	return view;
}



#pragma mark ------BMKSearchDelegate接口回调方法-------

//- (void)onGetDrivingRouteResult:(BMKPlanResult*)result errorCode:(int)error
//{
//    
//    if (error == BMKErrorOk)
//    {
//        BMKRoutePlan* plan = (BMKRoutePlan*)[result.plans objectAtIndex:0];
//        
//        BMKRoute* route = [plan.routes objectAtIndex:0];
//        
//        BMKMapPoint* points = malloc(sizeof(CLLocationCoordinate2D) * route.steps.count);
//        
//        for (int i = 0; i < route.steps.count; ++i)
//        {
//            BMKStep* step = [route.steps objectAtIndex:i];
//            BMKMapPoint point = BMKMapPointForCoordinate(step.pt); //注意这里的处理方法
//            points[i] = point;
//        }
//        
//        [_mapView removeOverlays:[_mapView overlays]];
//        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:points count:route.steps.count];
//        free(points);
//        [_mapView addOverlay:polyLine];
//    }
//}




@end

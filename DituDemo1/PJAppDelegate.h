//
//  PJAppDelegate.h
//  DituDemo1
//
//  Created by hamigua on 14-4-8.
//  Copyright (c) 2014年 com.patk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMKMapManager.h"

@interface PJAppDelegate : UIResponder <UIApplicationDelegate>{
    
    UINavigationController *navigationController;
    BMKMapManager *_mapManager;

}

@property (strong, nonatomic) UIWindow *window;

@end

//
//  IQTabbarController.h
//  IQChannels
//
//  Created by Ivan Korobkov on 12/09/16.
//  Copyright © 2016 Ivan Korobkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQAppDelegate;

@interface IQTabbarController : UITabBarController
@property(nonatomic, weak) IQAppDelegate *appDelegate;
+ (instancetype)controllerWithAppDelegate:(IQAppDelegate *)appDelegate;
@end

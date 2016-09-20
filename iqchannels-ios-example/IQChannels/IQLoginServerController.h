//
//  IQLoginServerController.h
//  IQChannels
//
//  Created by Ivan Korobkov on 17/09/16.
//  Copyright © 2016 Ivan Korobkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IQLoginServerController : UIViewController
+ (UINavigationController *)controllerWithCallback:(void (^)(NSString *))callback;
@end

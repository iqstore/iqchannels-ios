//
//  Created by Ivan Korobkov on 12/09/16.
//

#import <UIKit/UIKit.h>

@class IQAppDelegate;

@interface IQLoginController : UIViewController
@property(nonatomic, weak) IQAppDelegate *appDelegate;
+ (instancetype)controllerWithAppDelegate:(IQAppDelegate *)appDelegate;
@end

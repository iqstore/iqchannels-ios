//
//  IQTabbarController.m
//  IQChannels
//
//  Created by Ivan Korobkov on 12/09/16.
//  Copyright © 2016 Ivan Korobkov. All rights reserved.
//

#import <IQChannels/IQChannels.h>
#import "IQTabbarController.h"
#import "IQAppDelegate.h"
#import "IQExpensesController.h"
#import "IQMessagesController.h"


@interface IQTabbarController () <UITabBarControllerDelegate>
@property(nonatomic) UINavigationController *expenses;
@property(nonatomic) UINavigationController *messages;
@property(nonatomic) UINavigationController *logout;
@end


@implementation IQTabbarController
+ (instancetype)controllerWithAppDelegate:(IQAppDelegate *)appDelegate {
    IQTabbarController *controller = [[IQTabbarController alloc] init];
    controller.appDelegate = appDelegate;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;

    self.expenses = [self newExpenses];
    self.messages = [self newMessages];
    self.logout = [self newLogout];
    self.viewControllers = @[self.expenses, self.messages, self.logout];
}

- (UINavigationController *)newExpenses {
    UINavigationController *nc = [[UINavigationController alloc]
        initWithRootViewController:[[IQExpensesController alloc] init]];
    nc.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Расходы"
        image:[UIImage imageNamed:@"tabbar-expenses.png"]
        tag:0];
    [self setupChild:nc];
    return nc;
}

- (UINavigationController *)newMessages {
    UINavigationController *nc = [[UINavigationController alloc] init];
    nc.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Сообщения"
        image:[UIImage imageNamed:@"tabbar-messages.png"]
        tag:0];
    [self setupChild:nc];
    return nc;
}

- (UINavigationController *)newLogout {
    UINavigationController *nc = [[UINavigationController alloc] init];
    nc.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Выйти"
        image:[UIImage imageNamed:@"tabbar-logout.png"]
        tag:0];
    [self setupChild:nc];
    return nc;
}

- (void)setupChild:(UINavigationController *)nc {
    [nc.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    nc.navigationBar.shadowImage = [[UIImage alloc] init];
    nc.navigationBar.translucent = YES;
    nc.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (BOOL)  tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == self.messages) {
        IQMessagesController *mc = [[IQMessagesController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mc];
        [self presentViewController:nc animated:YES completion:nil];
        return NO;
    }
    if (viewController == self.logout) {
        [IQChannels logout];
        [_appDelegate switchToLogin];
        return NO;
    }
    return YES;
}
@end

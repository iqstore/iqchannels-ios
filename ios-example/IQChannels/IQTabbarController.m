//
//  IQTabbarController.m
//  IQChannels
//
//  Created by Ivan Korobkov on 12/09/16.
//  Copyright © 2016 Ivan Korobkov. All rights reserved.
//

#import <IQChannels/SDK.h>
#import <IQChannels/IQSubscription.h>
#import "IQTabbarController.h"
#import "IQAppDelegate.h"
#import "IQExpensesController.h"
#import "IQMessagesController.h"


@interface IQTabbarController () <UITabBarControllerDelegate, IQChannelsUnreadListener>
@property(nonatomic) UINavigationController *expenses;
@property(nonatomic) UINavigationController *messages;
@property(nonatomic) UINavigationController *logout;
@end


@implementation IQTabbarController {
    IQSubscription *_unreadSub;
}

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _unreadSub = [IQChannels unread:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [_unreadSub unsubscribe];
    _unreadSub = nil;
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
    UINavigationController *nc = [[UINavigationController alloc]
            initWithRootViewController:[[IQChannelMessagesViewController alloc] init]];
    nc.tabBarItem = [[UITabBarItem alloc]
            initWithTitle:@"Сообщения"
                    image:[UIImage imageNamed:@"tabbar-messages.png"]
                      tag:0];
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
    if (viewController == self.logout) {
        [IQChannels logout];
        [_appDelegate switchToLogin];
        return NO;
    }
    return YES;
}

#pragma mark IQChannelsUnreadListener

- (void)iq_unreadChanged:(NSInteger)unread {
    if (unread == 0) {
        self.messages.tabBarItem.badgeValue = nil;
    } else {
        self.messages.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long) unread];
    }
}
@end

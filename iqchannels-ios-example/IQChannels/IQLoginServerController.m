//
//  IQLoginServerController.m
//  IQChannels
//
//  Created by Ivan Korobkov on 17/09/16.
//  Copyright © 2016 Ivan Korobkov. All rights reserved.
//

#import "IQLoginServerController.h"

@interface IQLoginServerController ()
@property(weak, nonatomic) IBOutlet UITextField *serverTextField;
@property(nonatomic) void (^callback)(NSString *);
@end


@implementation IQLoginServerController
+ (UINavigationController *)controllerWithCallback:(void (^)(NSString *))callback {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IQLogin" bundle:[NSBundle mainBundle]];
    IQLoginServerController *controller = [storyboard instantiateViewControllerWithIdentifier:@"serverController"];
    controller.callback = callback;
    return [[UINavigationController alloc] initWithRootViewController:controller];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Сервер";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done:(id)sender {
    _callback(_serverTextField.text);
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

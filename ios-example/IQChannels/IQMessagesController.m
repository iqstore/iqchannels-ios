//
//  IQMessagesController.m
//  IQChannels
//
//  Created by Ivan Korobkov on 12/09/16.
//  Copyright © 2016 Ivan Korobkov. All rights reserved.
//

#import "IQMessagesController.h"


@interface IQMessagesController ()
@end


@implementation IQMessagesController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Сообщения";
    
    if (self.displayCloseButton) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    }
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
        action:@selector(close)];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

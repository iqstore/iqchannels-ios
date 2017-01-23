//
//  IQExpensesController.m
//  IQChannels
//
//  Created by Ivan Korobkov on 12/09/16.
//  Copyright © 2016 Ivan Korobkov. All rights reserved.
//

#import "IQExpensesController.h"

@interface IQExpensesController ()
@property(nonatomic) UIImage *image;
@end

@implementation IQExpensesController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup image.
    self.image = [UIImage imageNamed:@"expenses.png"];

    // Setup navbar.
    self.navigationItem.title = @"Расходы";

    // Setup tableView.
    self.tableView.backgroundView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"background.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image"];
    if (cell != nil) {
        return cell;
    }

    cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.opaque = NO;

    CGRect frame = imageView.frame;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = (self.image.size.height * width) / self.image.size.width;
    imageView.frame = CGRectMake(frame.origin.x, frame.origin.y, width, height);

    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:imageView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    h -= [UIApplication sharedApplication].statusBarFrame.size.height;
    if (self.navigationController) {
        UINavigationController *nc = self.navigationController;
        h -= nc.navigationBar.frame.size.height;
        h -= nc.tabBarController.tabBar.frame.size.height;
    }
    return h;
}
@end

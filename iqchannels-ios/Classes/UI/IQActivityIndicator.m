//
//  IQActivityIndicator.m
//  Pods
//
//  Created by Ivan Korobkov on 11/10/2016.
//
//

#import "IQActivityIndicator.h"

@implementation IQActivityIndicator
+ (instancetype)activityIndicator {
    NSBundle *bundle = [NSBundle bundleForClass:self];
    return [bundle loadNibNamed:@"IQActivityIndicator" owner:nil options:nil][0];
}

- (void)startAnimating {
    [self.indicator startAnimating];
    self.hidden = NO;
}

- (void)stopAnimating {
    [self.indicator stopAnimating];
    self.hidden = YES;
}
@end

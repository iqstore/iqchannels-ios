//
//  IQActivityIndicator.h
//  Pods
//
//  Created by Ivan Korobkov on 11/10/2016.
//
//

#import <UIKit/UIKit.h>

@interface IQActivityIndicator : UIView
@property(unsafe_unretained, nonatomic) IBOutlet UILabel *label;
@property(unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

+ (instancetype)activityIndicator;
- (void)startAnimating;
- (void)stopAnimating;
@end

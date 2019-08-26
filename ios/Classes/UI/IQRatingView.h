//
//  IQRatingView.h
//  IQChannels
//
//  Created by Ivan Korobkov on 26/08/2019.
//

#import <UIKit/UIKit.h>
#import "IQRating.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQRatingView : UIView
+ (instancetype)viewWithRating:(IQRating *)rating;
@end

NS_ASSUME_NONNULL_END

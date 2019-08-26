//
//  IQRatingMediaItem.h
//  IQChannels
//
//  Created by Ivan Korobkov on 26/08/2019.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMediaItem.h>
#import "IQRating.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQRatingMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>
- (instancetype _Nonnull)initWithRating:(IQRating *_Nonnull)rating;
@end

NS_ASSUME_NONNULL_END

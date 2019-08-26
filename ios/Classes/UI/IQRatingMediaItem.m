//
//  IQRatingMediaItem.m
//  IQChannels
//
//  Created by Ivan Korobkov on 26/08/2019.
//

#import "IQRatingMediaItem.h"
#import "IQRatingView.h"
#import "IQRating.h"
#import <JSQMessagesViewController/JSQMessagesMediaViewBubbleImageMasker.h>

@implementation IQRatingMediaItem {
    IQRating *_rating;
    IQRatingView *_ratingView;
}

- (instancetype _Nonnull)initWithRating:(IQRating *_Nonnull)rating {
    self = [super init];
    
    _rating = rating;
    return self;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView {
    if (_ratingView) {
        return _ratingView;
    }
    
    _ratingView = [IQRatingView viewWithRating:_rating];
    [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:_ratingView isOutgoing:NO];
    return _ratingView;
}

- (NSString *)mediaDataType {
    return @"rating";
}

- (CGSize)mediaViewDisplaySize {
    return CGSizeMake(260.0f, 105.0f);
}
@end

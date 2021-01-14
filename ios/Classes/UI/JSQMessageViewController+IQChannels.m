//
//  JSQMessageViewController+IQChannels.m
//  IQChannels
//
//  Created by Ivan Korobkov on 14.01.2021.
//

#import "JSQMessageViewController+IQChannels.h"


@implementation JSQMessagesMediaViewBubbleImageMasker (IQChannels)
- (void)jsq_maskView:(UIView *)view withImage:(UIImage *)image
{
    NSParameterAssert(view != nil);
    NSParameterAssert(image != nil);
    
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 2.0f, 2.0f);
    
    if (@available(iOS 14.0, *)) {
        view.maskView = imageViewMask;
    } else {
        view.layer.mask = imageViewMask.layer;
    }
}
@end

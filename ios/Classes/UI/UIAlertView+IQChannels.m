//
// Created by Ivan Korobkov on 11/10/2016.
//

#import "UIAlertView+IQChannels.h"
#import "SDK.h"


@implementation UIAlertView (IQChannels)
+ (UIAlertView *_Nonnull)iq_alertViewWithError:(NSError *_Nonnull)error {
    return [[UIAlertView alloc] initWithTitle:[NSBundle iq_channelsLocalizedStringForKey:@"iqchannels.error" value:@"Ошибка"]
        message:error.localizedDescription
        delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
}
@end

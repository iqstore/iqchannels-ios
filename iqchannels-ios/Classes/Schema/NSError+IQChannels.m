//
// Created by Ivan Korobkov on 06/09/16.
//

#import "NSError+IQChannels.h"
#import "IQError.h"
#import "NSBundle+IQChannels.h"


NSString *const IQErrorDomain = @"ru.iqstore.iqchannels";
NSString *const IQErrorUserInfoKey = @"ru.iqstore.error";

NSInteger const IQErrorUnknown = 1;
NSInteger const IQErrorAppError = 2;
NSInteger const IQErrorClientError = 3;


@implementation NSError (IQChannels)
+ (NSError *_Nonnull)iq_authRequired {
    return [self iq_appErrorWithLocalizedDescription:
        [NSBundle iq_channelsLocalizedStringForKey:@"errors.auth_required" value:@"Authentication required"]];
}

+ (NSError *)iq_appErrorWithLocalizedDescription:(NSString *_Nullable)text {
    if (text == nil) {
        text = NSLocalizedString(@"Unknown error", nil);
    }
    return [NSError errorWithDomain:IQErrorDomain code:IQErrorAppError
        userInfo:@{NSLocalizedDescriptionKey: text}];
}

+ (NSError *)iq_clientError {
    return [self iq_clientErrorWithLocalizedDescription:nil];
}

+ (NSError *)iq_clientErrorWithLocalizedDescription:(NSString *_Nullable)text {
    if (text == nil) {
        text = NSLocalizedString(@"Client error", nil);
    }
    return [NSError errorWithDomain:IQErrorDomain code:IQErrorClientError
        userInfo:@{NSLocalizedDescriptionKey: text}];
}

+ (NSError *)iq_withIQError:(IQError *)error {
    if (error == nil) {
        return [NSError errorWithDomain:IQErrorDomain code:IQErrorUnknown
            userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown error", nil)}];
    }

    NSString *text = error.Text ? error.Text : NSLocalizedString(@"Unknown error", nil);
    return [NSError errorWithDomain:IQErrorDomain code:IQErrorAppError
        userInfo:@{
            NSLocalizedDescriptionKey: text,
            IQErrorUserInfoKey: error,
        }];
}

- (BOOL)iq_isAppError {
    return [self iq_appError] != nil;
}

- (IQError *)iq_appError {
    return self.userInfo[IQErrorUserInfoKey];
}

- (UIAlertView *)iq_toAlertView {
    return [[UIAlertView alloc] initWithTitle:@"Ошибка" message:self.localizedDescription delegate:nil
        cancelButtonTitle:@"OK" otherButtonTitles:nil];
}
@end

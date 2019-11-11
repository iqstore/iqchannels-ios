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
+ (NSError *_Nonnull)iq_loggedOut {
    return [self iq_appErrorWithLocalizedDescription:
        [NSBundle iq_channelsLocalizedStringForKey:@"errors.logged_out" value:@"Logged out"]];
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

- (BOOL)iq_isAuthError {
    if (![self iq_isAppError]) {
        return NO;
    }
    
    IQError *error = self.iq_appError;
    if (!error) {
        return nil;
    }
    
    return [error.Code isEqualToString:IQErrorCodeUnauthorized];
}

- (IQError *)iq_appError {
    return self.userInfo[IQErrorUserInfoKey];
}
@end

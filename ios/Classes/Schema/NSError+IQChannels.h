//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>

@class IQError;


extern NSString *_Nonnull const IQErrorDomain;
extern NSString *_Nonnull const IQErrorUserInfoKey;

extern NSInteger const IQErrorUnknown;
extern NSInteger const IQErrorAppError;
extern NSInteger const IQErrorClientError;


@interface NSError (IQChannels)
+ (NSError *_Nonnull)iq_loggedOut;
+ (NSError *_Nonnull)iq_appErrorWithLocalizedDescription:(NSString *_Nullable)text;
+ (NSError *_Nonnull)iq_clientError;
+ (NSError *_Nonnull)iq_clientErrorWithLocalizedDescription:(NSString *_Nullable)text;
+ (NSError *_Nonnull)iq_withIQError:(IQError *_Nullable)error;

- (BOOL)iq_isAppError;
- (BOOL)iq_isAuthError;
- (IQError *_Nullable)iq_appError;
@end

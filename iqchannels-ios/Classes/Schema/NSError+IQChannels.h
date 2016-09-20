//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>

@class IQError;


extern NSString *const IQErrorDomain;
extern NSString *const IQErrorUserInfoKey;

extern NSInteger const IQErrorUnknown;
extern NSInteger const IQErrorAppError;
extern NSInteger const IQErrorClientError;


@interface NSError (IQChannels)
+ (NSError *_Nonnull)iq_authRequired;
+ (NSError *_Nonnull)iq_appErrorWithLocalizedDescription:(NSString *_Nullable)text;

+ (NSError *_Nonnull)iq_clientError;
+ (NSError *_Nonnull)iq_clientErrorWithLocalizedDescription:(NSString *_Nullable)text;
+ (NSError *_Nonnull)iq_withIQError:(IQError *_Nullable)error;

- (BOOL)iq_isAppError;
- (IQError *_Nullable)iq_appError;

- (UIAlertView *_Nonnull)iq_toAlertView;
@end

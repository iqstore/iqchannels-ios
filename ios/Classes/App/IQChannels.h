//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>


@class IQSubscription;
@class IQChannelsConfig;
@class IQChatMessageForm;
@protocol IQChannelsStateListener;
@protocol IQChannelsMessagesListener;
@protocol IQChannelsUnreadListener;
@protocol IQChannelsMoreMessagesListener;


@interface IQChannels : NSObject

// Configuration

+ (void)configure:(IQChannelsConfig *_Nonnull)config;
+ (void)pushToken:(NSData *_Nullable)token;
+ (IQSubscription *_Nonnull)state:(id <IQChannelsStateListener> _Nonnull)listener;

// Login/logout

+ (void)login:(NSString *_Nullable)credentials;
+ (void)loginAnonymous;
+ (void)logout;

// Chat

+ (IQSubscription *_Nonnull)unread:(id <IQChannelsUnreadListener> _Nonnull)listener;
+ (IQSubscription *_Nonnull)messages:(id <IQChannelsMessagesListener> _Nonnull)listener;
+ (IQSubscription *_Nonnull)moreMessages:(id <IQChannelsMoreMessagesListener> _Nonnull)listener;
+ (void)loadMessageMedia:(int64_t)messageId;
+ (void)typing;
+ (void)sendText:(NSString *_Nonnull)text;
+ (void)sendImage:(UIImage *_Nonnull)image filename:(NSString *_Nullable)filename;
+ (void)deleteFailedUpload:(int64_t)localId;
+ (void)retryUpload:(int64_t)localId;
+ (void)markAsRead:(int64_t)messageId;
+ (void)rate:(int64_t)ratingId value:(int32_t)value;
@end

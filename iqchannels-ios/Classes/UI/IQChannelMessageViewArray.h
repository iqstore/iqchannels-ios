//
// Created by Ivan Korobkov on 11/10/2016.
//

#import <Foundation/Foundation.h>
#import "SDK.h"

@class IQChannelMessageViewData;
@class IQChannelMessage;


@interface IQChannelMessageViewArray : NSObject
@property(nonatomic, readonly, nonnull) NSArray<IQChannelMessageViewData *> *items;
@property(nonatomic, readonly, nullable) NSNumber *minMessageId;
@property(nonatomic, readonly, nullable) NSNumber *maxEventId;

- (instancetype _Nonnull)initWithClientId:(int64_t)clientId;
- (instancetype _Nonnull)initWithClientId:(int64_t)clientId messages:(NSArray<IQChannelMessage *> *_Nullable)messages;

- (void)appendMessages:(NSArray<IQChannelMessage *> *_Nullable)messages;
- (void)prependMessages:(NSArray<IQChannelMessage *> *_Nullable)messages;
- (void)appendMessage:(IQChannelMessage *_Nonnull)message;
- (void)applyEvent:(IQChannelEvent *_Nonnull)event created:(BOOL *)created updated:(NSUInteger *)updated;
@end

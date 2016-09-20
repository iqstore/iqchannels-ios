//
//  IQChannelThread.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

@class IQChannel;
@class IQClient;
@class IQRelationMap;
@class IQChannelEvent;
@class IQChannelMessage;
@class IQChannelMessage;


@interface IQChannelThread : NSObject <IQJSONDecodable, NSCopying>
@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t ChannelId;
@property(nonatomic) int64_t ClientId;
@property(nonatomic, copy, nullable) NSNumber *EventId;

@property(nonatomic) int32_t ClientUnread;
@property(nonatomic) int32_t UserUnread;

@property(nonatomic) int64_t CreatedAt;
@property(nonatomic) int64_t UpdatedAt;

// Transitive
@property(nonatomic, nullable) NSMutableArray<IQChannelMessage *> *Messages;

// Local
@property(nonatomic) int64_t UserTypingAt;
@property(nonatomic) int64_t ClientTypingAt;

- (instancetype _Nonnull)init;
+ (NSArray<IQChannelThread *> *_Nonnull)fromJSONArray:(id _Nullable)array;

- (void)applyEvent:(IQChannelEvent *_Nullable)event;
- (void)applyEvents:(NSArray<IQChannelEvent *> *_Nullable)events;

- (void)appendMessage:(IQChannelMessage *_Nullable)message;
- (void)appendOutgoingMessage:(IQChannelMessage *_Nullable)message;
- (void)prependMessages:(NSArray<IQChannelMessage *> *_Nullable)messages;
@end

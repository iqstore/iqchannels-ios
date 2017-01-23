//
//  IQChat.h
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
@class IQChatEvent;
@class IQChatMessage;
@class IQChatMessage;
@class IQUser;


@interface IQChat : NSObject <IQJSONDecodable>
@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t ChannelId;
@property(nonatomic) int64_t ClientId;
@property(nonatomic) BOOL Open;

@property(nonatomic, copy, nullable) NSNumber *EventId;
@property(nonatomic, copy, nullable) NSNumber *MessageId;
@property(nonatomic, copy, nullable) NSNumber *SessionId;
@property(nonatomic, copy, nullable) NSNumber *AssigneeId;

@property(nonatomic) int32_t ClientUnread;
@property(nonatomic) int32_t UserUnread;
@property(nonatomic) int32_t TotalMembers;

@property(nonatomic) int64_t CreatedAt;
@property(nonatomic, copy, nullable) NSNumber *OpenedAt;
@property(nonatomic, copy, nullable) NSNumber *ClosedAt;

// Relations
@property (nonatomic, nullable) IQClient *Client;
@property (nonatomic, nullable) IQChatMessage *Message;
@property (nonatomic, nullable) IQChannel *Channel;

- (instancetype _Nonnull)init;

+ (NSArray<IQChat *> *_Nonnull)fromJSONArray:(id _Nullable)array;
@end

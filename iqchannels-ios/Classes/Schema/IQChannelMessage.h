//
//  IQChannelMessage.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//
#import <Foundation/Foundation.h>
#import <JSQMessagesViewController/JSQMessageData.h>
#import "IQSchemaConsts.h"
#import "IQJSONDecodable.h"


@class IQUser;
@class IQClient;
@class IQChannelMessageForm;
@class IQChannelEvent;


@interface IQChannelMessage : NSObject <NSCopying, JSQMessageData, IQJSONDecodable>
@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t ThreadId;
@property(nonatomic) int64_t LocalId;

// Author
@property(nonatomic, copy, nullable) IQChannelAuthorType Author;
@property(nonatomic, copy, nullable) NSNumber *ClientId;
@property(nonatomic, copy, nullable) NSNumber *UserId;

// Payload
@property(nonatomic, copy, nullable) IQChannelPayloadType Payload;
@property(nonatomic, copy, nullable) NSString *Text;
@property(nonatomic, copy, nullable) NSNumber *EventId;

// Flags
@property(nonatomic) BOOL Received;
@property(nonatomic) BOOL Read;

@property(nonatomic) int64_t CreatedAt;
@property(nonatomic) int64_t UpdatedAt;
@property(nonatomic, copy, nullable) NSNumber *ReceivedAt;
@property(nonatomic, copy, nullable) NSNumber *ReadAt;

// Relations
@property(nonatomic, nullable) IQUser *User;
@property(nonatomic, nullable) IQClient *Client;

+ (NSString *)senderIdWithClientId:(int64_t)id;
+ (NSArray<IQChannelMessage *> *_Nonnull)fromJSONArray:(id _Nullable)array;

- (id)initWithClientId:(int64_t)clientId form:(IQChannelMessageForm *)form;
- (void)applyEvent:(IQChannelEvent *)event;
@end

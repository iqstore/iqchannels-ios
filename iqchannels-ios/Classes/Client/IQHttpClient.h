//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQCancel.h"

@class IQChannel;
@class IQChannelMessage;
@class IQChannelEvent;
@class IQChannelEventsQuery;
@class IQChannelThread;
@class IQChannelThreadQuery;
@class IQChannelMessageForm;
@class IQChannelMessagesQuery;
@class IQClientAuth;
@class IQClientSession;
@class IQLogging;
@class IQRelations;

typedef void (^IQHttpVoidCallback)(NSError *);
typedef void (^IQHttpClientAutCallback)(IQClientAuth *, IQRelations *, NSError *);
typedef void (^IQHttpThreadCallback)(IQChannelThread *, IQRelations *rels, NSError *);
typedef void (^IQHttpMessagesCallback)(NSArray<IQChannelMessage *> *, IQRelations *rels, NSError *);
typedef void (^IQHttpEventsCallback)(NSArray<IQChannelEvent *> *, IQRelations *rels, NSError *);
typedef void (^IQHttpUnreadCallback)(NSNumber *, NSError *);


@interface IQHttpClient : NSObject
@property(nonatomic) NSString *address;
@property(nonatomic) NSString *token;

- (instancetype)initWithLogging:(IQLogging *)logging address:(NSString *)address;
- (instancetype)initWithLogging:(IQLogging *)logging address:(NSString *)address token:(NSString *)token;

// Clients
- (IQCancel)clientAuth:(NSString *)token callback:(IQHttpClientAutCallback)callback;
- (IQCancel)clientIntegrationAuth:(NSString *)credentials callback:(IQHttpClientAutCallback)callback;

// Threads
- (IQCancel)channel:(NSString *)channel thread:(IQChannelThreadQuery *)query callback:(IQHttpThreadCallback)callback;
- (IQCancel)channel:(NSString *)channel typingCallback:(IQHttpVoidCallback)callback;

// Messages
- (IQCancel)channel:(NSString *)channel sendForm:(IQChannelMessageForm *)form callback:(IQHttpVoidCallback)callback;
- (IQCancel)receivedMessages:(NSArray<NSNumber *> *)messageIds callback:(IQHttpVoidCallback)callback;
- (IQCancel)readMessages:(NSArray<NSNumber *> *)messageIds callback:(IQHttpVoidCallback)callback;
- (IQCancel)channel:(NSString *)channel messages:(IQChannelMessagesQuery *)query callback:(IQHttpMessagesCallback)callback;

// Events
- (IQCancel)channel:(NSString *)channel listen:(IQChannelEventsQuery *)query callback:(IQHttpEventsCallback)callback;
- (IQCancel)channel:(NSString *)channel unreadWithCallback:(IQHttpUnreadCallback)callback;
@end

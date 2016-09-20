//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQCancel.h"

@class IQChannel;
@class IQRelations;
@class IQChannelMessage;
@class IQChannelEvent;
@class IQChannelEventsQuery;
@class IQLogging;
@class IQChannelThread;
@class IQClientSession;
@class IQChannelThreadQuery;
@class IQChannelMessageForm;
@class IQChannelMessagesQuery;


typedef void (^IQHttpVoidCallback)(NSError *);
typedef void (^IQHttpSessionCallback)(IQClientSession *, IQRelations *, NSError *);
typedef void (^IQHttpThreadCallback)(IQChannelThread *, IQRelations *rels, NSError *);
typedef void (^IQHttpMessagesCallback)(NSArray<IQChannelMessage *> *, IQRelations *rels, NSError *);
typedef void (^IQHttpEventsCallback)(NSArray<IQChannelEvent *> *, IQRelations *rels, NSError *);


@interface IQHttpClient : NSObject
@property(nonatomic) NSString *address;
@property(nonatomic) NSString *token;

- (instancetype)initWithLogging:(IQLogging *)logging address:(NSString *)address;

// Clients
- (IQCancel)clientAuth:(NSString *)token callback:(IQHttpSessionCallback)callback;
- (IQCancel)clientAuthExternal:(NSString *)token callback:(IQHttpSessionCallback)callback;

// Threads
- (IQCancel)channel:(NSString *)channel thread:(IQChannelThreadQuery *)query callback:(IQHttpThreadCallback)callback;
- (IQCancel)channel:(NSString *)channel typingCallback:(IQHttpVoidCallback)callback;

// Messages
- (IQCancel)channel:(NSString *)channel sendForm:(IQChannelMessageForm *)form callback:(IQHttpVoidCallback)callback;
- (IQCancel)channel:(NSString *)channel received:(NSArray<NSNumber *> *)messageIds
           callback:(IQHttpVoidCallback)callback;
- (IQCancel)channel:(NSString *)channel read:(NSArray<NSNumber *> *)messageIds callback:(IQHttpVoidCallback)callback;
- (IQCancel)channel:(NSString *)channel messages:(IQChannelMessagesQuery *)query
           callback:(IQHttpMessagesCallback)callback;

// Events
- (IQCancel)channel:(NSString *)channel listen:(IQChannelEventsQuery *)query callback:(IQHttpEventsCallback)callback;
@end

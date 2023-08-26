//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQResult.h"


@class IQChannel;
@class IQChatMessage;
@class IQChatEvent;
@class IQChatEventQuery;
@class IQChat;
@class IQChatMessageForm;
@class IQMaxIdQuery;
@class IQClientAuth;
@class IQClientSession;
@class IQRelations;
@class IQLog;
@class IQHttpRequest;
@class IQRelationService;
@class IQFile;
@class IQFileToken;


typedef void (^IQHttpVoidCallback)(NSError *);
typedef void (^IQHttpClientAutCallback)(IQClientAuth *, NSError *);
typedef void (^IQHttpClientSignupCallback)(IQClientAuth *, NSError *);
typedef void (^IQHttpChatCallback)(IQChat *, NSError *);
typedef void (^IQHttpMessagesCallback)(NSArray<IQChatMessage *> *, NSError *);
typedef void (^IQHttpEventsCallback)(NSArray<IQChatEvent *> *, NSError *);
typedef void (^IQHttpUnreadCallback)(NSNumber *, NSError *);
typedef void (^IQHttpFileCallback)(IQFile *, NSError *);
typedef void (^IQHttpFileTokenCallback)(IQFileToken *, NSError *);


@interface IQHttpClient : NSObject
@property(nonatomic) NSString *address;
@property(nonatomic) NSString *token;

- (instancetype)initWithLog:(IQLog *)log relations:(IQRelationService *)relations address:(NSString *)address;
- (void)setCustomeHeaders:(NSDictionary<NSString*, NSString*>*)headers;

// Clients

- (IQHttpRequest *)clientsSignup:(NSString *)channel callback:(IQHttpClientSignupCallback)callback;
- (IQHttpRequest *)clientsAuth:(NSString *)token callback:(IQHttpClientAutCallback)callback;
- (IQHttpRequest *)clientsIntegrationAuth:(NSString *)credentials channel:(NSString *)channel callback:(IQHttpClientAutCallback)callback;

// Chats channel

- (IQHttpRequest *)chatsChannel:(NSString *)channel chat:(IQHttpChatCallback)callback;
- (IQHttpRequest *)chatsChannel:(NSString *)channel messages:(IQMaxIdQuery *)query callback:(IQHttpMessagesCallback)callback;
- (IQHttpRequest *)chatsChannel:(NSString *)channel typing:(IQHttpVoidCallback)callback;
- (IQHttpRequest *)chatsChannel:(NSString *)channel send:(IQChatMessageForm *)form callback:(IQHttpVoidCallback)callback;
- (IQHttpRequest *)chatsChannel:(NSString *)channel events:(IQChatEventQuery *)query callback:(IQHttpEventsCallback)callback;
- (IQHttpRequest *)chatsChannel:(NSString *)channel unread:(IQHttpUnreadCallback)callback;

// Chats messages

- (IQHttpRequest *)chatsMessagesReceived:(NSArray<NSNumber *> *)messageIds callback:(IQHttpVoidCallback)callback;
- (IQHttpRequest *)chatsMessagesRead:(NSArray<NSNumber *> *)messageIds callback:(IQHttpVoidCallback)callback;

// Files

- (IQHttpRequest *)filesUploadImage:(NSString *)filename data:(NSData *)data callback:(IQHttpFileCallback)callback;
- (IQHttpRequest *)filesUploadData:(NSString *)filename data:(NSData *)data callback:(IQHttpFileCallback)callback;
- (IQHttpRequest *)filesToken:(NSString *)fileId callback:(IQHttpFileTokenCallback)callback;
- (NSURL *)fileURL:(NSString *)fileId token:(NSString *)token;

// Ratings

- (IQHttpRequest *)ratingsRate:(int64_t)ratingId value:(int32_t)value callback:(IQHttpVoidCallback)callback;
- (IQHttpRequest *)ratingsIgnore:(int64_t)ratingId callback:(IQHttpVoidCallback)callback;

// Push

- (IQHttpRequest *)pushChannel:(NSString *)channel apnsToken:(NSString *)token callback:(IQHttpVoidCallback)callback;
@end

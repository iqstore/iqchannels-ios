//
//  IQChatMessage.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//
#import <Foundation/Foundation.h>
#import <JSQMessagesViewController/JSQMessageData.h>
#import "IQJSONDecodable.h"
#import "IQActorType.h"
#import "IQChatPayloadType.h"
#import "IQSingleChoice.h"
#import "IQAction.h"


@class IQUser;
@class IQClient;
@class IQChatMessageForm;
@class IQChatEvent;
@class IQFile;
@class IQRating;
@class IQSingleChoice;


@interface IQChatMessage : NSObject <IQJSONDecodable, JSQMessageData>
@property(nonatomic) int64_t Id;
@property(nonatomic, copy, nullable) NSString *UID;
@property(nonatomic) int64_t ChatId;
@property(nonatomic) int64_t SessionId;
@property(nonatomic) int64_t LocalId;
@property(nonatomic, copy, nullable) NSNumber *EventId;
@property(nonatomic) BOOL Public;

// Author
@property(nonatomic, copy, nullable) IQActorType Author;
@property(nonatomic, copy, nullable) NSNumber *ClientId;
@property(nonatomic, copy, nullable) NSNumber *UserId;

// Payload
@property(nonatomic, copy, nullable) IQChatPayloadType Payload;
@property(nonatomic, copy, nullable) NSString *Text;
@property(nonatomic, copy, nullable) NSString *FileId;
@property(nonatomic, copy, nullable) NSNumber *RatingId;
@property(nonatomic, copy, nullable) NSNumber *NoticeId;
@property(nonatomic, copy, nullable) NSString *BotpressPayload;

// Flags
@property(nonatomic) BOOL Received;
@property(nonatomic) BOOL Read;
@property(nonatomic) BOOL DisableFreeText;
@property(nonatomic) BOOL IsDropDown;

// Timestamps
@property(nonatomic) int64_t CreatedAt;
@property(nonatomic, copy, nullable) NSNumber *ReceivedAt;
@property(nonatomic, copy, nullable) NSNumber *ReadAt;

// Transitive
@property(nonatomic) BOOL My;

// Relations
@property(nonatomic, nullable) IQClient *Client;
@property(nonatomic, nullable) IQUser *User;
@property(nonatomic, nullable) IQFile *File;
@property(nonatomic, nullable) IQRating *Rating;

@property(nonatomic, nullable) NSDate *CreatedDate;
@property(nonatomic, nullable) NSDateComponents *CreatedComponents;

// JSQMessageData
@property(nonatomic, copy, nullable) NSString *senderId;
@property(nonatomic, copy, nullable) NSString *senderDisplayName;
@property(nonatomic, nullable) NSDate *date;
@property(nonatomic) NSUInteger messageHash;

@property(nonatomic, readonly) BOOL isMediaMessage;
@property(nonatomic, readonly) BOOL isFileMessage;    // To display a simple file link.
@property(nonatomic, nullable, readonly) NSString *text;
@property(nonatomic, nullable, readonly) id <JSQMessageMediaData> media;

// Local
@property(nonatomic, nullable) UIImage *UploadImage;
@property(nonatomic, nullable) NSData *UploadData;
@property(nonatomic, copy, nullable) NSString *UploadFilename;
@property(nonatomic) BOOL Uploaded;
@property(nonatomic) BOOL Uploading;
@property(nonatomic, nullable) NSError *UploadError;

// Single choices
@property(nonatomic, copy, nullable) NSArray<IQSingleChoice *> *SingleChoices;
@property(nonatomic, copy, nullable) NSArray<IQAction *> *Actions;

+ (NSArray<IQChatMessage *> *_Nonnull)fromJSONArray:(id _Nullable)array;

- (instancetype _Nonnull)init;

- (instancetype _Nonnull)initWithClient:(IQClient *_Nonnull)client
                                localId:(int64_t)localId
                                   text:(NSString *_Nonnull)text;

- (instancetype _Nonnull)initWithClient:(IQClient *_Nonnull)client
                                localId:(int64_t)localId
                                  image:(UIImage *_Nonnull)image
                               fileName:(NSString *_Nonnull)fileName;

- (instancetype _Nonnull)initWithClient:(IQClient *_Nonnull)client
                                localId:(int64_t)localId
                                   data:(NSData *_Nonnull)data
                               fileName:(NSString *_Nonnull)fileName;

- (void)mergeWithCreatedMessage:(IQChatMessage *_Nonnull)message;
@end

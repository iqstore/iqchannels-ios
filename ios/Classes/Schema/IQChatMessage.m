//
//  IQChatcopy.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChatMessage.h"
#import "IQJSON.h"
#import "IQUser.h"
#import "IQClient.h"
#import "IQChatMessageForm.h"
#import "IQFile.h"
#import "IQFileSize.h"
#import "IQRating.h"
#import "IQRatingMediaItem.h"
#import "IQRatingState.h"
#import "JSQPhotoMediaItem.h"


@implementation IQChatMessage {
    id <JSQMessageMediaData> _media;
}

+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQChatMessage *message = [[IQChatMessage alloc] init];
    message.Id = [IQJSON int64FromObject:object key:@"Id"];
    message.UID = [IQJSON stringFromObject:object key:@"UID"];
    message.ChatId = [IQJSON int64FromObject:object key:@"ChatId"];
    message.SessionId = [IQJSON int64FromObject:object key:@"SessionId"];
    message.LocalId = [IQJSON int64FromObject:object key:@"LocalId"];
    message.EventId = [IQJSON numberFromObject:object key:@"EventId"];
    message.Public = [IQJSON boolFromObject:object key:@"Public"];

    message.Author = [IQJSON stringFromObject:object key:@"Author"];
    message.ClientId = [IQJSON numberFromObject:object key:@"ClientId"];
    message.UserId = [IQJSON numberFromObject:object key:@"UserId"];

    message.Payload = [IQJSON stringFromObject:object key:@"Payload"];
    message.Text = [IQJSON stringFromObject:object key:@"Text"];
    message.FileId = [IQJSON stringFromObject:object key:@"FileId"];
    message.RatingId = [IQJSON numberFromObject:object key:@"RatingId"];
    message.NoticeId = [IQJSON numberFromObject:object key:@"NoticeId"];
    message.BotpressPayload = [IQJSON stringFromObject:object key:@"BotpressPayload"];

    message.Received = [IQJSON boolFromObject:object key:@"Received"];
    message.Read = [IQJSON boolFromObject:object key:@"Read"];
    message.DisableFreeText = [IQJSON boolFromObject:object key:@"DisableFreeText"];
    message.IsDropDown = [IQJSON boolFromObject:object key:@"IsDropDown"];

    message.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    message.ReceivedAt = [IQJSON numberFromObject:object key:@"ReceivedAt"];
    message.ReadAt = [IQJSON numberFromObject:object key:@"ReadAt"];

    message.My = [IQJSON boolFromObject:object key:@"My"];

    message.SingleChoices = [IQSingleChoice fromJSONArray:[IQJSON arrayFromObject:object key:@"SingleChoices"]];
    message.Actions = [IQAction fromJSONArray:[IQJSON arrayFromObject:object key:@"Actions"]];

    return message;
}

+ (NSArray<IQChatMessage *> *_Nonnull)fromJSONArray:(id _Nullable)array {
    if (array == nil) {
        return @[];
    }
    if (![array isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<IQChatMessage *> *messages = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQChatMessage *user = [IQChatMessage fromJSONObject:item];
        if (user == nil) {
            continue;
        }

        [messages addObject:user];
    }
    return messages;
}

- (instancetype)init {
    return self = [super init];
}

- (instancetype)initWithClient:(IQClient *)client localId:(int64_t)localId {
    if (!(self = [super init])) {
        return nil;
    }

    _LocalId = localId;
    _Public = YES;

    // Author
    _Author = IQActorClient;
    _ClientId = @(client.Id);

    // Timestamps
    _CreatedAt = (int64_t) ([[[NSDate alloc] init] timeIntervalSince1970] * 1000);

    // Relations
    _My = YES;
    return self;
}

- (instancetype)initWithClient:(IQClient *)client localId:(int64_t)localId text:(NSString *)text {
    if (!(self = [self initWithClient:client localId:localId])) {
        return nil;
    }

    _Payload = IQChatPayloadText;
    _Text = text;
    return self;
}

- (instancetype)initWithClient:(IQClient *)client localId:(int64_t)localId image:(UIImage *)image
                      fileName:(NSString *)fileName {
    if (!(self = [self initWithClient:client localId:localId])) {
        return nil;
    }

    _Payload = IQChatPayloadFile;
    _UploadImage = image;
    _UploadFilename = fileName;
    return self;
}

- (instancetype)initWithClient:(IQClient *)client
                       localId:(int64_t)localId
                          data:(NSData *)data
                      fileName:(NSString *)fileName {
    if (!(self = [self initWithClient:client localId:localId])) {
        return nil;
    }

    _Payload = IQChatPayloadFile;
    _UploadData = data;
    _UploadFilename = fileName;
    
    return self;
}

- (void)mergeWithCreatedMessage:(IQChatMessage *)message {
    // Ids
    _Id = message.Id;
    _EventId = message.EventId;

    // Payload
    _Payload = message.Payload;
    _Text = message.text;
    _FileId = message.FileId;
    _NoticeId = message.NoticeId;
    _BotpressPayload = message.BotpressPayload;

    // Relations
    _Client = message.Client;
    _User = message.User;
    _File = message.File;

    // JSQMessageData
    _senderId = message.senderId;
    _senderDisplayName = message.senderDisplayName;
    _date = message.date;
    _messageHash = message.messageHash;
}

- (BOOL)isMediaMessage {
    if (_UploadError) {
        return NO; // Display an error message.
    }
    if (_UploadImage) {
        return YES;
    }
    
    if (self.isImageMessage) {
        return YES;
    }
    if (self.isPendingRatingMessage) {
        return YES;
    }
    return NO;
}

- (BOOL)isFileMessage {
    return _File && [_File.Type isEqualToString:IQFileTypeFile];
}

- (BOOL)isImageMessage {
    return _File && [_File.Type isEqualToString:IQFileTypeImage];
}

- (BOOL)isPendingRatingMessage {
    return _Rating != nil && [_Rating.State isEqual:IQRatingStatePending];
}

- (id <JSQMessageMediaData>)media {
    if (_media) {
        return _media;
    }
    
    if (self.isPendingRatingMessage) {
        _media = [[IQRatingMediaItem alloc] initWithRating:_Rating];
        return _media;
    }
    
    if (!self.isMediaMessage) {
        return nil;
    }
    
    _media = [[JSQPhotoMediaItem alloc] initWithImage:nil];
    return _media;
}

- (NSString *)text {
    if (_UploadError) {
        return [NSString stringWithFormat:@"Ошибка: %@", _UploadError.localizedDescription];
    }
    if (self.isFileMessage) {
        return [NSString stringWithFormat:@"%@, %@", _File.Name, [IQFileSize unitWithSize:_File.Size]];
    }
    if (_Rating) {
        if ([_Rating.State isEqual:IQRatingStateIgnored]) {
            return [NSString stringWithFormat:@"Без оценки"];
        }
        if ([_Rating.State isEqual:IQRatingStateRated]) {
            return [NSString stringWithFormat:@"Оценка оператора: %@ из 5", _Rating.Value];
        }
    }
    return _Text;
}
@end

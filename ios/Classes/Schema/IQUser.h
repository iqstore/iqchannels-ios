//
//  IQUser.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

@interface IQUser : NSObject <IQJSONDecodable>
@property(nonatomic) int64_t Id;
@property(nonatomic, copy, nullable) NSString *Name;
@property(nonatomic, copy, nullable) NSString *DisplayName;
@property(nonatomic, copy, nullable) NSString *Email;
@property(nonatomic) BOOL Online;
@property(nonatomic) BOOL Deleted;
@property(nonatomic, copy, nullable) NSString *AvatarId;

@property(nonatomic) int64_t CreatedAt;
@property(nonatomic, copy, nullable) NSNumber *LoggedInAt;
@property(nonatomic, copy, nullable) NSNumber *LastSeenAt;

// JSQ
@property(nonatomic, nullable) NSString *senderId;
@property(nonatomic, nullable) NSString *senderDisplayName;

// Local
@property(nonatomic, nullable) NSURL *AvatarURL;
@property(nonatomic, nullable) UIImage *AvatarImage;

+ (NSArray<IQUser *> *_Nonnull)fromJSONArray:(NSArray *_Nullable)array;
@end

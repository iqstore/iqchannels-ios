//
// Created by Ivan Korobkov on 17/01/2017.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"
#import "IQFileType.h"
#import "IQFileOwnerType.h"
#import "IQActorType.h"


@interface IQFile : NSObject <IQJSONDecodable>
@property(nonatomic, nonnull) NSString *Id;
@property(nonatomic, nonnull) IQFileType Type;
@property(nonatomic, nonnull) IQFileOwnerType Owner;
@property(nonatomic, nullable) NSNumber *OwnerClientId;

@property(nonatomic, nonnull) IQActorType Actor;
@property(nonatomic, nullable) NSNumber *ActorClientId;
@property(nonatomic, nullable) NSNumber *ActorUserId;

@property(nonatomic, nonnull) NSString *Name;
@property(nonatomic, nonnull) NSString *Path;
@property(nonatomic) int64_t Size;

@property(nonatomic, nullable) NSNumber *ImageWidth;
@property(nonatomic, nullable) NSNumber *ImageHeight;

@property(nonatomic, nonnull) NSString *ContentType;
@property(nonatomic) int64_t CreatedAt;

// Local
@property(nonatomic, nullable) NSURL *URL;
@property(nonatomic, nullable) NSURL *ImagePreviewURL;

- (instancetype _Nonnull)init;
+ (NSArray<IQFile *> *_Nonnull)fromJSONArray:(id _Nullable)array;
@end

//
//  IQClient.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"


@interface IQClient : NSObject <IQJSONDecodable>
@property(nonatomic) int64_t Id;
@property(nonatomic, copy, nullable) NSString *Name;
@property(nonatomic, copy, nullable) NSString *IntegrationId;
@property(nonatomic) int64_t CreatedAt;
@property(nonatomic) int64_t UpdatedAt;

// JSQ
@property(nonatomic, nullable) NSString *senderId;
@property(nonatomic, nullable) NSString *senderDisplayName;

- (instancetype _Nonnull)init;

+ (NSArray<IQClient *> *_Nonnull)fromJSONArray:(NSArray *_Nullable)array;
@end

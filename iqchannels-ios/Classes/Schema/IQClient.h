//
//  IQClient.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"


@interface IQClient : NSObject <IQJSONDecodable, NSCopying>
@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t OrgId;
@property(nonatomic, copy, nullable) NSString *ExternalId;
@property(nonatomic, copy, nullable) NSString *Name;
@property(nonatomic) int64_t CreatedAt;
@property(nonatomic) int64_t UpdatedAt;

+ (NSArray<IQClient *> *_Nonnull)fromJSONArray:(NSArray *_Nullable)array;
@end

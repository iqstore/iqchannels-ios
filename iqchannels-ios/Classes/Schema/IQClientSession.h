//
//  IQClientSession.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

@interface IQClientSession : NSObject <IQJSONDecodable, NSCopying>
@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t OrgId;
@property(nonatomic) int64_t ClientId;
@property(nonatomic, copy, nullable) NSString *Token;
@property(nonatomic) BOOL External;
@property(nonatomic, copy, nullable) NSString *ExternalId;
@property(nonatomic) int64_t CreatedAt;
@end

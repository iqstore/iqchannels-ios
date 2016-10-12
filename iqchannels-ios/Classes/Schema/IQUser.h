//
//  IQUser.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

@interface IQUser : NSObject <IQJSONDecodable, NSCopying>
@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t OrgId;
@property(nonatomic, nullable) NSString *Name;
@property(nonatomic, nullable) NSString *Email;
@property(nonatomic) BOOL Active;
@property(nonatomic) int64_t CreatedAt;
@property(nonatomic) int64_t LoggedInAt;

+ (NSArray<IQUser *> *_Nonnull)fromJSONArray:(NSArray *_Nullable)array;
@end

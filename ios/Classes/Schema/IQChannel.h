//
//  IQChannel.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

@interface IQChannel : NSObject <IQJSONDecodable>
@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t OrgId;
@property(nonatomic, copy, nullable) NSString *Name;
@property(nonatomic, copy, nullable) NSString *Title;
@property(nonatomic, copy, nullable) NSString *Description;
@property(nonatomic) BOOL Deleted;
@property(nonatomic, copy, nullable) NSNumber *EventId;
@property(nonatomic, copy, nullable) NSNumber *ChatEventId;
@property(nonatomic) int64_t CreatedAt;

+ (NSArray<IQChannel *>*_Nonnull) fromJSONArray:(id _Nullable)array;
@end

//
//  IQMaxIdQuery.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONEncodable.h"

@interface IQMaxIdQuery : NSObject <IQJSONEncodable>
@property(nonatomic, nullable) NSNumber *MaxId;
@property(nonatomic, nullable) NSNumber *Limit;

- (instancetype _Nonnull)init;
- (instancetype _Nonnull)initWithMaxId:(NSNumber *_Nullable)maxId;
@end

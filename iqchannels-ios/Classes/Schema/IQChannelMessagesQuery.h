//
//  IQChannelMessagesQuery.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONEncodable.h"

@interface IQChannelMessagesQuery : NSObject <IQJSONEncodable, NSCopying>
@property(nonatomic) NSNumber *MaxId;
@property(nonatomic) NSNumber *Limit;
- (instancetype)init;
- (instancetype)initWithMaxId:(NSNumber *)maxId;
@end

//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQJSONEncodable.h"
#import "IQJSONDecodable.h"


@interface IQChatEventQuery : NSObject <IQJSONEncodable>
@property(nonatomic, copy, nullable) NSNumber *LastEventId;
@property(nonatomic, copy, nullable) NSNumber *Limit;

- (instancetype _Nonnull)init;

- (instancetype _Nonnull)initWithLastEventId:(NSNumber *_Nullable)lastEventId;
@end

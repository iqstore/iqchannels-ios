//
// Created by Ivan Korobkov on 18/09/16.
//

#import <Foundation/Foundation.h>
#import "IQJSONEncodable.h"


@interface IQChannelThreadQuery : NSObject <IQJSONEncodable>
@property(nonatomic, nullable) NSNumber *MessagesLimit;
- (instancetype _Nonnull)init;
- (instancetype _Nonnull)initWithMessagesLimit:(NSNumber *_Nullable)messagesLimit;
@end

//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"
#import "IQJSONEncodable.h"


@interface IQChannelsConfig : NSObject <IQJSONEncodable, IQJSONDecodable, NSCopying>
@property(nonatomic, copy) NSString *address;
@property(nonatomic, copy) NSString *channel;

- (instancetype)init;
- (instancetype)initWithAddress:(NSString *)address channel:(NSString *)channel;
@end

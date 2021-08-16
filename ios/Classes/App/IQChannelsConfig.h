//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"
#import "IQJSONEncodable.h"


@interface IQChannelsConfig : NSObject <IQJSONEncodable, IQJSONDecodable, NSCopying>
@property(nonatomic, copy) NSString *address;   // Server address, i.e. https://demo.iqchannels.ru:3001
@property(nonatomic, copy) NSString *channel;   // Default channel name.
@property(nonatomic) BOOL disableUnreadBadge;   // Disables setting the app badge to the unread number
@property(nonatomic) NSDictionary<NSString*, NSString*> *customHeaders; // Custom http headers

- (instancetype)init;
- (instancetype)initWithAddress:(NSString *)address channel:(NSString *)channel;
@end

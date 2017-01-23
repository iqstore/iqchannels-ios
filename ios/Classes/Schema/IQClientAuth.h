//
// Created by Ivan Korobkov on 11/10/2016.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

@class IQClient;
@class IQClientSession;


@interface IQClientAuth : NSObject <IQJSONDecodable>
@property(nonatomic, nullable) IQClient *Client;
@property(nonatomic, nullable) IQClientSession *Session;
@end

//
//  IQClientIntegrationAuthRequest.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONEncodable.h"

@interface IQClientIntegrationAuthRequest : NSObject <IQJSONEncodable, NSCopying>
@property(nonatomic, copy, nullable) NSString *Credentials;
@end

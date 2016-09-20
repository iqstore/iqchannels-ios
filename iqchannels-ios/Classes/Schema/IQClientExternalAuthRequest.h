//
//  IQClientExternalAuthRequest.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONEncodable.h"

@interface IQClientExternalAuthRequest : NSObject <IQJSONEncodable, NSCopying>
@property(nonatomic, copy, nullable) NSString *ExternalToken;
@end

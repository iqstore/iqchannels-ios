//
//  IQClientAuthRequest.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONEncodable.h"

@interface IQClientAuthRequest : NSObject <IQJSONEncodable>
@property(nonatomic, copy, nullable) NSString *Token;
@end

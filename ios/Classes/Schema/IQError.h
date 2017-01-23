//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"
#import "IQErrorCode.h"


@interface IQError : NSObject <IQJSONDecodable>
@property(nonatomic, copy, nullable) IQErrorCode Code;
@property(nonatomic, copy, nullable) NSString *Text;
@end

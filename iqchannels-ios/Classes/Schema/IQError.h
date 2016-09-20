//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQSchemaConsts.h"
#import "IQJSONDecodable.h"


@interface IQError : NSObject <IQJSONDecodable, NSCopying>
@property(nonatomic, copy, nullable) IQErrorCode Code;
@property(nonatomic, copy, nullable) NSString *Text;
@end

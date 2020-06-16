//
//  IQFileToken.h
//  IQChannels
//
//  Created by Ivan Korobkov on 16.06.2020.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQFileToken : NSObject <IQJSONDecodable>
@property(nonatomic, copy, nullable) NSString *Token;
@end

NS_ASSUME_NONNULL_END

//
//  IQClientInput.h
//  IQChannels
//
//  Created by Ivan Korobkov on 11.11.2019.
//

#import <Foundation/Foundation.h>
#import "IQJSONEncodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQClientInput : NSObject <IQJSONEncodable>
@property(nonatomic, copy, nullable) NSString *Name;
@property(nonatomic, copy, nullable) NSString *Channel;
@end

NS_ASSUME_NONNULL_END

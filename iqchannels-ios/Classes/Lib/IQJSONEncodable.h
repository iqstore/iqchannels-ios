//
//  IQJSONEncodable.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>

@protocol IQJSONEncodable <NSObject>
-(NSDictionary *)toJSONObject;
@end

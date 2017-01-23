//
//  IQJSONDecodable.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>

@protocol IQJSONDecodable <NSObject>
+ (instancetype _Nullable)fromJSONObject:(id _Nullable)object;
@end

//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQLogLevel.h"


@interface IQLog : NSObject
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) IQLogLevel level;

- (instancetype)initWithName:(NSString *)name level:(IQLogLevel)level;
- (void)debug:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
- (void)info:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
- (void)error:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
@end

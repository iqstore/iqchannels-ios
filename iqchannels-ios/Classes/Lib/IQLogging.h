//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>

@class IQLogger;


typedef NSInteger IQLogLevel;
extern IQLogLevel const IQLogDebug;
extern IQLogLevel const IQLogInfo;
extern IQLogLevel const IQLogError;

NSString *IQLogLevelName(IQLogLevel level);


@interface IQLogging : NSObject
- (instancetype)initWithInfo;
- (instancetype)initWithDefaultLevel:(IQLogLevel)level levels:(NSDictionary *)levels;

- (IQLogger *)loggerWithName:(NSString *)name;
@end

//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQLogging.h"
#import "IQLogger.h"


const IQLogLevel IQLogDebug = 0;
const IQLogLevel IQLogInfo = 10;
const IQLogLevel IQLogError = 20;


NSString *IQLogLevelName(IQLogLevel level) {
    switch (level) {
        case IQLogDebug:return @"DEBUG";
        case IQLogInfo:return @"INFO";
        case IQLogError:return @"ERROR";
        default:return @"UNKNOWN";
    }
}


@implementation IQLogging {
    IQLogLevel _defaultLevel;
    NSDictionary *_levels;
    NSMutableDictionary *_loggers;
    dispatch_queue_t _queue;
}

- (instancetype)initWithInfo {
    return [self initWithDefaultLevel:IQLogInfo levels:@{}];
}

- (instancetype)initWithDefaultLevel:(IQLogLevel)level levels:(NSDictionary *)levels {
    _defaultLevel = level;
    _levels = levels;
    _loggers = [[NSMutableDictionary alloc] init];
    _queue = dispatch_queue_create("ru.iqstore.iqchannels.logger", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (IQLogger *)loggerWithName:(NSString *)name {
    __block IQLogger *result;
    dispatch_sync(_queue, ^{
        result = _loggers[name];
        if (result != nil) {
            return;
        }

        IQLogLevel level = _defaultLevel;
        NSNumber *levelNum = _levels[name];
        if (levelNum != nil) {
            level = levelNum.integerValue;
        }

        result = [[IQLogger alloc] initWithName:name level:level];
        _loggers[name] = result;
    });
    return result;
}
@end

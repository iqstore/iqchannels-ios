//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQLog.h"
#import "IQHttpClient.h"


@implementation IQLog

- (instancetype)initWithName:(NSString *)name level:(IQLogLevel)level {
    _name = name;
    _level = level;
    return self;
}

- (void)debug:(NSString *)format, ... {
    va_list vl;
    va_start(vl, format);
    [self writeWithLevel:IQLogDebug format:format args:vl];
    va_end(vl);
}

- (void)info:(NSString *)format, ... {
    va_list vl;
    va_start(vl, format);
    [self writeWithLevel:IQLogInfo format:format args:vl];
    va_end(vl);
}

- (void)error:(NSString *)format, ... {
    va_list vl;
    va_start(vl, format);
    [self writeWithLevel:IQLogError format:format args:vl];
    va_end(vl);
}

- (void)writeWithLevel:(IQLogLevel)level format:(NSString *)format args:(va_list)args {
    if (_level > level) {
        return;
    }

    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    return [self writeWithLevel:level message:message];
}

- (void)writeWithLevel:(IQLogLevel)level message:(NSString *)message {
    if (_level > level) {
        return;
    }

    // level name message
    NSString *levelName = IQLogLevelName(level);
    NSLog(@"%@\t%@\t%@", levelName, _name, message);
}
@end

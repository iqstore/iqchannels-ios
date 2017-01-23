//
// Created by Ivan Korobkov on 17/01/2017.
//

#import "IQLogLevel.h"


NSString *IQLogLevelName(IQLogLevel level) {
    switch (level) {
        case IQLogDebug:
            return @"DEBUG";
        case IQLogInfo:
            return @"INFO";
        case IQLogError:
            return @"ERROR";
        default:
            return @"UNKNOWN";
    }
}

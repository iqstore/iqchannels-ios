//
// Created by Ivan Korobkov on 11/09/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (IQChannels)
+ (instancetype)colorWithHex:(NSInteger)hex;
+ (instancetype) paletteColorFromString:(NSString *)string;
@end

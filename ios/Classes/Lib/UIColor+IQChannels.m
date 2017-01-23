//
// Created by Ivan Korobkov on 11/09/16.
//

#import "UIColor+IQChannels.h"


@implementation UIColor (IQChannels)
+ (instancetype)colorWithHex:(NSInteger)hex {
    NSInteger red = (hex & 0xFF0000) >> 16;
    NSInteger green = (hex & 0x00FF00) >> 8;
    NSInteger blue = (hex & 0x0000FF);

    CGFloat rf = (CGFloat) (red / 255.0);
    CGFloat gf = (CGFloat) (green / 255.0);
    CGFloat bf = (CGFloat) (blue / 255.0);

    return [[UIColor alloc] initWithRed:rf green:gf blue:bf alpha:1.0];
}

+ (instancetype)paletteColorFromString:(NSString *)string {
    if (!string || string.length == 0) {
        return [UIColor colorWithHex:0x78909c]; // blue-grey-400
    }

    static NSArray<UIColor *> *colors = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        colors = @[
                [UIColor colorWithHex:0xef5350], // red-400
                [UIColor colorWithHex:0xec407a], // pink-400
                [UIColor colorWithHex:0xab47bc], // purple-400
                [UIColor colorWithHex:0x7e57c2], // deep-purple-400
                [UIColor colorWithHex:0x5c6bc0], // indigo-400
                [UIColor colorWithHex:0x42a5f5], // blue-400
                [UIColor colorWithHex:0x29b6f6], // light-blue-400
                [UIColor colorWithHex:0x26c6da], // cyan-400
                [UIColor colorWithHex:0x26a69a], // teal-400
                [UIColor colorWithHex:0x66bb6a], // green-400
                [UIColor colorWithHex:0x9ccc65], // light-green-400
                [UIColor colorWithHex:0xd4e157], // lime-400
                [UIColor colorWithHex:0xffca28], // amber-400
                [UIColor colorWithHex:0xffa726], // orange-400
                [UIColor colorWithHex:0xff7043], // deep-orange-400
        ];
    });

    unichar ch = [string characterAtIndex:0];
    return colors[ch % colors.count];
}
@end

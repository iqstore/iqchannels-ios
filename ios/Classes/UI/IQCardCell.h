//
//  IQCardCell.h
//  Pods
//
//  Created by Zhalgas Baibatyr on 02.12.2023.
//

#import <UIKit/UIKit.h>
#import "IQAction.h"

@class IQCardCell;

@protocol IQCardCellDelegate <NSObject>

@required

- (void)cardCell:(IQCardCell *)cell didSelectOption:(IQAction *)action;

@end

@interface IQCardCell : UICollectionViewCell

@property (weak, nonatomic) id<IQCardCellDelegate> delegate;

- (void)setImage:(UIImage *)image;
- (void)setText:(NSString *)text;
- (void)setActions:(NSMutableArray<IQAction *> *)actions;
- (void)setTime:(NSString *)time;
- (void)setMessageBubbleWidth:(CGFloat)width;
- (void)setAsMedia;
+ (NSString *)cellReuseIdentifier;

@end

//
//  IQStackedSingleChoicesCell.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 23.11.2023.
//

#import "IQStackedSingleChoicesCell.h"
#import "JSQMessagesCollectionViewLayoutAttributes.h"
#import <IQChannels/IQSingleChoice.h>

@interface IQStackedSingleChoicesCell()

@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonsArray;

@end

@implementation IQStackedSingleChoicesCell {

    NSMutableArray<IQSingleChoice *> *_singleChoices;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self) {
        self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
        self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;
        self.buttonsArray = [@[] mutableCopy];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self clearSingleChoices];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];

    JSQMessagesCollectionViewLayoutAttributes *customAttributes = (JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes;

    self.avatarViewSize = customAttributes.incomingAvatarViewSize;
}

+ (NSString *)cellReuseIdentifier { return NSStringFromClass([self class]); }

- (void)setSingleChoices:(NSMutableArray<IQSingleChoice *> *)singleChoices {
    _singleChoices = singleChoices;

    for (IQSingleChoice *singleChoice in singleChoices) {
        UIButton *button = [self getNewButtonWithTitle: singleChoice.title];
        [self.stackView addArrangedSubview:button];
        [self.buttonsArray addObject:button];
    }

    [self layoutSubviews];
}

- (void)clearSingleChoices {
    [_singleChoices removeAllObjects];

    for (UIView *subview in self.stackView.arrangedSubviews) {
        [self.stackView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }

    [self.buttonsArray removeAllObjects];
}

- (UIButton *)getNewButtonWithTitle:(NSString*)title {
    UIButton *button = [[UIButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[[button heightAnchor] constraintEqualToConstant: 32] setActive:YES];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    UIColor *backgroundColor = [UIColor colorWithRed:173.0/255 green:184.0/255 blue:191.0/255 alpha:1];
    button.backgroundColor = backgroundColor;
    button.titleLabel.font = [UIFont systemFontOfSize: 12];
    button.layer.cornerRadius = 4;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonAction:(UIButton *)button {
    NSUInteger index = [self.buttonsArray indexOfObject: button];
    [self.stackedSingleChoicesDelegate stackedSingleChoicesCell:self didSelectOption:_singleChoices[index]];
}

@end

//
//  IQSingleChoicesView.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 05.11.2023.
//

#import "IQSingleChoicesView.h"
#import "RightAlignedCollectionViewFlowLayout.h"
#import <IQChannels/IQSingleChoice.h>

@interface IQSingleChoicesView ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonsArray;

@end

@implementation IQSingleChoicesView {

    NSMutableArray<IQSingleChoice *> *_singleChoices;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self) {
        self.stackView = [[UIStackView alloc] init];
        [self addSubview: self.stackView];
        [self setLayoutConstraints];
        [self setStyleProperties];
        self.buttonsArray = [@[] mutableCopy];
    }
}

- (void)setLayoutConstraints {
    [self.stackView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *leading = [
        NSLayoutConstraint
        constraintWithItem: self.stackView
        attribute: NSLayoutAttributeLeading
        relatedBy: NSLayoutRelationEqual
        toItem: self
        attribute: NSLayoutAttributeLeading
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *top = [
        NSLayoutConstraint
        constraintWithItem: self.stackView
        attribute: NSLayoutAttributeTop
        relatedBy: NSLayoutRelationEqual
        toItem: self
        attribute: NSLayoutAttributeTop
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *trailing = [
        NSLayoutConstraint
        constraintWithItem: self.stackView
        attribute: NSLayoutAttributeTrailing
        relatedBy: NSLayoutRelationEqual
        toItem: self
        attribute: NSLayoutAttributeTrailing
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *bottom = [
        NSLayoutConstraint
        constraintWithItem: self.stackView
        attribute: NSLayoutAttributeBottom
        relatedBy: NSLayoutRelationEqual
        toItem: self
        attribute: NSLayoutAttributeBottom
        multiplier: 1
        constant: 0
    ];

    [self addConstraints:@[leading, top, trailing, bottom]];
}

- (void)setStyleProperties {
    self.backgroundColor = [UIColor clearColor];
    self.stackView.backgroundColor = [UIColor clearColor];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.alignment = UIStackViewAlignmentTrailing;
    self.stackView.spacing = 4;
}

- (void)setSingleChoices:(NSMutableArray<IQSingleChoice *> *)singleChoices {
    _singleChoices = singleChoices;

    CGFloat width = UIScreen.mainScreen.bounds.size.width;

    CGFloat height = 2 + 28 + 2;
    NSInteger index = 0;
    NSInteger choiceIndex = 0;
    do {
        UIStackView *lineView = [[UIStackView alloc] init];
        lineView.spacing = 4;

        CGFloat lineWidth = 0;
        while (choiceIndex < singleChoices.count) {
            NSString* title = singleChoices[choiceIndex].title;
            CGRect boundingRect = [title boundingRectWithSize: CGSizeMake(-1, -1)
                options: NSStringDrawingUsesLineFragmentOrigin
                attributes: @{ NSFontAttributeName: [UIFont systemFontOfSize: 12] }
                context: nil
            ];
            CGFloat choiceWidth = 6 + boundingRect.size.width + 6 + 1;
            lineWidth += choiceWidth;

            if (lineWidth > width) {
                break;
            }

            choiceIndex += 1;

            UIButton *button = [self getNewButtonWithTitle: title width:choiceWidth - 4 height:height];
            [lineView addArrangedSubview:button];
            [self.buttonsArray addObject:button];
        }
        index += 1;

        [self.stackView addArrangedSubview:lineView];
    } while (choiceIndex < singleChoices.count);
}

- (void)clearSingleChoices {
    [_singleChoices removeAllObjects];

    for (UIView *subview in self.stackView.arrangedSubviews) {
        [self.stackView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }

    [self.buttonsArray removeAllObjects];
}

- (UIButton *)getNewButtonWithTitle:(NSString*)title width:(CGFloat)width height:(CGFloat)height {
    UIButton *button = [[UIButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[[button heightAnchor] constraintEqualToConstant: height] setActive:YES];
    [[[button widthAnchor] constraintEqualToConstant: width] setActive:YES];
    UIColor *color = [UIColor colorWithRed:136 / 255.0 green:186 / 255.0 blue:73 / 255.0 alpha:1];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize: 12];
    button.layer.borderColor = [color CGColor];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 8;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonAction:(UIButton *)button {
    NSUInteger index = [self.buttonsArray indexOfObject: button];
    [self.delegate singleChoicesView:self didSelectOption:_singleChoices[index]];
}

@end

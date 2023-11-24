//
//  IQSingleChoicesView.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 05.11.2023.
//

#import "IQSingleChoicesView.h"
#import "RightAlignedCollectionViewFlowLayout.h"
#import "IQSingleChoiceCell.h"
#import <IQChannels/IQSingleChoice.h>

@interface IQSingleChoicesView ()

@property (nonatomic) UICollectionView *collectionView;

@property (nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic) NSLayoutConstraint *heightConstraint;

@end

@implementation IQSingleChoicesView {

    NSMutableArray<IQSingleChoice *> *_singleChoices;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        RightAlignedCollectionViewFlowLayout *collectionViewLayout = [[RightAlignedCollectionViewFlowLayout alloc] init];
        self.collectionView = [
            [UICollectionView alloc]
            initWithFrame: CGRectZero
            collectionViewLayout: collectionViewLayout
        ];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
    }

    [self addSubview: self.collectionView];
    [self setLayoutConstraints];
    [self setStyleProperties];

    [self.collectionView
        registerClass: [IQSingleChoiceCell self]
        forCellWithReuseIdentifier: [IQSingleChoiceCell cellReuseIdentifier]
    ];

    return self;
}

- (void)setLayoutConstraints {
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *leading = [
        NSLayoutConstraint
        constraintWithItem: self.collectionView
        attribute: NSLayoutAttributeLeading
        relatedBy: NSLayoutRelationEqual
        toItem: self
        attribute: NSLayoutAttributeLeading
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *top = [
        NSLayoutConstraint
        constraintWithItem: self.collectionView
        attribute: NSLayoutAttributeTop
        relatedBy: NSLayoutRelationEqual
        toItem: self
        attribute: NSLayoutAttributeTop
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *trailing = [
        NSLayoutConstraint
        constraintWithItem: self.collectionView
        attribute: NSLayoutAttributeTrailing
        relatedBy: NSLayoutRelationEqual
        toItem: self
        attribute: NSLayoutAttributeTrailing
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *bottom = [
        NSLayoutConstraint
        constraintWithItem: self.collectionView
        attribute: NSLayoutAttributeBottom
        relatedBy: NSLayoutRelationEqual
        toItem: self
        attribute: NSLayoutAttributeBottom
        multiplier: 1
        constant: 0
    ];
    self.heightConstraint = [
        NSLayoutConstraint
        constraintWithItem: self
        attribute: NSLayoutAttributeHeight
        relatedBy: NSLayoutRelationEqual
        toItem: nil
        attribute: NSLayoutAttributeNotAnAttribute
        multiplier: 1
        constant: 0
    ];

    [self addConstraints:@[leading, top, trailing, bottom, self.heightConstraint]];
}

- (void)setStyleProperties {
    self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
}

- (void)setSingleChoices:(NSMutableArray<IQSingleChoice *> *)singleChoices {
    _singleChoices = singleChoices;
    [self.collectionView reloadData];
    CGFloat height = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    self.heightConstraint.constant = height;
    [self.delegate singleChoicesView: self didChangeHeight: height];
}

- (void)clearSingleChoices {
    _singleChoices = [@[] mutableCopy];
    [self.collectionView reloadData];
    self.heightConstraint.constant = 0;
    [self.delegate singleChoicesView: self didChangeHeight: 0];
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _singleChoices.count;
}

- (__kindof UICollectionViewCell *)
    collectionView:(UICollectionView *)collectionView
    cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    IQSingleChoice *singleChoice = _singleChoices[(NSUInteger) indexPath.item];

    NSString *cellIdentifier = [IQSingleChoiceCell cellReuseIdentifier];
    IQSingleChoiceCell *cell = [collectionView
        dequeueReusableCellWithReuseIdentifier: cellIdentifier
        forIndexPath: indexPath
    ];
    [cell setSingleChoice: singleChoice];

    return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath {
    IQSingleChoiceCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [_delegate singleChoicesView: self didSelectOption: cell.singleChoice];
}

#pragma mark - Collection view flow layout delegate

- (CGSize)
    collectionView:(UICollectionView *)collectionView
    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    IQSingleChoice *singleChoice = _singleChoices[(NSUInteger) indexPath.item];
    NSString* title = singleChoice.title;
    CGRect boundingRect = [title boundingRectWithSize: CGSizeMake(-1, -1)
           options: NSStringDrawingUsesLineFragmentOrigin
           attributes: @{ NSFontAttributeName: [UIFont systemFontOfSize: 12] }
           context: nil
    ];

    return  CGSizeMake(6 + boundingRect.size.width + 6 + 1, 2 + 28 + 2);
}

@end

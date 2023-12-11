//
//  IQSingleChoicesCell.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 25.11.2023.
//

#import "IQSingleChoicesCell.h"
#import "JSQMessagesCollectionViewLayoutAttributes.h"
#import "IQSingleChoicesView.h"
#import <IQChannels/IQSingleChoice.h>

@interface IQSingleChoicesCell()

@property (weak, nonatomic) IBOutlet IQSingleChoicesView *view;

@end

@implementation IQSingleChoicesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self) {
        self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
        self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;

    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.view clearSingleChoices];
    self.view.delegate = nil;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];

    JSQMessagesCollectionViewLayoutAttributes *customAttributes = (JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes;

    self.avatarViewSize = customAttributes.incomingAvatarViewSize;
}

+ (NSString *)cellReuseIdentifier { return NSStringFromClass([self class]); }

- (void)setSingleChoices:(NSMutableArray<IQSingleChoice *> *)singleChoices {
    [self.view setSingleChoices:singleChoices];
}

- (void)setSingleChoicesDelegate:(id<IQSingleChoicesViewDelegate>)delegate {
    self.view.delegate = delegate;
}

@end

//
//  IQRatingView.m
//  IQChannels
//
//  Created by Ivan Korobkov on 26/08/2019.
//

#import "IQRatingView.h"
#import "IQRating.h"
#import "IQChannels.h"
#import <JSQMessagesViewController/UIColor+JSQMessages.h>

@interface IQRatingView ()
@property (nonatomic) IQRating *rating;

@property (weak, nonatomic) IBOutlet UIButton *rateOne;
@property (weak, nonatomic) IBOutlet UIButton *rateTwo;
@property (weak, nonatomic) IBOutlet UIButton *rateThree;
@property (weak, nonatomic) IBOutlet UIButton *rateFour;
@property (weak, nonatomic) IBOutlet UIButton *rateFive;

//@property(nonatomic) UIImage *image;
//@property(nonatomic) UIImageView *imageView;
//@property(nonatomic) UIToolbar *toolbar;
@end

@implementation IQRatingView

+ (instancetype)viewWithRating:(IQRating *)rating {
    NSBundle *bundle = [NSBundle bundleForClass:self];
    UIColor *lightGrayColor = [UIColor jsq_messageBubbleLightGrayColor];
    
    IQRatingView *view = [bundle loadNibNamed:@"IQRatingView" owner:nil options:nil][0];
    view.rating = rating;
    view.backgroundColor = lightGrayColor;
    return view;
}

- (IBAction)touchRateDown:(id)sender {
    if (![_rating.State isEqualToString:IQRatingStatePending]) {
        return;
    }
    
    [self updateRatingValue:sender];
    [self updateImages];
}

- (IBAction)touchRateUpInside:(id)sender {
    if (![_rating.State isEqualToString:IQRatingStatePending]) {
        return;
    }
    
    [self updateRatingValue:sender];
    
    int32_t value = _rating.Value.intValue;
    _rating.State = IQRatingStateRated;
    [IQChannels rate:_rating.Id value:value];
}

- (void) updateRatingValue:(id)sender {
    if (sender == self.rateOne) {
        _rating.Value = @1;
    } else if (sender == self.rateTwo) {
        _rating.Value = @2;
    } else if (sender == self.rateThree) {
        _rating.Value = @3;
    } else if (sender == self.rateFour) {
        _rating.Value = @4;
    } else if (sender == self.rateFive) {
        _rating.Value = @5;
    }
}

- (void) updateImages {
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"IQChannels" withExtension:@"bundle"]];
    
    UIImage *empty = [UIImage imageNamed:@"star-empty.png" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *filled = [UIImage imageNamed:@"star-filled.png" inBundle:bundle compatibleWithTraitCollection:nil];
    NSArray *buttons = @[_rateOne, _rateTwo, _rateThree, _rateFour, _rateFive];
    
    
    for (NSInteger i = 0; i < buttons.count; i++) {
        UIButton *button = buttons[i];
        
        if (_rating.Value != nil && i < _rating.Value.intValue) {
            [button setImage:filled forState:UIControlStateNormal];
        } else {
            [button setImage:empty forState:UIControlStateNormal];
        }
    }
}
@end

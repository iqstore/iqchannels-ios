//
//  IQImagePreviewViewController.m
//  IQChannels
//
//  Created by Ivan Korobkov on 11.11.2019.
//

#import "IQImagePreviewViewController.h"

@interface IQImagePreviewViewController ()
@property (nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) void (^cancel)(IQImagePreviewViewController *);
@property (nonatomic) void (^done)(IQImagePreviewViewController *);
@end

@implementation IQImagePreviewViewController {
    void (^_cancel)(IQImagePreviewViewController *);
    void (^_done)(IQImagePreviewViewController *);
}

+ (instancetype)controllerWithImage:(UIImage *_Nonnull)image
                             cancel:(void (^ _Nonnull)(IQImagePreviewViewController *))cancel
                               done:(void (^ _Nonnull)(IQImagePreviewViewController *))done {
    NSBundle *bundle = [NSBundle bundleForClass:[IQImagePreviewViewController class]];
    IQImagePreviewViewController *vc = [[IQImagePreviewViewController alloc] initWithNibName:@"IQImagePreviewViewController" bundle: bundle];
    
    vc.image = image;
    vc.cancel = cancel;
    vc.done = done;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = self.image;
}

- (IBAction)doCancel:(id)sender {
    if (_cancel) {
        _cancel(self);
    }
}

- (IBAction)doDone:(id)sender {
    if (_done) {
        _done(self);
    }
}
@end

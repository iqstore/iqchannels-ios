//
//  Created by Ivan Korobkov on 12/09/16.
//

#import <IQChannels/IQChannels.h>
#import <IQChannels/IQChannelsConfig.h>
#import "IQLoginController.h"
#import "IQAppDelegate.h"
#import "IQLoginServerController.h"


NSString *const userDefaultsLoginServerKey = @"iqchannels-example.login.server";
// NSString *const userDefaultsLoginServerValue = @"http://192.168.1.102:3001";
NSString *const userDefaultsLoginServerValue = @"http://iq.bigdev.ru";


@interface IQLoginController () <UITextFieldDelegate>
@property(nonatomic) NSUserDefaults *userDefaults;
@property(weak, nonatomic) IBOutlet UIButton *serverButton;
@property(weak, nonatomic) IBOutlet UITextField *email;
@end


@implementation IQLoginController
+ (instancetype)controllerWithAppDelegate:(IQAppDelegate *)appDelegate {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IQLogin" bundle:[NSBundle mainBundle]];
    IQLoginController *controller = [storyboard instantiateInitialViewController];
    controller.appDelegate = appDelegate;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _email.delegate = self;

    {
        NSString *server = [_userDefaults stringForKey:userDefaultsLoginServerKey];
        [self setServer:server];
    }
}

- (IBAction)serverButtonTouch:(id)sender {
    UINavigationController *nc = [IQLoginServerController controllerWithCallback:^(NSString *server) {
        [self setServer:server];
    }];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)setServer:(NSString *)server {
    if (server == nil || [server isEqualToString:@""]) {
        [_userDefaults removeObjectForKey:userDefaultsLoginServerKey];
        server = userDefaultsLoginServerValue;
    } else {
        [_userDefaults setObject:userDefaultsLoginServerKey forKey:server];
        [_userDefaults synchronize];
    }

    IQChannelsConfig *config = [[IQChannelsConfig alloc] initWithAddress:server channel:@"support"];
    [IQChannels configure:config];
    [_serverButton setTitle:server forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField != self.email) {
        return YES;
    }

    [self loginWithEmail:self.email.text];
    return YES;
}

- (IBAction)login:(id)sender {
    [self loginWithEmail:self.email.text];
}

- (void)loginWithEmail:(NSString *)email {
    [IQChannels login:self.email.text];
    [_appDelegate switchToTabbar];
}
@end
//
//  LoginViewController.m
//  tweets
//
//  Created by  Yugender Boini on 1/30/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "NavigationManager.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *loginButtonImage;
@property (nonatomic) BDBOAuth1SessionManager *sessionManager;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButtonImage.layer.cornerRadius = 5.0;
    self.loginButtonImage.layer.masksToBounds = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onLoginButton:(UIButton *)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (error) {
            NSLog(@"failed to login");
        } else {
            [[NavigationManager sharedInstance] logIn:user];
        }
    }];
}

@end

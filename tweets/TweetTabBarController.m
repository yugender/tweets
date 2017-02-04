//
//  TweetTabBarController.m
//  tweets
//
//  Created by  Yugender Boini on 2/1/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "TweetTabBarController.h"
#import "TweetListViewController.h"
#import "ProfileViewController.h"

@interface TweetTabBarController ()

@end

@implementation TweetTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype) init {
    self = [super init];
    if (self) {
        // set up home timeline
        TweetListViewController *viewController = [[TweetListViewController alloc] initWithNibName:@"TweetListViewController" bundle:nil];
        UINavigationController *homeTimelineNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        homeTimelineNavigationController.tabBarItem.title = @"Home";
        homeTimelineNavigationController.tabBarItem.image = [UIImage imageNamed:@"home-icon.png"];
        
        TweetListViewController *mentionsViewController = [[TweetListViewController alloc] initWithNibName:@"TweetListViewController" bundle:nil];
        UINavigationController *mentionsNavigationController = [[UINavigationController alloc] initWithRootViewController:mentionsViewController];
        mentionsNavigationController.tabBarItem.title = @"Mentions";
        mentionsNavigationController.tabBarItem.image = [UIImage imageNamed:@"home-icon.png"];
        
        ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
        profileNavigationController.tabBarItem.title = @"Me";
        profileNavigationController.tabBarItem.image = [UIImage imageNamed:@"profile-icon.png"];
        
        [self setViewControllers:@[homeTimelineNavigationController, mentionsNavigationController ,profileNavigationController]];
    }
    return self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

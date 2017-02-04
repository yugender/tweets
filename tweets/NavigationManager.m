//
//  NavigationManager.m
//  tweets
//
//  Created by  Yugender Boini on 2/3/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "NavigationManager.h"
#import "LoginViewController.h"
#import "TweetListViewController.h"
#import "ProfileViewController.h"
#import "TwitterClient.h"
#import "User.h"

@interface NavigationManager()

@property (assign, nonatomic) BOOL isLoggedIn;

@end

@implementation NavigationManager

- (instancetype)init;
{
    self = [super init];
    if (self) {
        self.isLoggedIn = User.currentUser != nil;
    }
    return self;
}

+ (NavigationManager *)sharedInstance;
{
    static NavigationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NavigationManager new];
    });
    return instance;
}

- (void)setRootViewController;
{
    self.window.rootViewController = (self.isLoggedIn)? [self initializeLoggedInRootViewController] : [self initializeLoggedOutRootViewController];
}

- (UIViewController *)initializeLoggedInRootViewController {
    TweetListViewController *homeTimelineViewController = [[TweetListViewController alloc] initWithNibName:@"TweetListViewController" bundle:nil];
    homeTimelineViewController.tweetsViewType = Home;
    UINavigationController *homeTimelineNavigationController = [[UINavigationController alloc] initWithRootViewController:homeTimelineViewController];
    homeTimelineNavigationController.tabBarItem.title = @"Home";
    homeTimelineNavigationController.tabBarItem.image = [UIImage imageNamed:@"home-icon.png"];
    
    
    TweetListViewController *mentionsViewController = [[TweetListViewController alloc] initWithNibName:@"TweetListViewController" bundle:nil];
    mentionsViewController.tweetsViewType = Mentions;
    UINavigationController *mentionsNavigationController = [[UINavigationController alloc] initWithRootViewController:mentionsViewController];
    mentionsNavigationController.tabBarItem.title = @"Mentions";
    mentionsNavigationController.tabBarItem.image = [UIImage imageNamed:@"mentions-icon.png"];
    
    ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    profileViewController.user = [User currentUser];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    profileNavigationController.tabBarItem.title = @"Me";
    profileNavigationController.tabBarItem.image = [UIImage imageNamed:@"profile-icon.png"];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    [tabBarController setViewControllers:@[homeTimelineNavigationController, mentionsNavigationController ,profileNavigationController]];
    return tabBarController;
}

- (UIViewController *)initializeLoggedOutRootViewController {
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    return loginViewController;
}

- (void)logOut;
{
    self.isLoggedIn = NO;
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    [self setRootViewController];
}

- (void)logIn:(User *)user;
{
    self.isLoggedIn = YES;
    [User setCurrentUser:user];
    [self setRootViewController];
}

@end

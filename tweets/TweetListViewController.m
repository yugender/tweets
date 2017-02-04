//
//  TweetListViewController.m
//  tweets
//
//  Created by  Yugender Boini on 1/30/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "TwitterClient.h"
#import "TweetListViewController.h"
#import "TweetTableViewCell.h"
#import "TweetDetailViewController.h"
#import "ComposeTweetViewController.h"
#import "NavigationManager.h"
#import "LoginViewController.h"
#import "ProfileViewController.h"

@interface TweetListViewController () <UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, TweetActionDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<Tweet *> *tweets;
@property (strong, nonatomic) UIRefreshControl* refreshControl;

@end

@implementation TweetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(fetchTweets) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self addNavBarItems];
    
    [self fetchTweets];
    
    UINib *nib = [UINib nibWithNibName:@"TweetTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TweetTableViewCell"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addNavBarItems {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(composeNewTweet)];
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,32,32)];
    titleView.image = [UIImage imageNamed:@"twitter-header.png"];
    self.navigationItem.titleView = titleView;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (void) updateTweetsTable:(NSArray *)tweets error:(NSError *)error {
    self.tweets = tweets;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void) fetchTweets {
    if (self.tweetsViewType == Home) {
        [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
            [self updateTweetsTable:tweets error:error];
        }];
    } else if (self.tweetsViewType == Mentions) {
        [[TwitterClient sharedInstance] mentionsTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
            [self updateTweetsTable:tweets error:error];
        }];
    }
}

- (void)postedTweet:(Tweet *) tweet {
    if (self.tweetsViewType == Home) {
        NSArray* tweets = [[NSArray alloc] initWithObjects:tweet, nil];
        self.tweets = [tweets arrayByAddingObjectsFromArray:self.tweets];
        [self.tableView reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetTableViewCell" forIndexPath:indexPath];
    cell.tweet = [self.tweets objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.cellIndex = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailViewController *tweetViewController = [[TweetDetailViewController alloc] init];
    tweetViewController.tweet = [self.tweets objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:tweetViewController animated:YES];
    
}

- (void)onReply:(Tweet *)tweet atIndex:(NSInteger)index {
    ComposeTweetViewController *composeTweetViewController = [[ComposeTweetViewController alloc] init];
    composeTweetViewController.delegate = self;
    composeTweetViewController.replyToTweet = tweet;
    [self.navigationController presentViewController:composeTweetViewController animated:YES completion:^{
        
    }];
}

- (void)onTapProfileImage:(User *)user {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    profileViewController.user = user;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)onRetweet:(Tweet *)tweet atIndex:(NSInteger)index {
    if (tweet.retweeted) {
        [[TwitterClient sharedInstance] unretweet:tweet completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                self.tweets[index].retweeted = NO;
                NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }];
    } else {
        [[TwitterClient sharedInstance] retweet:tweet completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                self.tweets[index].retweeted = YES;
                NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }];
    }
}

- (void)onFavorite:(Tweet *)tweet atIndex:(NSInteger)index {
    if (tweet.favorited) {
        [[TwitterClient sharedInstance] unfavorite:tweet completion:^(Tweet *tweet, NSError *error) {
            if (tweet) {
                self.tweets[index].favorited = NO;
                NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }];
    } else {
        [[TwitterClient sharedInstance] favorite:tweet completion:^(Tweet *tweet, NSError *error) {
            if (tweet) {
                self.tweets[index].favorited = YES;
                NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }];
    }
}

- (void) composeNewTweet {
    ComposeTweetViewController *composeTweetViewController = [[ComposeTweetViewController alloc] init];
    composeTweetViewController.delegate = self;
    [self.navigationController presentViewController:composeTweetViewController animated:YES completion:^{
        
    }];
}

- (void) logout {
    UIAlertController *confirmSignOut = [UIAlertController alertControllerWithTitle:@"Are you sure want to sign out of Twitter?"
                                                                            message:nil
                                                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Sign out" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [[NavigationManager sharedInstance] logOut];
                                                         [self presentViewController:[LoginViewController new] animated:YES completion:^{
                                                             
                                                         }];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    [confirmSignOut addAction:okAction];
    [confirmSignOut addAction:cancelAction];
    [self presentViewController:confirmSignOut animated:YES completion:nil];
}

@end

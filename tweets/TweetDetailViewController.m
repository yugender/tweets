//
//  TweetViewController.m
//  tweets
//
//  Created by  Yugender Boini on 2/1/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "ComposeTweetViewController.h"
#import "TwitterClient.h"
#import "TweetTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface TweetDetailViewController () <ComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *repliesTable;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (strong, nonatomic) NSArray<Tweet *> *tweets;

@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self showTweetDetails];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.repliesTable.dataSource = self;
    self.repliesTable.delegate = self;
    self.repliesTable.estimatedRowHeight = 200;
    self.repliesTable.rowHeight = UITableViewAutomaticDimension;
    
    UINib *nib = [UINib nibWithNibName:@"TweetTableViewCell" bundle:nil];
    [self.repliesTable registerNib:nib forCellReuseIdentifier:@"TweetTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showTweetDetails {
    self.nameLabel.text = self.tweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screenName];
    self.tweetLabel.text = self.tweet.text;
    self.timestampLabel.text = [Tweet getElapsedTimeForTweet:self.tweet];
    [self.profileImage setImageWithURL:[NSURL URLWithString:self.tweet.user.profileImageUrl]];
    self.profileImage.layer.cornerRadius = 5.0;
    self.profileImage.layer.masksToBounds = YES;
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%li", (long)self.tweet.retweetCount];
    self.likesCountLabel.text = [NSString stringWithFormat:@"%li", (long)self.tweet.favoriteCount];
    self.repliesTable.hidden = YES;
    if (self.tweet.favorited) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
    }
    
    if (self.tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
    }
    
    [self fetchTweetReplies];
}

- (void)postedTweet:(Tweet *) tweet {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetTableViewCell" forIndexPath:indexPath];
    cell.tweet = [self.tweets objectAtIndex:indexPath.row];
    cell.cellIndex = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailViewController *tweetViewController = [[TweetDetailViewController alloc] init];
    tweetViewController.tweet = [self.tweets objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:tweetViewController animated:YES];
    
}

- (void) fetchTweetReplies {
    [[TwitterClient sharedInstance] repliesFor:self.tweet completion:^(NSArray *tweets, NSError *error) {
        if (!error && tweets.count > 0) {
            self.tweets = tweets;
            self.repliesTable.hidden = NO;
            [self.repliesTable reloadData];
        } else {
            self.repliesTable.hidden = YES;
        }
    }];
}

- (IBAction)onReply:(UIButton *)sender {
    ComposeTweetViewController *composeTweetViewController = [[ComposeTweetViewController alloc] init];
    composeTweetViewController.delegate = self;
    composeTweetViewController.replyToTweet = self.tweet;
    [self.navigationController presentViewController:composeTweetViewController animated:YES completion:^{
        
    }];
}

- (IBAction)onRetweet:(UIButton *)sender {
    if (self.tweet.retweeted) {
        [[TwitterClient sharedInstance] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                self.tweet.retweeted = NO;
                self.tweet.retweetCount = tweet.retweetCount;
                [self showTweetDetails];
            }
        }];
    } else {
        [[TwitterClient sharedInstance] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                self.tweet.retweeted = YES;
                self.tweet.retweetCount = tweet.retweetCount;
                [self showTweetDetails];
            }
        }];
    }
}


- (IBAction)onFavorite:(UIButton *)sender {
    if (self.tweet.favorited) {
        [[TwitterClient sharedInstance] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if (tweet) {
                self.tweet.favorited = NO;
                self.tweet.favoriteCount = tweet.favoriteCount;
                [self showTweetDetails];
            }
        }];
    } else {
        [[TwitterClient sharedInstance] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if (tweet) {
                self.tweet.favorited = YES;
                self.tweet.favoriteCount = tweet.favoriteCount;
                [self showTweetDetails];
            }
        }];
    }
}

@end

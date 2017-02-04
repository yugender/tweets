//
//  ProfileViewController.m
//  tweets
//
//  Created by  Yugender Boini on 2/3/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "ProfileViewController.h"
#import "Tweet.h"
#import "TweetTableViewCell.h"
#import "TwitterClient.h"
#import "TweetDetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tweetsTable;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userHandle;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (strong, nonatomic) NSArray<Tweet *> *tweets;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tweetsTable.dataSource = self;
    self.tweetsTable.delegate = self;
    self.tweetsTable.estimatedRowHeight = 200;
    self.tweetsTable.rowHeight = UITableViewAutomaticDimension;
    
    [self.userName setText:self.user.name];
    [self.userHandle setText:[NSString stringWithFormat:@"@%@", self.user.screenName]];
    [self.profileImage setImageWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
    self.profileImage.layer.cornerRadius = 5.0;
    self.profileImage.layer.masksToBounds = YES;
    [self.followersLabel setText:[NSString stringWithFormat:@"%ld followers", (long)self.user.followersCount]];
    [self.followingLabel setText:[NSString stringWithFormat:@"%ld following", (long)self.user.followingCount]];
    
    [self fetchTweets];
    
    UINib *nib = [UINib nibWithNibName:@"TweetTableViewCell" bundle:nil];
    [self.tweetsTable registerNib:nib forCellReuseIdentifier:@"TweetTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (void) fetchTweets {
    [[TwitterClient sharedInstance] userTimeline:self.user completion:^(NSArray *tweets, NSError *error) {
        self.tweets = tweets;
        [self.tweetsTable reloadData];
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetTableViewCell" forIndexPath:indexPath];
    cell.tweet = [self.tweets objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailViewController *tweetViewController = [[TweetDetailViewController alloc] init];
    tweetViewController.tweet = [self.tweets objectAtIndex:indexPath.row];
    tweetViewController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:tweetViewController animated:YES];
    
}

@end

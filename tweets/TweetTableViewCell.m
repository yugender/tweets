//
//  TweetTableViewCell.m
//  tweets
//
//  Created by  Yugender Boini on 1/30/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "TweetTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface TweetTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reTweetContainerHeight;
@property (weak, nonatomic) IBOutlet UIImageView *tweetImage;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetedByLabel;

@end

@implementation TweetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnProfileImage:)];
    tapGesture.cancelsTouchesInView = YES;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.profileImage addGestureRecognizer:tapGesture];
}

- (void) setTweet: (Tweet *)tweet {
    _tweet = tweet;
    self.nameLabel.text = tweet.user.name;
    self.handleLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    self.contentLabel.text = tweet.text;
    self.timestampLabel.text = [Tweet getElapsedTimeForTweet:tweet];
    [self.profileImage setImageWithURL:[NSURL URLWithString:tweet.user.profileImageUrl]];
    self.profileImage.layer.cornerRadius = 5.0;
    self.profileImage.layer.masksToBounds = YES;
    [self.tweetImage setImageWithURL:[NSURL URLWithString:tweet.imageUrl]];
    if (!tweet.retweeted) {
        self.reTweetContainerHeight.constant = 0;
        self.retweetedByLabel.hidden = YES;
    }
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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tapOnProfileImage:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(onTapProfileImage:)]) {
            [self.delegate onTapProfileImage:self.tweet.user];
        }
    }
}

- (IBAction)onReply:(UIButton *)sender {
    NSLog(@"inside onreply");
    if ([self.delegate respondsToSelector:@selector(onReply:atIndex:)]) {
        NSLog(@"inside onreply delegate");
        [self.delegate onReply:self.tweet atIndex:self.cellIndex];
    }
}

- (IBAction)onRetweet:(UIButton *)sender {
    NSLog(@"inside onRetweet");
    if ([self.delegate respondsToSelector:@selector(onRetweet:atIndex:)]) {
        NSLog(@"before onretweet delegate");
        [self.delegate onRetweet:self.tweet atIndex:self.cellIndex];
    }
}

- (IBAction)onFavorite:(UIButton *)sender {
    NSLog(@"inside onfavorite");
    if ([self.delegate respondsToSelector:@selector(onFavorite:atIndex:)]) {
        NSLog(@"before onFav delegate");
        [self.delegate onFavorite:self.tweet atIndex:self.cellIndex];
    }
}

@end

//
//  TweetTableViewCell.h
//  tweets
//
//  Created by  Yugender Boini on 1/30/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "User.h"

@protocol TweetActionDelegate <NSObject>

- (void)onReply:(Tweet *)tweet atIndex:(NSInteger) index;
- (void)onTapProfileImage:(User *)user;
- (void)onRetweet:(Tweet *)tweet atIndex:(NSInteger) index;
- (void)onFavorite:(Tweet *)tweet atIndex:(NSInteger) index;

@end

@interface TweetTableViewCell : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, strong) id<TweetActionDelegate> delegate;
@property (nonatomic, assign) NSInteger cellIndex;

@end

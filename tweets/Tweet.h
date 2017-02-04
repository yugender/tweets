//
//  Tweet.h
//  tweets
//
//  Created by  Yugender Boini on 1/31/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString * idString;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) User * user;
@property (nonatomic, strong) Tweet *replyToTweet;

@property (nonatomic) BOOL favorited;
@property (nonatomic) NSInteger favoriteCount;

@property (nonatomic) BOOL retweeted;
@property (nonatomic) NSInteger retweetCount;

@property (nonatomic, strong) NSString * inReplyToStatusId;

- (instancetype) initWithDictionary:(NSDictionary *) dictionary;
+ (NSArray *) tweetsWithArray:(NSArray *) array;
+ (NSString *)getElapsedTimeForTweet:(Tweet *) tweet;
+ (NSString *)getFormattedCount:(NSInteger) count;

@end

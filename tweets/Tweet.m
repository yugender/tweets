//
//  Tweet.m
//  tweets
//
//  Created by  Yugender Boini on 1/31/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        self.text = dictionary[@"text"];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.idString = dictionary[@"id_str"];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        self.retweetCount = [dictionary[@"retweet_count"] integerValue];
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
        NSString *createdAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss z y";
        self.createdAt = [formatter dateFromString:createdAtString];
        
        NSDictionary *entities = dictionary[@"entities"];
        if (entities) {
            NSArray *media = entities[@"media"];
            if (media && media.count) {
                self.imageUrl = media[0][@"media_url_https"];
            }
        }
        
        self.inReplyToStatusId = dictionary[@"in_reply_to_status_id_str"];
    }
    return self;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    
    return tweets;
}

+ (NSString *)getElapsedTimeForTweet:(Tweet *) tweet {
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
    formatter.allowedUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    formatter.maximumUnitCount = 1;
    NSString *elapsed = [formatter stringFromDate:tweet.createdAt toDate:[NSDate date]];
    return elapsed;
}

+ (NSString *)getFormattedCount:(NSInteger) count {
    if (count >= 1000000) {
        return [NSString stringWithFormat:@"%0.2fM", count / 1000000.0];
    } else if (count >= 1000) {
        return [NSString stringWithFormat:@"%ldK", lroundf(count / 1000.0)];
    } else {
        return [NSString stringWithFormat:@"%ld", count];
    }
}

@end

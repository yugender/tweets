//
//  TwitterClient.m
//  tweets
//
//  Created by  Yugender Boini on 1/30/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
NSString * const BASE_URL = @"https://api.twitter.com";
NSString * const CONSUMER_KEY = @"otGoG4JtUMPSUsDKM22LwPn0u";
NSString * const CONSUMER_SECRET = @"O2xtm5SksRPRmvzZsxGQragO3i627PPSrkSaYmrmdh3yU6YPD8";

@interface TwitterClient ()
@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);
@end
@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (client == nil) {
            client = [[TwitterClient alloc]initWithBaseURL:[NSURL URLWithString:BASE_URL] consumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET];
        }
    });
    
    return client;
}

- (void) loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"mytweets://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"Got the request token");
        
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat: @"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        [[UIApplication sharedApplication] openURL:authURL options:@{} completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Opened URL");
            } else {
                NSLog(@"Failed to open URL");
            }
        }];
    } failure:^(NSError *error) {
        NSLog(@"Failed to get the request token");
        self.loginCompletion(nil, error);
    }];
    
}

- (void)openURL:(NSURL *)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        [self.requestSerializer saveAccessToken:accessToken];
        
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil progress:^(NSProgress *downloadProgress) {
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            self.loginCompletion(user, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            self.loginCompletion(nil, error);
        }];
    } failure:^(NSError *error) {
        self.loginCompletion(nil, error);
    }];
}

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json?include_my_retweet=1" parameters:params progress:^(NSProgress *downloadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray * tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failed to get home timeline%@", error);
        completion(nil, error);
    }];
}

- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/mentions_timeline.json" parameters:params progress:^(NSProgress *downloadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray * tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failed to get mentions timeline %@", error);
        completion(nil, error);
    }];
}

- (void)repliesFor:(Tweet *)tweet completion:(void (^)(NSArray *tweets, NSError *))completion {
    NSString *queryString = [[NSString stringWithFormat:@"@%@", tweet.user.screenName ] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *urlString = [@"1.1/search/tweets.json?q=" stringByAppendingString:queryString];
    NSDictionary *params = @{@"count":@"40"};
    [self GET:urlString parameters:params progress:^(NSProgress *downloadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *allTweets = [Tweet tweetsWithArray:responseObject[@"statuses"]];
        NSMutableArray *replies = [NSMutableArray array];
        for (Tweet* reply in allTweets) {
            if ([tweet.idString isEqualToString:reply.inReplyToStatusId]) {
                [replies addObject:reply];
            }
        }
        NSArray * tweets = replies;
        completion(tweets, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failed to get replies to a tweet %@", error);
        completion(nil, error);
    }];
}

- (void)userTimeline:(User *)user completion:(void (^)(NSArray *tweets, NSError *error))completion {
    User *userParam = user ? user : [User currentUser];
    NSString *urlString = [NSString stringWithFormat:@"1.1/statuses/user_timeline.json?include_rts=1&count=20&include_my_retweet=1&screen_name=%@", userParam.screenName];
    [self GET:urlString parameters:nil progress:^(NSProgress *downloadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray * tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

- (void)favorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/create.json?id=%@", tweet.idString];
    [self POST:postUrl parameters:nil progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        completion([[Tweet alloc] initWithDictionary:responseObject], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

- (void)unfavorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/destroy.json?id=%@", tweet.idString];
    [self POST:postUrl parameters:nil progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        completion([[Tweet alloc] initWithDictionary:responseObject], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

- (void)retweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweet.idString];
    [self POST:postUrl parameters:nil progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        completion([[Tweet alloc] initWithDictionary:responseObject], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failed to retweet %@", error);
        completion(nil, error);
    }];
}

- (void)unretweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/unretweet/%@.json", tweet.idString];
    [self POST:postUrl parameters:nil progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        completion([[Tweet alloc] initWithDictionary:responseObject], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failed to unretweet %@", error);
        completion(nil, error);
    }];
}

- (void)sendTweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion {
    NSString *postUrl;
    
    if (tweet.replyToTweet) {
        postUrl = [NSString stringWithFormat:@"1.1/statuses/update.json?status=%@&in_reply_to_status_id=%@", tweet.text, tweet.replyToTweet.idString];
    } else {
        postUrl = [NSString stringWithFormat:@"1.1/statuses/update.json?status=%@", tweet.text];
    }
    
    postUrl = [postUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self POST:postUrl parameters:params progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        Tweet *newTweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(newTweet, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failed to post tweet %@", error);
        completion(nil, error);
    }];
}

@end

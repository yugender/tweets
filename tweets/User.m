//
//  User.m
//  tweets
//
//  Created by  Yugender Boini on 1/31/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "User.h"

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

static User *_currentUser = nil;

NSString * const kCurrentUserKey = @"currentUserData";

+ (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:NULL];
        [userDefaults setObject:data forKey:kCurrentUserKey];
    } else {
        [userDefaults setObject:nil forKey:kCurrentUserKey];
    }
}

+ (User *)currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    
    return _currentUser;
}

- (instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profileImageUrl = dictionary[@"profile_image_url_https"];
        self.tagline = dictionary[@"description"];
        self.followingCount = [dictionary[@"following"] integerValue];
        self.followersCount =[dictionary[@"followers_count"] integerValue];
    }
    return self;
}

@end

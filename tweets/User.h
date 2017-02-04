//
//  User.h
//  tweets
//
//  Created by  Yugender Boini on 1/31/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * screenName;
@property (nonatomic, strong) NSString * profileImageUrl;
@property (nonatomic, strong) NSString * tagline;
@property (nonatomic) NSInteger followingCount;
@property (nonatomic) NSInteger followersCount;

- (instancetype) initWithDictionary:(NSDictionary *) dictionary;
+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;

@end

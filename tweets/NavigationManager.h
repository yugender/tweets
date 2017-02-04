//
//  NavigationManager.h
//  tweets
//
//  Created by  Yugender Boini on 2/3/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"

@interface NavigationManager : NSObject

+ (NavigationManager *)sharedInstance;

- (void)logOut;
- (void)logIn:(User *)user;
- (void)setRootViewController;

@property (strong, nonatomic) UIWindow *window;

@end

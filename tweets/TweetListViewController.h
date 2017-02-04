//
//  TweetListViewController.h
//  tweets
//
//  Created by  Yugender Boini on 1/30/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Home,
    Mentions
} TweetsViewType;

@interface TweetListViewController : UIViewController

@property (nonatomic) TweetsViewType tweetsViewType;

@end

//
//  ComposeTweetViewController.h
//  tweets
//
//  Created by  Yugender Boini on 2/1/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol ComposeViewControllerDelegate <NSObject>

- (void)postedTweet:(Tweet *)tweet;

@end

@interface ComposeTweetViewController : UIViewController

@property (nonatomic, strong) Tweet *replyToTweet;

@property (nonatomic, weak) id <ComposeViewControllerDelegate> delegate;

@end

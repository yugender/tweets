//
//  ComposeTweetViewController.m
//  tweets
//
//  Created by  Yugender Boini on 2/1/17.
//  Copyright © 2017 sample. All rights reserved.
//

#import "ComposeTweetViewController.h"
#import "TwitterClient.h"

@interface ComposeTweetViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UILabel *charCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

const int kMaxTweetLength = 140;

@implementation ComposeTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.charCountLabel setText:[NSString stringWithFormat:@"%d", kMaxTweetLength]];
    [self.tweetTextView becomeFirstResponder];
    self.tweetTextView.delegate = self;
    
    if (self.replyToTweet) {
        self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.replyToTweet.user.screenName];
    }
    
    self.tweetButton.layer.cornerRadius = 5.0;
    self.tweetButton.layer.masksToBounds = YES;
    self.tweetButton.backgroundColor = [UIColor colorWithRed:0 green:172 blue:238 alpha:1.0];
    self.tweetButton.tintColor = [UIColor whiteColor];
    
    [self updateCharCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardDidShow:(NSNotification *)sender {
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
    self.bottomConstraint.constant = -(newFrame.origin.y - CGRectGetHeight(self.view.frame));
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

- (IBAction)onCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateCharCount];
}

- (IBAction)onTweetButton:(id)sender {
    int tweetLength = (int)self.tweetTextView.text.length;
    int remaining = kMaxTweetLength - tweetLength;
    
    if (tweetLength > 0 && remaining >= 0) {
        Tweet *tweet = [[Tweet alloc] init];
        tweet.text = self.tweetTextView.text;
        if (self.replyToTweet) {
            tweet.replyToTweet = self.replyToTweet;
        }
        [[TwitterClient sharedInstance] sendTweetWithParams:nil tweet:tweet completion:^(Tweet *tweet, NSError *error) {
            if (self.delegate) {
                [self.delegate postedTweet:tweet];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)updateCharCount {
    int remaining = kMaxTweetLength - (int)self.tweetTextView.text.length;
    
    self.charCountLabel.text = [NSString stringWithFormat:@"%d", remaining];
    
    if (remaining <= 0) {
        self.charCountLabel.textColor = [UIColor redColor];
        self.tweetButton.enabled = NO;
        self.tweetButton.backgroundColor = nil;
    } else {
        self.charCountLabel.textColor = [UIColor lightGrayColor];
        self.tweetButton.enabled = YES;
    }
}

@end

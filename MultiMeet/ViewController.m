//
//  ViewController.m
//  MultiMeet
//
//  Created by Maxim Zaks on 16.05.14.
//  Copyright (c) 2014 MultiThink. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self accessTwitterAccount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)accessTwitterAccount
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore
     requestAccessToAccountsWithType:accountType
     options:nil
     completion:^(BOOL granted, NSError *error) {
         if (granted) {
             NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
             if (accountsArray.count > 0) {
                 ACAccount *twitterAccount = [accountsArray firstObject];
                 [self loadProfileDetailsForAccount:twitterAccount];
                 
                 return;
             }
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
            [self createUserWithName:[UIDevice currentDevice].name pictureSource:nil];
         });
    }];
}

- (void)createUserWithName:(NSString *)name pictureSource:(NSString *)pictureSource
{
    NSLog(@"Creating user with name %@, avatar url %@", name, pictureSource);
    
    if (pictureSource == nil)
    {
        self.loadingIndicator.hidden = YES;
        self.userNameLabel.text = name;
        self.userPicture.image = [UIImage imageNamed:@"default_profile_picture"];
    }
    else
    {
        // Remove _normal in picture name to get full size profile picture
        // See https://dev.twitter.com/docs/user-profile-images-and-banners
        pictureSource = [pictureSource stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
        
        NSURL *pictureURL = [NSURL URLWithString:pictureSource];
        
        dispatch_async
        (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData =
            [NSData dataWithContentsOfURL:pictureURL];
            
            UIImage *image = [UIImage imageWithData:imageData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loadingIndicator.hidden = YES;
                self.userNameLabel.text = name;
                self.userPicture.image = image;
            });
        });
    }
}

- (void)loadProfileDetailsForAccount:(ACAccount *)account
{
    NSParameterAssert(account);
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
    NSDictionary *params = @{@"screen_name" : account.username};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];
    
    [request setAccount:account];
    
    [request performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         if (responseData) {
             NSDictionary *user =
             [NSJSONSerialization JSONObjectWithData:responseData
                                             options:NSJSONReadingAllowFragments
                                               error:NULL];
             
             NSString *userName = user[@"name"] ?: account.username;
             NSString *profileImageUrl = user[@"profile_image_url"];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self createUserWithName:userName pictureSource:profileImageUrl];
             });
         }
     }];
}

@end

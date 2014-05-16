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
#import "FoodDataSource.h"
#import "Advertiser.h"
#import "MMChatViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
  FoodDataSource* _foodDataSource;
  NSTimer *_timer;
  CGFloat _currentProgress;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self accessTwitterAccount];
  
  _foodDataSource = [[FoodDataSource alloc] initWithTableView:self.foodChoiceTableView];
  
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCount) name:kMultiMeetCount object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showChatView) name:kMultiMeetStart object:nil];

    _currentProgress = 0;
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

    [Advertiser sharedAdvertiser].peerName = name;
    
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
                self.userPicture.image = [self maskImage:image withMask:[UIImage imageNamed:@"circle"] ];
            });
        });
    }
}

- (UIImage*) maskImage:(UIImage *) image withMask:(UIImage *) mask
{
  CGImageRef imageReference = image.CGImage;
  CGImageRef maskReference = mask.CGImage;
  
  CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                           CGImageGetHeight(maskReference),
                                           CGImageGetBitsPerComponent(maskReference),
                                           CGImageGetBitsPerPixel(maskReference),
                                           CGImageGetBytesPerRow(maskReference),
                                           CGImageGetDataProvider(maskReference),
                                           NULL, // Decode is null
                                           YES // Should interpolate
                                           );
  
  CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
  CGImageRelease(imageMask);
  
  UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
  CGImageRelease(maskedReference);
  
  return maskedImage;
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

- (void) updateCount
{

    dispatch_async(dispatch_get_main_queue(), ^{

        NSInteger connectedPeers = [[Advertiser sharedAdvertiser] numberOfConnectedPeers];
        
        self.connectedCountLabel.text = [NSString stringWithFormat:@"+%li", connectedPeers];
        
        if (connectedPeers == 0) {
            [_timer invalidate];
            _timer = nil;
            _currentProgress = 0;
            [self updateProgressBar];
        } else {
            if(!_timer){
                _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showProgress) userInfo:nil repeats:YES];
                [_timer fire];
            }
        }
    });

}

- (void)showProgress {
  _currentProgress++;
    if(_currentProgress>=31){
        [self startChating];
    } else {
      [self updateProgressBar];
    }
}


- (void) updateProgressBar {
  CGFloat width = (320.0f / 30.0f) * _currentProgress;
  
  [UIView animateWithDuration:1 animations:^{
    _progressIndicator.frame = CGRectMake(_progressIndicator.frame.origin.x, _progressIndicator.frame.origin.y, width, _progressIndicator.frame.size.height);
  }];
}

- (void)startChating {
    [_timer invalidate];
    _timer = nil;
    _currentProgress = 0;

    [[Advertiser sharedAdvertiser] startChatting];

    [self showChatView];
}

- (void)showChatView {
    
    if (self.presentedViewController) return;
    
    MMChatViewController *chatViewController = [[MMChatViewController alloc] init];
    chatViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneChatting:)];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];

}

- (void)onDoneChatting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

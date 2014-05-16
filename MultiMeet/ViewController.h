//
//  ViewController.h
//  MultiMeet
//
//  Created by Maxim Zaks on 16.05.14.
//  Copyright (c) 2014 MultiThink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (weak, nonatomic) IBOutlet UILabel *connectedCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *foodChoiceTableView;
@property (weak, nonatomic) IBOutlet UIImageView *progressIndicator;

@end

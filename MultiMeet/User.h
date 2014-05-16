//
//  User.h
//  MultiMeet
//
//  Created by Jannis Muething on 5/16/14.
//  Copyright (c) 2014 MultiThink. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MultipeerConnectivity;

@interface User : NSObject

@property(nonatomic) NSString *twitterHandle;
@property(nonatomic) NSString *firstname;
@property(nonatomic) NSString *lastName;

@property(nonatomic) UIImage *userImage;

@property(nonatomic) MCPeerID *peerID;

@end

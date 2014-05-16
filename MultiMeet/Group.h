//
//  Group.h
//  MultiMeet
//
//  Created by Jannis Muething on 5/16/14.
//  Copyright (c) 2014 MultiThink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property(nonatomic) NSInteger numberOfPeople;

@property(nonatomic) NSSet *usersInGroup;

@end

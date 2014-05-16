//
//  FoodDataSource.h
//  MultiMeet
//
//  Created by Jannis Muething on 5/16/14.
//  Copyright (c) 2014 MultiThink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodDataSource : NSObject <UITableViewDataSource , UITableViewDelegate>

- (id) initWithTableView:(UITableView*) tableView;

@property (nonatomic, weak) UITableView* tableView;

@end

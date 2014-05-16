//
//  FoodDataSource.m
//  MultiMeet
//
//  Created by Jannis Muething on 5/16/14.
//  Copyright (c) 2014 MultiThink. All rights reserved.
//

#import "FoodDataSource.h"
#import "Advertiser.h"

@implementation FoodDataSource

- (id) initWithTableView:(UITableView*) tableView {
  self = [super init];
  
  if (self){
    self.tableView = tableView;
    self.tableView.dataSource = self;
  }
  return self;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 4;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell* cell;
  
  switch (indexPath.row) {
    case 0:
      cell = [self.tableView dequeueReusableCellWithIdentifier:@"pizza"];
      break;
    case 1:
      cell = [self.tableView dequeueReusableCellWithIdentifier:@"chinese"];
      break;
    case 2:
      cell = [self.tableView dequeueReusableCellWithIdentifier:@"fastfood"];
      break;
    case 3:
      cell = [self.tableView dequeueReusableCellWithIdentifier:@"doner"];
    default:
      break;
  }
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [[Advertiser sharedAdvertiser] startAdvertising:[NSString stringWithFormat:@"%li", indexPath.row]];

  
}

@end

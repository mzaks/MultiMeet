//
//  FoodDataSource.m
//  MultiMeet
//
//  Created by Jannis Muething on 5/16/14.
//  Copyright (c) 2014 MultiThink. All rights reserved.
//

#import "FoodDataSource.h"
#import "Advertiser.h"

@implementation FoodDataSource {
    NSArray *food;
}

- (id) initWithTableView:(UITableView*) tableView {
  self = [super init];
  
  if (self){
    self.tableView = tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    food = @[@"pizza", @"chinese", @"fastfood", @"doner"];
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
  
  cell = [self.tableView dequeueReusableCellWithIdentifier:food[indexPath.row]];
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [[Advertiser sharedAdvertiser] startAdvertising:[NSString stringWithFormat:@"%li", indexPath.row]];

}

- (NSString *)nameAtPath:(NSIndexPath *)path {
    return food[path.row];
}
@end

//
//  FriendListTableViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 18/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "FriendListTableViewController.h"
#import "Friend.h"
#import "SeeOnMapViewController.h"

@interface FriendListTableViewController ()

@end

@implementation FriendListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)setFriends:(NSArray *)friends {
    _friends = friends;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.friends count];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Friend Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Friend *fr= self.friends[indexPath.row];
    cell.textLabel.text =fr.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Current Location: %f,%f",fr.location.latitude,fr.location.longitude];
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
     NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
     if ([segue.identifier isEqualToString:@"See on map"]) {
        if ([segue.destinationViewController isKindOfClass:[SeeOnMapViewController class]]) {
            SeeOnMapViewController *ivc = (SeeOnMapViewController *)segue.destinationViewController;
            ivc.user = self.user;
            
            Friend *fr = self.friends[indexPath.row];
            ivc.friends = @[fr];
        }
    }
}


@end

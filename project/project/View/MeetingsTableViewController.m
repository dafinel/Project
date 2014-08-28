//
//  MeetingsTableViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 26/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//

#import "MeetingsTableViewController.h"
#import "MeetingOnMapViewController.h"
#import "Notification.h"
#import "User+Annotation.h"


@interface MeetingsTableViewController ()

@end

@implementation MeetingsTableViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationUser
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      User *u = note.userInfo[USER];
                                                      NSArray *array = [u.meetings sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                          NSDate *s1 = [obj1 valueForKey:@"date"];
                                                          NSDate *s2 = [obj2 valueForKey:@"date"];
                                                          return [s1 compare:s2];
                                                      }];
                                                      self.meetings = [array mutableCopy];
                                                  }];

    
    
    
    
}

- (void) setMeetings:(NSMutableArray *)meetings {
    _meetings = meetings;
    [[self.tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:[NSString stringWithFormat:@"%d",[self.meetings count]]];
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
    return [self.meetings count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Meeting Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *meting = self.meetings[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Meeting with: %@",meting[@"with"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"On: %@",meting[@"date"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
   // [self performSegueWithIdentifier:@"meeting on map" sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
     NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"meeting on map"]) {
        if ([segue.destinationViewController isKindOfClass:[MeetingOnMapViewController class]]) {
             MeetingOnMapViewController *myvc = (MeetingOnMapViewController *)segue.destinationViewController;
            Location *location =[[Location alloc] init];
            NSDictionary *meting = self.meetings[indexPath.row];
            location.latitude = [meting[@"lat"] doubleValue];
            location.longitude = [meting[@"lon"] doubleValue];
            location.date = meting[@"date"];
            myvc.meetingLocation = location;
        }
    }
}


@end

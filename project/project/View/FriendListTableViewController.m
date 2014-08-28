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
#import "Notification.h"

@interface FriendListTableViewController ()

@end

@implementation FriendListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationUser
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.user = note.userInfo[USER];
                                                      self.friends = [self createFriendsList:self.user.friends];;
                                                  }];
}

-(NSArray *)createFriendsList:(NSArray *)ids {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *s in ids) {
        [array addObject:[self getFriendInfo:s]];
    }
    return array;
}

- (Friend *)getFriendInfo:(NSString *)s {
    
    Friend *fr=[[Friend alloc]init];
    __block BOOL ok = NO;
    NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:[NSString stringWithFormat:@"/%@",s]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setRequestCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSDictionary* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if ([responseArray count]) {
                // dispatch_async(dispatch_get_main_queue(), ^{
                // User *user =[[User alloc] initWithDictionary:responseArray];
                fr._id = responseArray[@"_id"];
                fr.name = responseArray[@"name"];
                fr.location = [[Location alloc] init];
                fr.location.latitude = [[responseArray valueForKeyPath:@"curent_location.latitude"] doubleValue];
                fr.location.longitude = [[responseArray valueForKeyPath:@"curent_location.longitude"] doubleValue] ;
                ok = YES;
                // });
                
                
                
            } else {
                //error;
                
            }
        }
    }];
    
    [dataTask resume];
    while (!ok) {
        
    }
    return fr;
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

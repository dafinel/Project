//
//  CereriTableViewController.m
//  project
//
//  Created by Andrei-Daniel Anton on 19/08/14.
//  Copyright (c) 2014 Andrei-Daniel Anton. All rights reserved.
//
#import "CereriTableViewController.h"

#define kBaseURL @"http://localhost:3000/"
#define kLocations @"users"

@interface CereriTableViewController ()

@end

@implementation CereriTableViewController

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
    return [self.cereri count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cerere" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *cerere = self.cereri[indexPath.row];
    cell.textLabel.text = cerere[@"name"];
    [[NSUserDefaults standardUserDefaults]setValue:cerere forKey:@"idprieten"];
    UIButton *but = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    but.frame = CGRectMake(cell.frame.size.width - 70 , cell.frame.origin.y, 70, 44);
    [but setTitle:@"Accept" forState:UIControlStateNormal];
    [but setBackgroundColor:[UIColor clearColor]];
    [but addTarget:self action:@selector(acceptAction) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:but];
    
    
    
   
    
    

    return cell;
}

- (void)acceptAction {
    NSString *udid = [[NSUserDefaults standardUserDefaults]stringForKey:@"_id"];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"idprieten"];
    NSString *idprieten = [NSString stringWithFormat:@"%@",dic[@"_id"]];
    udid = [NSString stringWithFormat:@"/yes/%@/%@",idprieten,udid];
    NSURL * url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kLocations]];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:udid]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { //5
        if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cereri removeObject:dic];
            [self.tableView reloadData];
        });
        }
    }];
    [dataTask resume];
    

    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

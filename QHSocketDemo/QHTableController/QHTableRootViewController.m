//
//  QHTableRootViewController.m
//  QHTableDemo
//
//  Created by chen on 17/3/13.
//  Copyright © 2017年 chen. All rights reserved.
//

#import "QHTableRootViewController.h"

#import "QHDetailRootViewController.h"
#import "QHTableSubViewController.h"

#import "QHSocketServerViewController.h"
#import "QHSockettClientViewController.h"
#import "QHCFSocketServerViewController.h"
#import "QHCFSocketClientViewController.h"
#import "QHCocoaAsyncSocketClientViewController.h"
#import "QHCocoaAsyncSocketServerViewController.h"
#import "QHSocketHttpViewController.h"
#import "QHCFSocketBytesClientViewController.h"
#import "QHSRSocketClientViewController.h"
#import "QHSocketIOClientViewController.h"
#import "QHSimplePingViewController.h"

@interface QHTableRootViewController ()

@property (nonatomic, strong) NSMutableArray *arData;

@end

@implementation QHTableRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [task resume];
    
    NSArray *array = @[@"SocketServer", @"SocketClient", @"CFSocketServer", @"CFSocketClient", @"CocoaAsyncSocketServer", @"CocoaAsyncSocketClient", @"SRSocketClient", @"SocketIOClient", @"SocketHttp", @"CFSocketBytes", @"QHSimplePing"];
    self.arData = [NSMutableArray arrayWithArray:array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCellIdentity" forIndexPath:indexPath];
    
    cell.textLabel.text = self.arData[indexPath.row];
    
    return cell;
}

#pragma mark - 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = self.arData[indexPath.row];
    
    UIViewController *subVC = nil;
    if ([title isEqualToString:@"SocketServer"]) {
        subVC = [[QHSocketServerViewController alloc] init];
    }
    else if ([title isEqualToString:@"SocketClient"]) {
        subVC = [[QHSockettClientViewController alloc] init];
    }
    else if ([title isEqualToString:@"CFSocketServer"]) {
        subVC = [QHCFSocketServerViewController new];
    }
    else if ([title isEqualToString:@"CFSocketClient"]) {
        subVC = [QHCFSocketClientViewController new];
    }
    else if ([title isEqualToString:@"CocoaAsyncSocketServer"]) {
        subVC = [QHCocoaAsyncSocketServerViewController new];
    }
    else if ([title isEqualToString:@"CocoaAsyncSocketClient"]) {
        subVC = [QHCocoaAsyncSocketClientViewController new];
    }
    else if ([title isEqualToString:@"SRSocketClient"]) {
        subVC = [QHSRSocketClientViewController new];
    }
    else if ([title isEqualToString:@"SocketIOClient"]) {
        subVC = [QHSocketIOClientViewController new];
    }
    else if ([title isEqualToString:@"SocketHttp"]) {
        subVC = [QHSocketHttpViewController new];
    }
    else if ([title isEqualToString:@"CFSocketBytes"]) {
        subVC = [QHCFSocketBytesClientViewController new];
    }
    else if ([title isEqualToString:@"QHSimplePing"]) {
        subVC = [QHSimplePingViewController new];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        subVC = [storyboard instantiateViewControllerWithIdentifier:@"QHDetsilRootID"];
    }
    
    [subVC.navigationItem setTitle:title];
    [self.navigationController pushViewController:subVC animated:YES];
}

@end

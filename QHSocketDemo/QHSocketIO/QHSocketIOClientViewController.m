//
//  QHSocketIOClientViewController.m
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/2/25.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHSocketIOClientViewController.h"

@import SocketIO;

@interface QHSocketIOClientViewController ()

@property (nonatomic, strong) SocketManager *manager;

@end

@implementation QHSocketIOClientViewController

- (void)dealloc
{
    NSLog(@"QHSocketIOClientViewController dealloc");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navigationController.topViewController != self) {
        SocketIOClient* socket = _manager.defaultSocket;
        [socket disconnect];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSURL* url = [[NSURL alloc] initWithString:@"http://127.0.0.1:21025"];
    _manager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @YES, @"compress": @YES}];
    SocketIOClient* socket = _manager.defaultSocket;
    
    [socket on:@"Server" callback:^(NSArray * data, SocketAckEmitter * ack) {
        NSLog(@"Server say: %@", data);
    }];
    
    [socket connect];
}

- (IBAction)sendAction:(id)sender {
    SocketIOClient* socket = _manager.defaultSocket;
    [socket emit:@"event" with:@[@"hello"]];
}

@end

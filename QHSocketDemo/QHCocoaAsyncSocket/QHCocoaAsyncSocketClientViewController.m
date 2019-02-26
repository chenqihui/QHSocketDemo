//
//  QHCocoaAsyncSocketClientViewController.m
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/1/22.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHCocoaAsyncSocketClientViewController.h"

#import <CocoaAsyncSocket/GCDAsyncSocket.h>

#define TEST_IP_PROT 21025
/** 替换成你需要连接服务器绑定的IP地址，不能随便输*/
#define TEST_IP_ADDR @"127.0.0.1"//@"10.4.64.49"
//#define TEST_IP_ADDR @"192.168.2.17"

@interface QHCocoaAsyncSocketClientViewController () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@property (nonatomic) dispatch_queue_t socketQueue;

@end

@implementation QHCocoaAsyncSocketClientViewController

- (void)dealloc
{
    NSLog(@"QHCocoaAsyncSocketClientViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _socketQueue = dispatch_queue_create("socketQueue", NULL);
    
    _clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    
    NSError *error = nil;
    BOOL connected = [self.clientSocket connectToHost:TEST_IP_ADDR onPort:TEST_IP_PROT viaInterface:nil withTimeout:-1 error:&error];

}

- (void)p_write {
    NSData *data = [@"hello, I am client" dataUsingEncoding:NSUTF8StringEncoding];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [self.clientSocket writeData:data withTimeout:- 1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"read-->%@", text);
    // 读取到服务端数据值后,能再次读取
    [_clientSocket readDataWithTimeout:- 1 tag:0];
}

#pragma mark - Action

- (IBAction)sendAction:(id)sender {
    [self p_write];
}

@end

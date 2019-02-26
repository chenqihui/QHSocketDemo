//
//  QHCocoaAsyncSocketServerViewController.m
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/1/22.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHCocoaAsyncSocketServerViewController.h"

#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "QHCFSocketBytesClientViewController.h"
#import "Qhpbdemo.pbobjc.h"

#define TEST_IP_PROT 21024

@interface QHCocoaAsyncSocketServerViewController () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
@property (nonatomic) dispatch_queue_t socketQueue;
@property (nonatomic, strong) NSMutableArray *connectedSockets;

@property (weak, nonatomic) IBOutlet UITextView *contentTV;

@end

@implementation QHCocoaAsyncSocketServerViewController

- (void)dealloc
{
    NSLog(@"QHCocoaAsyncSocketServerViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _connectedSockets = [NSMutableArray new];
    _socketQueue = dispatch_queue_create("socketQueue", NULL);
    
    _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    
    NSError *error = nil;
    BOOL bResult = [_serverSocket acceptOnPort:TEST_IP_PROT error:&error];
}

- (void)p_sendMessage:(NSString *)msg
{
    if(_connectedSockets == nil) return;
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [_connectedSockets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj writeData:data withTimeout:-1 tag:0];
    }];
}

- (void)p_addContent:(NSString *)content {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *c = [[NSMutableString alloc] initWithString:self.contentTV.text];
        [c appendString:content];
        [c appendString:@"\r\n"];
        self.contentTV.text = c;
    });
}

#pragma mark - GCDAsyncSocketDelegate

// 连接上新的客户端socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(nonnull GCDAsyncSocket *)newSocket
{
    // 保存客户端的socket
    [_connectedSockets addObject: newSocket];
    // 添加定时器
    NSLog(@"客户端的地址: %@ -------端口: %d", newSocket.connectedHost, newSocket.connectedPort);
    
    [newSocket readDataWithTimeout:- 1 tag:0];
    
    [self p_sendMessage:@"welcome"];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"client say: %@", text);
//    [self p_addContent:text];
//    [self p_sendMessage:text];
    
//    QHSocketByteObj *obj = [QHSocketByteObj new];
//    [obj readChar:data];
    
//    QHPBDemo *pbObj = [QHPBDemo parseFromData:data error:nil];
//    [self p_addContent:pbObj.description];
    
    [sock readDataWithTimeout:-1 tag:0];
    
    [self p_sendMessage:@"收到收到"];
}

@end

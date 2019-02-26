//
//  QHSocketServerViewController.m
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/1/18.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHSocketServerViewController.h"

#import <arpa/inet.h>
#import <netinet/in.h>
#import <sys/socket.h>

#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>

@interface QHSocketServerViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UISwitch *onSwitch;
@property (weak, nonatomic) IBOutlet UITextField *speakTF;
@property (weak, nonatomic) IBOutlet UITextView *contentTV;
@property (weak, nonatomic) IBOutlet UILabel *ipL;

@property (nonatomic) int socketServer;
@property (nonatomic) int acceptSocketClient;

@property (nonatomic) BOOL bOn;

@end

@implementation QHSocketServerViewController

- (void)dealloc {
    NSLog(@"QHSocketServerViewController dealloc");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navigationController.topViewController != self) {
        [self p_closeSocket:_socketServer];
//        [self p_closeSocket:_acceptSocketClient];
        _bOn = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _socketServer = -1;
    _bOn = NO;
    NSString *ip = [QHSocketServerViewController localWiFiIPAddress];
    _ipL.text = ip;
    _portTF.text = @"21024";
}

- (void)p_addContent:(NSString *)content {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *c = [[NSMutableString alloc] initWithString:self.contentTV.text];
        [c appendString:content];
        [c appendString:@"\r\n"];
        self.contentTV.text = c;
    });
}

- (void)p_closeSocket:(int)socket {
    if (socket >= 0) {
        
//        int opt = 1;
//        int len = sizeof(opt);
//        setsockopt(socket, SOL_SOCKET, SO_REUSEADDR, &opt, &len);
        
        BOOL  bDontLinger = FALSE;
        setsockopt(socket, SOL_SOCKET, SO_LINGER, (const char*)&bDontLinger, sizeof(BOOL));
        
        shutdown(socket, SHUT_RDWR);
        close(socket);
    }
}

- (BOOL)p_connectAndListenWith:(NSInteger)port {
    BOOL bResult = NO;
    
    _socketServer = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if (_socketServer != -1) {
        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port = htons(port);
        addr.sin_addr.s_addr = INADDR_ANY;
        
        int bindAddrResult = bind(_socketServer, (const struct sockaddr *)&addr, sizeof(addr));
        if (bindAddrResult == 0) {
            int listenResult = listen(_socketServer, 1); // 等待的连接数
            if (listenResult == 0) {
                bResult = YES;
            }
        }
    }
    return bResult;
}

- (void)p_accept {
    struct sockaddr_in peeraddr;
    socklen_t addrLen;
    addrLen = sizeof(peeraddr);
    
    _acceptSocketClient = accept(_socketServer, (struct sockaddr *restrict)&peeraddr, &addrLen);
//    if (_acceptSocketClient != -1) {
//
//        char buf[1024];
//        size_t len = sizeof(buf);
//
//        recv(_acceptSocketClient, buf, len, 0);
//
//        NSString *clientIp = [NSString stringWithUTF8String:inet_ntoa(peeraddr.sin_addr)];
//        NSString *clientPort = [NSString stringWithFormat:@"%d", ntohs(peeraddr.sin_port)];
//        NSString *content = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
//
//        [self p_addContent:[NSString stringWithFormat:@"（%@:%@）", clientIp, clientPort]];
//        [self p_addContent:[NSString stringWithFormat:@"Client:%@", content]];
//    }
    
    if (_acceptSocketClient != -1) {
        char buf[1024];
        size_t len = sizeof(buf);
        long readData;
        while ((readData = recv(_acceptSocketClient, buf, len, 0)) && _bOn == YES) {
            NSString *content = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
            [self p_addContent:[NSString stringWithFormat:@"Client:%@", content]];
            memset(buf, 0, 1024);
        }
    }
}

- (void)p_send:(int)socketClient msg:(NSString *)msg {
    dispatch_queue_t q_con =  dispatch_queue_create("CONCURRENT", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(q_con, ^{
        const char *str = msg.UTF8String;
        send(socketClient, str, strlen(str), 0);
        [self p_addContent:[NSString stringWithFormat:@"Server:%@", msg]];
        
//        char *buf[1024];
//        ssize_t recvLen = recv(socketClient, buf, sizeof(buf), 0);
//        NSString *recvStr = [[NSString alloc] initWithBytes:buf length:recvLen encoding:NSUTF8StringEncoding];
//        [self p_addContent:[NSString stringWithFormat:@"Client:%@", recvStr]];
    });
}

// [03-WIFI通讯获取Wifi名称及ip地址 - 坤小的专栏 - CSDN博客](https://blog.csdn.net/u013263917/article/details/77151545)
+ (NSString *)localWiFiIPAddress {
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _speakTF) {
        NSString *msg = textField.text.copy;
        [self p_send:_acceptSocketClient msg:msg];
        textField.text = nil;
    }
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Action

- (IBAction)onAction:(UISwitch *)sender {
    if (sender.on) {
        sender.on = [self p_connectAndListenWith:[_portTF.text integerValue]];
    }
    _bOn = sender.on;
    if (_bOn == NO) {
        [self p_closeSocket:_socketServer];
    }
    else {
        __weak typeof(self) weakSelf = self;
        dispatch_queue_t SERIAL_QUEUE =  dispatch_queue_create("SERIAL", DISPATCH_QUEUE_SERIAL);
        dispatch_async(SERIAL_QUEUE, ^{
//            while (weakSelf.bOn) {
                [weakSelf p_accept];
//            }
        });
    }
}

@end

//
//  QHSockettClientViewController.m
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/1/21.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHSockettClientViewController.h"

#import <arpa/inet.h>
#import <netinet/in.h>
#import <sys/socket.h>

@interface QHSockettClientViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *ipTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UISwitch *onSwitch;
@property (weak, nonatomic) IBOutlet UITextField *speakTF;
@property (weak, nonatomic) IBOutlet UITextView *contentTV;

@property (nonatomic) int socketClient;

@end

@implementation QHSockettClientViewController

- (void)dealloc {
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navigationController.topViewController != self) {
        [self p_closeSocket:_socketClient];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _ipTF.text = @"10.4.64.49";
//    _ipTF.text = @"192.168.2.17";
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
        int r = shutdown(socket, SHUT_WR);
        int rr = close(socket);
        int y = 1;
    }
}

- (BOOL)p_connectServer:(NSString *)ip port:(NSInteger)port {
    _socketClient = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    struct sockaddr_in addr;
    
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr(ip.UTF8String);
    
    int connectResult = connect(_socketClient, (const struct sockaddr *)&addr, sizeof(addr));
    
    if (connectResult == 0) {
        return YES;
    }
    return NO;
}

- (void)p_sendMsg:(NSString *)msg {
//    dispatch_queue_t q_con =  dispatch_queue_create("CONCURRENT", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(q_con, ^{
        const char *str = msg.UTF8String;
        ssize_t sendLen = send(self.socketClient, str, strlen(str), 0);
        [self p_addContent:[NSString stringWithFormat:@"Client:%@", msg]];
        
//        char *buf[1024];
//        ssize_t recvLen = recv(self.socketClient, buf, sizeof(buf), 0);
//        NSString *recvStr = [[NSString alloc] initWithBytes:buf length:recvLen encoding:NSUTF8StringEncoding];
//        [self p_addContent:[NSString stringWithFormat:@"Server:%@", recvStr]];
//    });
}

#pragma mark - Action

- (IBAction)onAction:(UISwitch *)sender {
    if (sender.on) {
        sender.on = [self p_connectServer:_ipTF.text port:[_portTF.text integerValue]];
    }
    
    if (sender.on == NO) {
        [self p_closeSocket:_socketClient];
    }
    else {
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            long recvLen;
            char buf[1024];
           NSMutableString *contentString = nil;
            while ((recvLen = recv(self.socketClient, buf, sizeof(buf), 0))) {
//                if (recvLen == -1) {
//                    break;
//                }
                if (recvLen < 0) {
                    // 由于是非阻塞的模式,所以当buflen为EAGAIN时,表示当前缓冲区已无数据可读
                    // 在这里就当作是该次事件已处理
                    if (recvLen == EAGAIN) {
                        break;
                    }
                    else {
                        return;
                    }
                }
                else if (recvLen == 0) {
                    // 这里表示对端的socket已正常关闭.
                    break;
                }

                if (contentString == nil) {
                    contentString = [NSMutableString new];
                }
                NSString *recvStr = [[NSString alloc] initWithBytes:buf length:recvLen encoding:NSUTF8StringEncoding];
                if (recvStr != nil) {
                    [contentString appendString:recvStr];
                    if (recvLen != sizeof(buf)) {
                        [self p_addContent:[NSString stringWithFormat:@"Server:%@", contentString]];
                        contentString = nil;
                    }
                    else {
                    }
                }
            }
       });
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _speakTF) {
        NSString *msg = textField.text.copy;
        [self p_sendMsg:msg];
        textField.text = nil;
    }
    [textField resignFirstResponder];
    return NO;
}

@end

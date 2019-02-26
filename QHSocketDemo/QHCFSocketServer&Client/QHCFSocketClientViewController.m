//
//  QHCFSocketClientViewController.m
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/1/21.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHCFSocketClientViewController.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>

/** 这个端口可以随便设置*/
#define TEST_IP_PROT 21026
/** 替换成你需要连接服务器绑定的IP地址，不能随便输*/
#define TEST_IP_ADDR @"10.4.64.49"
//#define TEST_IP_ADDR @"192.168.2.17"

@interface QHCFSocketClientViewController ()

@property (nonatomic) CFSocketRef socketRef;

@end

@implementation QHCFSocketClientViewController

- (void)dealloc {
    NSLog(@"QHCFSocketClientViewController dealloc");
}

- (void)viewDidDisappear:( BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navigationController.topViewController != self) {
        [self _releseSocket];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self p_connectServer:TEST_IP_ADDR port:TEST_IP_PROT];
}

- (BOOL)p_connectServer:(NSString *)ip port:(NSInteger)port {
    if (!_socketRef) {
        
        // 创建socket关联的上下文信息
        
        /*
         typedef struct {
         CFIndex    version; 版本号, 必须为0
         void *    info; 一个指向任意程序定义数据的指针，可以在CFSocket对象刚创建的时候与之关联，被传递给所有在上下文中回调
         const void *(*retain)(const void *info); info 指针中的retain回调，可以为NULL
         void    (*release)(const void *info); info指针中的release回调，可以为NULL
         CFStringRef    (*copyDescription)(const void *info); 回调描述，可以n为NULL
         } CFSocketContext;
         
         */
        
        CFSocketContext sockContext = {0, (__bridge void *)(self), NULL, NULL, NULL};
        
        //创建一个socket
        _socketRef = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, ServerConnectCallBack, &sockContext);
        if (_socketRef == NULL) {
            NSLog(@"创建失败");
            return NO;
        }
        //创建sockadd_in的结构体，改结构体作为socket的地址，IPV6需要改参数
        
        //sockaddr_in
        // sin_len;  长度
        //sin_family;协议簇， 用AF_INET -> 互联网络， TCP，UDP 等等
        //sin_port; 端口号（使用网络字节顺序）htons:将主机的无符号短整形数转成网络字节顺序
        //in_addr sin_addr; 存储IP地址， inet_addr()的功能是将一个点分十进制的IP转换成一个长整型数(u_long类型)，若字符串有效则将字符串转换为32位二进制网络字节序的IPV4地址， 否则为IMADDR_NONE
        //sin_zero[8]; 让sockaddr与sockaddr_in 两个数据结构保持大小相同而保留的空字节，无需处理
        
        struct sockaddr_in Socketaddr;
        //memset： 将addr中所有字节用0替代并返回addr，作用是一段内存块中填充某个给定的值，它是对较大的结构体或数组进行清零操作的一种最快方法
        memset(&Socketaddr, 0, sizeof(Socketaddr));
        Socketaddr.sin_len = sizeof(Socketaddr);
        Socketaddr.sin_family = AF_INET;
        Socketaddr.sin_port = htons(port);
        Socketaddr.sin_addr.s_addr = inet_addr(ip.UTF8String);
        
        //将地址转化为CFDataRef
        CFDataRef dataRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&Socketaddr, sizeof(Socketaddr));
        
        //连接
        //CFSocketError    CFSocketConnectToAddress(CFSocketRef s, CFDataRef address, CFTimeInterval timeout);
        //第一个参数  连接的socket
        //第二个参数  连接的socket的包含的地址参数
        //第三个参数 连接超时时间，如果为负，则不尝试连接，而是把连接放在后台进行，如果_socket消息类型为kCFSocketConnectCallBack，将会在连接成功或失败的时候在后台触发回调函数
        CFSocketConnectToAddress(_socketRef, dataRef, -1);

        //加入循环中
        //获取当前线程的runLoop
        CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
        //把socket包装成CFRunLoopSource, 最后一个参数是指有多个runloopsource通过一个runloop时候顺序，如果只有一个source 通常为0
        CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socketRef, 0);

        //加入运行循环
        //第一个参数：运行循环管
        //第二个参数： 增加的运行循环源, 它会被retain一次
        //第三个参数：用什么模式把source加入到run loop里面,使用kCFRunLoopCommonModes可以监视所有通常模式添加source
        CFRunLoopAddSource(runloopRef, sourceRef, kCFRunLoopCommonModes);

        //之前被retain一次，这边要释放掉
        CFRelease(sourceRef);
        
//        CFSocketError result = CFSocketConnectToAddress(_socketRef, dataRef, 5);
    }
    return YES;
}

/**
 回调函数
 
 @param s socket对象
 @param callbackType 这个socket对象的活动类型
 @param address socket对象连接的远程地址，CFData对象对应的是socket对象中的protocol family (struct sockaddr_in 或者 struct sockaddr_in6), 除了type 类型 为kCFsocketAcceptCallBack 和kCFSocketDataCallBack ，否则这个值通常是NULL
 @param data 跟回调类型相关的数据指针
 kCFSocketConnectCallBack : 如果失败了， 它指向的就是SINT32的错误代码
 kCFSocketAcceptCallBack : 它指向的就是CFSocketNativeHandle
 kCFSocketDataCallBack : 它指向的就是将要进来的Data
 其他情况就是NULL
 
 @param info 与socket相关的自定义的任意数据
 
 */
void ServerConnectCallBack (CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
    QHCFSocketClientViewController *vc = (__bridge QHCFSocketClientViewController *)(info);
    //判断是不是NULL
    if (data != NULL)
    {
        printf("----->>>>>>连接失败\n");
        
        [vc performSelector:@selector(_releseSocket) withObject:nil];
        
    }
    else
    {
        printf("----->>>>>>连接成功\n");
        [vc performSelectorInBackground:@selector(_readStreamData) withObject:nil];
        
    }
    
}

- (void)sendMessage:(NSString *)msg {
    
    if (!_socketRef) {
        // 请先连接服务器
        return;
    }
    
    const char* data       = [msg UTF8String];
    
    /** 成功则返回实际传送出去的字符数, 失败返回-1. 错误原因存于errno*/
    long sendData          = send(CFSocketGetNative(_socketRef), data, strlen(data) + 1, 0);
    
    if (sendData < 0) {
        perror("send");
    }
}

- (void)_readStreamData
{
    //定义一个字符型变量
    char buffer[512];
    
    /*
     int recv(SOCKET s, char FAR *buf, int len, int flags);
     
     不论是客户还是服务器应用程序都用recv函数从TCP连接的另一端接收数据
     1. 第一个参数指定接收端套接字描述符
     2.第二个参数指明一个缓冲区，改缓冲区用来存放recv函数接受到的数据
     3. 第三个参数指明buf的长度
     4.第四个参数一般置0
     
     */
    
    long readData;
    //若无错误发生，recv() 返回读入的字节数。如果连接已终止，返回0 如果发生错误，返回-1， 应用程序可通过perror() 获取相应错误信息
    while ((readData = recv(CFSocketGetNative(_socketRef), buffer, sizeof(buffer), 0))) {
        if (readData <= 0) {
            break;
        }
        NSString *content = [[NSString alloc] initWithBytes:buffer length:readData encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            self.infoLabel.text = [NSString stringWithFormat:@"%@\n%@", content, self.infoLabel.text];
            NSLog(@"%@", content);
        });
        
    }
    
    perror("++++++recv+++++++++");
    
}

- (void)_releseSocket
{
    if (_socketRef) {
        CFSocketInvalidate(_socketRef);
        CFRelease(_socketRef);
    }
    
    _socketRef = NULL;
    
//    self.infoLabel.text = @"----->>>>>>连接失败-----";
    
    
}

#pragma mark - Action

- (IBAction)sendAction:(id)sender {
    [self sendMessage:@"hello"];
}

@end

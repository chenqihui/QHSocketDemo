//
//  QHSocketHttpViewController.m
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/1/22.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHSocketHttpViewController.h"

#import <WebKit/WebKit.h>
#import <arpa/inet.h>
#import <netinet/in.h>
#import <sys/socket.h>

#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface QHSocketHttpViewController () <WKNavigationDelegate, WKUIDelegate, GCDAsyncSocketDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) int clientSocket;

@property (nonatomic, strong) GCDAsyncSocket *asyncClientSocket;

@end

@implementation QHSocketHttpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addWebView];
    
//    [self testWeb];
    
//    [self socketDemo];
    
    [self initGCDAsync];
}

@end

@implementation QHSocketHttpViewController (Web)

- (void)addWebView {
    // [让iOS项目允许使用http协议请求 - harry_h - 博客园](https://www.cnblogs.com/harry-h/p/6010193.html)
    // [关于WKWebView加载HTTPS网页不显示的解决方案 - 简书](https://www.jianshu.com/p/ce1936d45daf)
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(10, 84, [UIScreen mainScreen].bounds.size.width - 20, 300) configuration:config];
    //    _webView.navigationDelegate = self;
    //    _webView.UIDelegate = self;
    _webView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_webView];
}

- (void)testWeb {
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [_webView loadRequest:request];
    
    //    NSURL *url = [NSURL URLWithString:@"https://qf.56.com/index_h5.html"];
    //    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    //    [_webView loadRequest:request];
}

- (NSString *)requsetString {
    return nil;
}

@end

@implementation QHSocketHttpViewController (Socket)

- (void)socketDemo {
    
    //    //连接百度
    //    [self connectToServer:@"115.239.210.27" port:80];
    //
    //    //发送HTTP格式请求
    //    NSString *requestStr =@"GET / HTTP/1.1\r\n"
    //    "Host: www.baidu.com\r\n"
    //    "Connection: close\r\n\r\n";
    //    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com/"];
    
    //    [self connectToServer:@"185.199.111.153" port:80];
    //    NSString *requestStr =@"GET /2019/01/16/iOS-组合礼物特效/ HTTP/1.1\r\n"
    //    "Host: chenqihui.github.io\r\n"
    //    "Connection: close\r\n\r\n";
    //    NSURL *url = [NSURL URLWithString:@"http://chenqihui.github.io/"];
    
    [self connectToServer:@"183.56.168.99" port:80];
    NSString *requestStr =@"GET / HTTP/1.1\r\n"
    "Host: qf.56.com\r\n"
    "Connection: close\r\n\r\n";
    NSURL *url = [NSURL URLWithString:@"http://qf.56.com/"];
    
    //    [self connectToServer:@"115.239.210.27" port:80];
    //    NSString *requestStr =@"GET /s?ie=utf-8&newi=1&mod=1&isbd=1&isid=9770815b00016318&wd=hello&rsv_spt=1&rsv_iqid=0xb0d21ace00013900&issp=1&f=3&rsv_bp=1&rsv_idx=2&ie=utf-8&rqlang=cn&tn=baiduhome_pg&rsv_enter=0&oq=12%2526lt%253B&rsv_t=d8d2eyqKRfSj7pCTzAGYv5gaMcMyksGoqOdklT5lwBUbZ69sbPVRVFWB4a%2FrUD3LqAto&inputT=6286&rsv_pq=9770815b00016318&rsv_sug3=8&rsv_sug1=8&rsv_sug7=100&prefixsug=hello&rsp=1&rsv_sug4=6286&bs=123&rsv_sid=1462_21095_20883_28329_28131_27245&_ss=1&clist=f9d0a569a95c3cc5%0923919995d7bce975&hsug=&f4s=1&csor=5&_cr1=39981 HTTP/1.1\r\n"
    //    "Host: www.baidu.com\r\n"
    //    "Connection: close\r\n\r\n";
    //    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com/"];
    
    //获取响应
    NSString *responseStr = [self sentAndRecv:requestStr];
    NSLog(@"%@", responseStr);
    NSLog(@"------------------------------------------");
    
    //分离响应体
    //    第一种方式分割:
    NSRange range = [responseStr rangeOfString:@"\r\n\r\n"];
    NSString *htmlStr = [responseStr substringFromIndex:range.location+range.length];
    NSLog(@"%@",htmlStr);
    //    第二种方式分割:
    NSArray * htmlArray = [responseStr componentsSeparatedByString:@"\r\n\r\n"];
    NSString * htmlStr2 = [htmlArray lastObject];
    NSLog(@"------------------------------------------");
    NSLog(@"%@",htmlStr2);
    
    
    //网页数据使用webview来显示
    //http://www.baidu.com/1.png ./1.png
    [self.webView loadHTMLString:htmlStr baseURL:url];
}

#pragma mark - 建立连接
- (void)connectToServer:(NSString *)ip port:(int)port{
    
    _clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    struct sockaddr_in addr;
    /* 填写sockaddr_in结构*/
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr(ip.UTF8String);
    
    int connectResult = connect(_clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
    
    if (connectResult == 0) {
        NSLog(@"连接成功");
    }
}

#pragma mark - 发送请求获取响应体数据
- (NSString *)sentAndRecv:(NSString *)msg {
    const char *str = msg.UTF8String;
    ssize_t sentLen = send(_clientSocket, str, strlen(str), 0);
    
    //数据的累加
    NSMutableString *mStr = [NSMutableString string];
    
    /*
     1.socket
     2.存放数据的缓冲区
     3.缓冲区长度。
     4.指定调用方式。 0
     返回值 接收成功的字符数
     */
    char *buf[1024];
    ssize_t recvLen = recv(_clientSocket, buf, sizeof(buf), 0);
    
    NSString *recvStr = [[NSString alloc] initWithBytes:buf length:recvLen encoding:NSUTF8StringEncoding];
    
    [mStr appendString:recvStr];
    
    // 不断的获取数据 判断的依据是recvLen
    while (recvLen != 0) {
        // [recv函数返回值说明 - tiandyoin的专栏 - CSDN博客](https://blog.csdn.net/tiandyoin/article/details/30044781)
        recvLen = recv(_clientSocket, buf, sizeof(buf), 0);
        if (recvLen > 0) {
            NSString *recvStr = [[NSString alloc] initWithBytes:buf length:recvLen encoding:NSUTF8StringEncoding];
            
            if (recvStr != nil && recvStr.length > 0) {
                [mStr appendString:recvStr];
            }
        }
    }
    return mStr.copy;
}

@end

@implementation QHSocketHttpViewController (GCDAsync)

- (void)initGCDAsync {
    self.asyncClientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [self.asyncClientSocket startTLS:nil];
    [self secureSocket:_asyncClientSocket];
//    NSString *host = @"www.baidu.com";
    NSString *host = @"qf.56.com";
    int port = 443;
    NSError *error;
    BOOL connected = [self.asyncClientSocket connectToHost:host onPort:port error:&error];
    if (connected == NO) {
        NSLog(@"connected fail");
    }
    if (error != nil) {
        NSLog(@"error=%@", error);
    }
}

- (void)writeGCDAsync {
//    NSString *requestStr =@"GET / HTTP/1.1\r\n"
//    "Host: www.baidu.com\r\n"
//    "Connection: close\r\n\r\n";
    NSString *requestStr =@"GET / HTTP/1.1\r\n"
    "Host: qf.56.com\r\n"
    "Connection: close\r\n\r\n";
    NSData *data = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncClientSocket writeData:data withTimeout:- 1 tag:0];
}

- (void)doTLSConnect:(GCDAsyncSocket *)sock {
    //HTTPS
    NSMutableDictionary *sslSettings = [[NSMutableDictionary alloc] init];
    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xxx.xxxxxxx.com" ofType:@"p12"]];//已经支持https的网站会有CA证书，给服务器要一个导出的p12格式证书
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(pkcs12data);
    CFStringRef password = CFSTR("xxxxxx");//这里填写上面p12文件的密码
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus securityError = SecPKCS12Import(inPKCS12Data, options, &items);
    CFRelease(options);
    CFRelease(password);
    
    if (securityError == errSecSuccess) {
        NSLog(@"Success opening p12 certificate.");
    }
    
    CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
    SecIdentityRef myIdent = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
    SecIdentityRef  certArray[1] = { myIdent };
    CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
    [sslSettings setObject:(id)CFBridgingRelease(myCerts) forKey:(NSString *)kCFStreamSSLCertificates];
    [sslSettings setObject:@"api.pandaworker.com" forKey:(NSString *)kCFStreamSSLPeerName];
    [sock startTLS:sslSettings];//最后调用一下GCDAsyncSocket这个方法进行ssl设置就Ok了
}

- (void)secureSocket:(GCDAsyncSocket *)sock
{
    // The root self-signed certificate I have created
    NSString *certificatePath = [[NSBundle mainBundle] pathForResource:@"*.56.com_rsa" ofType:@"cer"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certificatePath];
    CFDataRef certDataRef = (CFDataRef)CFBridgingRetain(certData);
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, certDataRef);
    
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();         // 3
    
    // the "identity" certificate
    SecCertificateRef certArray[1] = { cert };
    CFArrayRef myCerts = CFArrayCreate(
                                       NULL, (void *)certArray,
                                       1, NULL);
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(
                                                     myCerts,
                                                     myPolicy,
                                                     &myTrust);  // 4
    
    // the SSL configuration
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
    [settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsExpiredRoots];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsExpiredCertificates];
    [settings setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
    [settings setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString*)kCFStreamSSLLevel];
    [settings setObject:(id)CFBridgingRelease(myCerts) forKey:(NSString *)kCFStreamSSLCertificates];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLIsServer];
//    [settings setObject:@"*.56.com" forKey:(NSString *)kCFStreamSSLPeerName];
    [sock startTLS:settings];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"isSecure=%d", sock.isSecure);
    [self writeGCDAsync];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"read-->%@", text);
    [self.webView loadHTMLString:text baseURL:nil];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    //https安全认证成功时会调用
    NSLog(@"SSL握手成功，安全通信已经建立连接!");
}

@end

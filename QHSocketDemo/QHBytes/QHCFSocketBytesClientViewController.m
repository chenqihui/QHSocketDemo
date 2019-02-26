//
//  QHCFSocketBytesClientViewController.m
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/1/24.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHCFSocketBytesClientViewController.h"
#import "Qhpbdemo.pbobjc.h"

@interface QHCFSocketBytesClientViewController ()

@property (nonatomic) CFWriteStreamRef writeStreamRef;
@property (nonatomic) CFReadStreamRef readStreamRef;
@property (nonatomic) BOOL bBytes;

@end

@implementation QHCFSocketBytesClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    QHSocketByteObj *obj = [QHSocketByteObj new];
//    NSData *d = [obj writeChar];
//    [obj readChar:d];
    
    _bBytes = NO;
    [self initSocket];
}

- (void)initSocket {
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)@"10.4.64.31", 1028, &_readStreamRef, &_writeStreamRef);
    
    if (_readStreamRef != NULL && _writeStreamRef != NULL) {
        CFReadStreamSetProperty(_readStreamRef, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(_writeStreamRef, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
        CFSocketContext theContext={0};
//        theContext.info=CFBridgingRetain(self);
        CFOptionFlags readevents=kCFStreamEventHasBytesAvailable|kCFStreamEventErrorOccurred|kCFStreamEventEndEncountered|kCFStreamEventOpenCompleted;
        if(!CFReadStreamSetClient(_readStreamRef, readevents, bytesReadStream, (CFStreamClientContext *)(&theContext)))
        {
            goto FUNEXIT;
        }
        
        CFOptionFlags writeevents=kCFStreamEventCanAcceptBytes|kCFStreamEventErrorOccurred|kCFStreamEventEndEncountered|kCFStreamEventOpenCompleted;
        if(!CFWriteStreamSetClient(_writeStreamRef,  writeevents, bytesWriteStream, (CFStreamClientContext *)(&theContext)))
        {
            goto FUNEXIT;
        }
        CFReadStreamScheduleWithRunLoop(_readStreamRef, CFRunLoopGetCurrent(),  kCFRunLoopDefaultMode);
        CFWriteStreamScheduleWithRunLoop(_writeStreamRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        if(YES!=CFWriteStreamOpen(_writeStreamRef))
            goto FUNEXIT;
        if(YES!=CFReadStreamOpen(_readStreamRef))
            goto FUNEXIT;
    }
FUNEXIT:
    return;
}

void bytesReadStream(CFReadStreamRef readStream, CFStreamEventType eventype, void * clientCallBackInfo) {
    
    if (eventype == kCFStreamEventCanAcceptBytes) {
        UInt8 buff[2048];
        
        //    NSString *aaa = (__bridge NSString *)(clientCallBackInfo);
        //    NSLog(@"readStream+++++++>>>>>%@", aaa);
        
        //--从可读的数据流中读取数据，返回值是多少字节读到的， 如果为0 就是已经全部结束完毕，如果是-1 则是数据流没有打开或者其他错误发生
        CFIndex hasRead = CFReadStreamRead(readStream, buff, sizeof(buff));
        
        if (hasRead > 0) {
            NSLog(@"WriteStream");
            NSLog(@"----->>>>>接受到数据:%s \n", buff);
            //        const char *str = "test,  test , test \n";
            
            //向客户端输出数据
            //        CFWriteStreamWrite(self.writeStreamRef, (UInt8 *)str, strlen(str) + 1);
            
            //        QHCFSocketBytesClientViewController *vc = (__bridge QHCFSocketBytesClientViewController *)(clientCallBackInfo);
            //        if (vc.bBytes == YES) {
            //            NSString *s = [NSString stringWithFormat:@"%s", buff];
            //            NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
            //            [vc readChar:d];
            //        }
            //        vc.bBytes = NO;
        }
    }
    
}

void bytesWriteStream(CFWriteStreamRef stream, CFStreamEventType type, void *info)
{
    NSString *aaa = (__bridge NSString *)(info);
    NSLog(@"WriteStreamCallBack+++++++>>>>>%@", aaa);
}

- (IBAction)sendAction:(id)sender {
    _bBytes = YES;
//    BOOL b = CFWriteStreamCanAcceptBytes(_writeStreamRef);
    NSLog(@"sendAction");
//    // String
//    const char *str = "test,  test , test \n";
//    CFWriteStreamWrite(_writeStreamRef, (UInt8 *)str, strlen(str) + 1);
//    NSString *s = @"hello world";
//    NSData *d = [s dataUsingEncoding: NSUTF8StringEncoding];
//    CFWriteStreamWrite(_writeStreamRef, (UInt8 *)d.bytes, d.length);
    
//    // Bytes
//    QHSocketByteObj *obj = [QHSocketByteObj new];
//    NSData *d = [obj writeChar];
//    CFWriteStreamWrite(_writeStreamRef, (UInt8 *)d.bytes, d.length);
    
    // PB
    QHPBDemo *pbObj = [QHPBDemo new];
    pbObj.name = @"某某某";
    pbObj.phoneNumber = @"13812345678";
    NSData *d = pbObj.data;
    CFWriteStreamWrite(_writeStreamRef, (UInt8 *)d.bytes, d.length);
}

@end

/**
 QHSocketByteObj *obj = [QHSocketByteObj new];
 NSData *d = [obj writeChar];
 [obj readChar:d];
 */
@implementation QHSocketByteObj

- (NSData *)writeChar {
    int nOffset = 0;
    NSMutableData *data = [NSMutableData new];
    NSString *t = @"13812345678";
    NSString *n = @"某某某";
    NSInteger s = 1;
    NSInteger h = 0;
    [self writeString:t data:data output:&nOffset];
    [self writeString:n data:data output:&nOffset];
    [self writeInt:s data:data output:&nOffset];
    [self writeInt:h data:data output:&nOffset];
    return data;
}

- (void)readChar:(NSData *)data {
    int nOffset = 0;
    NSString *t = [self readStringWithData:data output:&nOffset];
    NSString *n = [self readStringWithData:data output:&nOffset];
    NSInteger s = [self readIntWithData:data output:&nOffset];
    NSInteger h = [self readIntWithData:data output:&nOffset];
    NSLog(@"%@,%@,%li,%li", t, n, (long)s, (long)h);
}

- (void)testDataLength {
    NSString *s = @"11138123456789某某某10";
    NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%d", d.length);
}

- (void)writeInt:(int)value data:(NSMutableData *)data output:(int*)nOffset {
    [data appendBytes:&value length:sizeof(int)];
    *nOffset+=sizeof(int);
}

- (void)writeString:(NSString *)value data:(NSMutableData *)data output:(int*)nOffset {
    const char* ch=[value UTF8String];
    int nLen=strlen(ch);
    [self writeInt:nLen data:data output:nOffset];
    [data appendBytes:ch length:nLen];
    *nOffset+=nLen;
}

- (int)readIntWithData:(NSData *)data output:(int*)nOffset {
    char buf[sizeof(int)];
    [data getBytes:buf range:NSMakeRange(*nOffset, sizeof(int))];
    *nOffset+=sizeof(int);
    return *(int*)buf;
}

- (NSString *)readStringWithData:(NSData *)data output:(int*)nOffset {
    int nLen = [self readIntWithData:data output:nOffset];
    char* ch=malloc(sizeof(char)*(nLen+1));
    [data getBytes:ch range:NSMakeRange(*nOffset, nLen)];
    ch[nLen]='\0';
    NSString *str = [NSString stringWithUTF8String:ch];
    free(ch);
    *nOffset+=nLen;
    return str;
}

@end

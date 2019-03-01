//
//  QHSimplePingViewController.m
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/3/1.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHSimplePingViewController.h"

#import "SimplePing.h"

@interface QHSimplePingViewController () <SimplePingDelegate>

@property (nonatomic, strong) SimplePing *pinger;

@end

@implementation QHSimplePingViewController

- (void)dealloc
{
    NSLog(@"QHSimplePingViewController dealloc");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navigationController.topViewController != self) {
        [_pinger stop];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    SimplePing *pinger = [[SimplePing alloc] initWithHostName:@"www.apple.com"];
    pinger.delegate = self;
    _pinger = pinger;
    
    [_pinger start];
}

+ (NSString *)displayAddressForAddress:(NSData *)address {
    return nil;
}

+ (NSString *)shortErrorFromError:(NSError *)error {
    return error.domain;
}

- (void)sendPing {
    [_pinger sendPingWithData:nil];
}

#pragma mark - SimplePingDelegate

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    NSLog(@"pinging %@", [QHSimplePingViewController displayAddressForAddress:address]);
    
    [self sendPing];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"failed: %@", [QHSimplePingViewController shortErrorFromError:error]);
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"#%u sent", sequenceNumber);
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    NSLog(@"#%u send failed: %@", sequenceNumber, [QHSimplePingViewController shortErrorFromError:error]);
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"#%u received, size=%zu", sequenceNumber, packet.length);
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    NSLog(@"unexpected packet, size=%zu", packet.length);
}

@end

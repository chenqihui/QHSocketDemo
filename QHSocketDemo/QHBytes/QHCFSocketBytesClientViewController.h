//
//  QHCFSocketBytesClientViewController.h
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/1/24.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHCFSocketBytesClientViewController : UIViewController

@end

@interface QHSocketByteObj : NSObject

- (NSData *)writeChar;
- (void)readChar:(NSData *)data;
- (void)testDataLength;

@end

NS_ASSUME_NONNULL_END

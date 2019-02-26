//
//  QHSocketHttpViewController.h
//  QHSocketDemo
//
//  Created by Anakin chen on 2019/1/22.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHSocketHttpViewController : UIViewController

@end

@interface QHSocketHttpViewController (Web)

- (void)addWebView;
- (void)testWeb;

@end

@interface QHSocketHttpViewController (Socket)

- (void)socketDemo;

@end

@interface QHSocketHttpViewController (GCDAsync)

- (void)initGCDAsync;
- (void)writeGCDAsync;

@end

NS_ASSUME_NONNULL_END

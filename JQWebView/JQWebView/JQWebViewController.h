//
//  JQWebViewController.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 9/11/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JQWebViewControllerProtocol.h"

// abstract class
@interface JQWebViewController : NSObject <JQWebViewControllerProtocol>

@property (nonatomic, weak) id<JQWebViewControllerDelegate> delegate;

- (id<JQURLRequestHandler>)handlerForScheme:(NSString *)scheme;

- (BOOL)isAppStoreURLString:(NSString *)urlString;

// 返回适配iOS版本的webViewController
+ (instancetype)webViewController;

@end

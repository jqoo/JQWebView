//
//  JQURLRequestHandler.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 9/14/15.
//  Copyright (c) 2015 jqoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JQWebViewProtocol.h"

@protocol JQURLRequestHandler <NSObject>

- (void)handleURLRequest:(NSURLRequest *)request;

@end

@protocol JQWebViewURLRequestHandler <JQURLRequestHandler>

@property (nonatomic, weak) id<JQWebViewProtocol> webView;

@end

//
//  JQWebViewControllerProtocol.h
//  hiloo
//
//  Created by zhang jinquan on 9/10/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JQWebViewProtocol.h"
#import "JQURLRequestHandler.h"

typedef enum {
    JQWebViewNavigationType_LinkActivated,
    JQWebViewNavigationType_FormSubmitted,
    JQWebViewNavigationType_BackForward,
    JQWebViewNavigationType_Reload,
    JQWebViewNavigationType_FormResubmitted,
    JQWebViewNavigationType_Other = -1,
} JQWebViewNavigationType;

@protocol JQWebViewControllerProtocol;

@protocol JQWebViewControllerDelegate <NSObject>

@optional

- (void)webViewControllerDidFinishLoad:(id<JQWebViewControllerProtocol>)webViewController;

- (BOOL)webViewController:(id<JQWebViewControllerProtocol>)webViewController shouldLoadWithRequest:(NSURLRequest *)request navigationType:(JQWebViewNavigationType)navigationType;

- (void)webViewController:(id<JQWebViewControllerProtocol>)webViewController didFailLoadWithError:(NSError *)error;

- (void)webViewController:(id<JQWebViewControllerProtocol>)webViewController loadInNewWebViewWithRequest:(NSURLRequest *)request;

@end

@protocol JQWebViewControllerProtocol <NSObject>

@property (nonatomic, weak) id<JQWebViewControllerDelegate> delegate;

- (UIView <JQWebViewProtocol>*)webView;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

- (void)registerScheme:(NSString *)scheme handler:(id<JQURLRequestHandler>)handler;
- (void)unregisterScheme:(NSString *)scheme;

@end

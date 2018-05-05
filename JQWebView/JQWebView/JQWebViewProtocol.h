//
//  JQWebViewProtocol.h
//  hiloo
//
//  Created by zhang jinquan on 9/10/15.
//  Copyright (c) 2015 jqoo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JQWebViewJSFunctionCompletionHandler)(id, NSError *);

@protocol JQWebViewProtocol <NSObject>

- (UIScrollView *)jq_scrollView;

- (void)jq_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;

- (id)jq_loadRequest:(NSURLRequest *)request;

- (id)jq_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

- (id)jq_reload;
- (void)jq_stopLoading;

- (BOOL)jq_canGoBack;
- (id)jq_goBack;

- (NSURL *)jq_URL;

- (void)jq_setScaleToFit:(BOOL)scaleToFit;
- (BOOL)jq_scaleToFit;

@end

extern NSString *JQWebViewEncodeJSString(NSString *jsString);
extern void JQWebViewCallJSFunction(UIView<JQWebViewProtocol> *webView, JQWebViewJSFunctionCompletionHandler completionHandler, NSString *function, ...);
extern BOOL JQWebViewSchemeInBlackList(NSString *scheme);
extern BOOL JQWebViewIsWebScheme(NSString *scheme);

//
//  JQWKWebView.m
//  hiloo
//
//  Created by zhang jinquan on 9/10/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import "JQWKWebView.h"

@implementation JQWKWebView {
}

- (UIScrollView *)jq_scrollView {
    return self.scrollView;
}

- (void)jq_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    [self evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (id)jq_loadRequest:(NSURLRequest *)request {
    return [self loadRequest:request];
}

- (id)jq_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    return [self loadHTMLString:string baseURL:baseURL];
}

- (id)jq_reload {
    return [self reload];
}

- (void)jq_stopLoading {
    [self stopLoading];
}

- (BOOL)jq_canGoBack {
    return [self canGoBack];
}

- (id)jq_goBack {
    return [self goBack];
}

- (NSURL *)jq_URL {
    return self.URL;
}

- (void)jq_setScaleToFit:(BOOL)scaleToFit {
    if (scaleToFit) {
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [self.configuration.userContentController addUserScript:wkUScript];
    }
}

- (BOOL)jq_scaleToFit {
    return NO;
}

@end

//
//  JQUIWebView.m
//  hiloo
//
//  Created by zhang jinquan on 9/10/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import "JQUIWebView.h"

@implementation JQUIWebView

- (UIScrollView *)jq_scrollView {
    return self.scrollView;
}

- (void)jq_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    NSString *result = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
    if (completionHandler) {
        completionHandler(result, nil);
    }
}

- (id)jq_loadRequest:(NSURLRequest *)request {
    [self loadRequest:request];
    return nil;
}

- (id)jq_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    [self loadHTMLString:string baseURL:baseURL];
    return nil;
}

- (id)jq_reload {
    [self reload];
    return nil;
}

- (void)jq_stopLoading {
    [self stopLoading];
}

- (BOOL)jq_canGoBack {
    return [self canGoBack];
}

- (id)jq_goBack {
    [self goBack];
    return nil;
}

- (NSURL *)jq_URL {
    return self.request.URL;
}

- (void)jq_setScaleToFit:(BOOL)scaleToFit {
    self.scalesPageToFit = scaleToFit;
}

- (BOOL)jq_scaleToFit {
    return self.scalesPageToFit;
}

@end

//
//  JQUIWebViewController.m
//  hiloo
//
//  Created by zhang jinquan on 9/10/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import "JQUIWebViewController.h"
#import "JQUIWebView.h"
#import "JQHTTPSRequestAuthHelper.h"

@interface JQUIWebViewController ()
{
    JQUIWebView *_webView;
}

@end

@implementation JQUIWebViewController

- (void)dealloc {
    _webView.delegate = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _webView = [[JQUIWebView alloc] init];
        _webView.delegate = self;
    }
    return self;
}

#pragma mark - JQWebViewControllerProtocol

- (UIView <JQWebViewProtocol>*)webView {
    return _webView;
}

- (void)loadRequest:(NSURLRequest *)request {
    [_webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    [_webView loadHTMLString:string baseURL:baseURL];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if ([self isAppStoreURLString:[url absoluteString]]) {
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    if ([JQHTTPSRequestAuthHelper sharedInstance].enable && [[url scheme] compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        if (![[JQHTTPSRequestAuthHelper sharedInstance] httpsAuthenticatedWithRequest:request]) {
            
            [[JQHTTPSRequestAuthHelper sharedInstance] authenticateWithRequest:request sender:self complete:^(BOOL success) {
                if (success) {
                    [webView loadRequest:request];
//                    RCTrace(@"");
                }
                else {
//                    RCTrace(@"");
                }
            }];
            return NO;
        }
        return YES;
    }
    id<JQURLRequestHandler> handler = [self handlerForScheme:[url scheme]];
    if (handler) {
        [handler handleURLRequest:request];
        return NO;
    }
    BOOL allow = YES;
    if ([self.delegate respondsToSelector:@selector(webViewController:shouldLoadWithRequest:navigationType:)]) {
        allow = [self.delegate webViewController:self shouldLoadWithRequest:request navigationType:[self navigationTypeOf:navigationType]];
    }
    allow = allow && !JQWebViewSchemeInBlackList([url scheme]);
    if (allow && !JQWebViewIsWebScheme([url scheme])) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        allow = NO;
    }
    return allow;
}

- (JQWebViewNavigationType)navigationTypeOf:(UIWebViewNavigationType)type {
    switch (type) {
        case UIWebViewNavigationTypeLinkClicked:
            return JQWebViewNavigationType_LinkActivated;
            
        case UIWebViewNavigationTypeFormSubmitted:
            return JQWebViewNavigationType_FormSubmitted;
            
        case UIWebViewNavigationTypeBackForward:
            return JQWebViewNavigationType_BackForward;
            
        case UIWebViewNavigationTypeReload:
            return JQWebViewNavigationType_Reload;
            
        case UIWebViewNavigationTypeFormResubmitted:
            return JQWebViewNavigationType_FormResubmitted;
            
        default:
            break;
    }
    return JQWebViewNavigationType_Other;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self.delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)]) {
        [self.delegate webViewControllerDidFinishLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(webViewController:didFailLoadWithError:)]) {
        [self.delegate webViewController:self didFailLoadWithError:error];
    }
}

@end

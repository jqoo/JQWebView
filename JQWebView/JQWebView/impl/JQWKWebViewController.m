//
//  JQWKWebViewController.m
//  hiloo
//
//  Created by zhang jinquan on 9/10/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import "JQWKWebViewController.h"

#import "JQWKWebView.h"
//#import "JQHTTPSRequestAuthHelper.h"
//#import "TinyAlertView.h"

@interface JQWKWebViewController ()
<
    WKUIDelegate
>
{
    JQWKWebView *_webView;
}

@end

@implementation JQWKWebViewController

- (void)dealloc {
    _webView.navigationDelegate = nil;
    _webView = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _webView = [[JQWKWebView alloc] init];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
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

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (decisionHandler) {
        NSURL *url = [navigationAction.request URL];
        if ([self isAppStoreURLString:[url absoluteString]]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        id<JQURLRequestHandler> handler = [self handlerForScheme:[url scheme]];
        if (handler) {
            [handler handleURLRequest:navigationAction.request];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        else {
            if ([self.delegate respondsToSelector:@selector(webViewController:shouldLoadWithRequest:navigationType:)]
                && ![self.delegate webViewController:self shouldLoadWithRequest:navigationAction.request navigationType:[self navigationTypeOf:navigationAction.navigationType]]) {
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            else {
                if (JQWebViewSchemeInBlackList([url scheme])) {
                    decisionHandler(WKNavigationActionPolicyCancel);
                }
                else if (!JQWebViewIsWebScheme([url scheme])) {
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                    decisionHandler(WKNavigationActionPolicyCancel);
                }
                else if ([navigationAction.sourceFrame isMainFrame] && ![navigationAction.targetFrame isMainFrame]) {
                    if ([self.delegate respondsToSelector:@selector(webViewController:loadInNewWebViewWithRequest:)]) {
                        [self.delegate webViewController:self loadInNewWebViewWithRequest:navigationAction.request];
                    }
                    decisionHandler(WKNavigationActionPolicyCancel);
                }
                else {
                    decisionHandler(WKNavigationActionPolicyAllow);
                }
            }
        }
    }
}

- (JQWebViewNavigationType)navigationTypeOf:(WKNavigationType)type {
    switch (type) {
        case WKNavigationTypeLinkActivated:
            return JQWebViewNavigationType_LinkActivated;
            
        case WKNavigationTypeFormSubmitted:
            return JQWebViewNavigationType_FormSubmitted;
            
        case WKNavigationTypeBackForward:
            return JQWebViewNavigationType_BackForward;
            
        case WKNavigationTypeReload:
            return JQWebViewNavigationType_Reload;
            
        case WKNavigationTypeFormResubmitted:
            return JQWebViewNavigationType_FormResubmitted;
            
        default:
            break;
    }
    return JQWebViewNavigationType_Other;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([self.delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)]) {
        [self.delegate webViewControllerDidFinishLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(webViewController:didFailLoadWithError:)]) {
        [self.delegate webViewController:self didFailLoadWithError:error];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    if (completionHandler) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    }
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completionHandler) {
            completionHandler();
        }
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end

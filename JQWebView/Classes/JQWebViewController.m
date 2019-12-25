//
//  JQWebViewController.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 9/11/15.
//  Copyright (c) 2015 jqoo. All rights reserved.
//

#import "JQWebViewController.h"

#import "JQUIWebViewController.h"
#import "JQWKWebViewController.h"

@interface JQWebViewController ()
{
    NSMutableDictionary *_handlerDict;
}

@end

@implementation JQWebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        NSAssert(![self isMemberOfClass:[JQWebViewController class]], @"JQWebViewController is abstract class");
        
        _handlerDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (UIView <JQWebViewProtocol>*)webView {
    return nil;
}

- (void)loadRequest:(NSURLRequest *)request {
    
}

- (void)registerScheme:(NSString *)scheme handler:(id<JQURLRequestHandler>)handler {
    if (scheme && handler) {
        if ([handler conformsToProtocol:@protocol(JQWebViewURLRequestHandler)]) {
            [(id<JQWebViewURLRequestHandler>)handler setWebView:self.webView];
        }
        [_handlerDict setObject:handler forKey:scheme];
    }
}

- (void)unregisterScheme:(NSString *)scheme {
    if (scheme) {
        [_handlerDict removeObjectForKey:scheme];
    }
}

- (id<JQURLRequestHandler>)handlerForScheme:(NSString *)scheme {
    if (scheme == nil) {
        return nil;
    }
    __block id<JQURLRequestHandler> resultHandler = nil;
    [_handlerDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<JQURLRequestHandler> handler, BOOL *stop) {
        NSRange r = [scheme rangeOfString:key options:NSRegularExpressionSearch];
        if (r.location == 0 && r.length == [scheme length]) {
            resultHandler = handler;
            *stop = YES;
        }
    }];
    return resultHandler;
}

static NSRegularExpression *appstore_url_regex() {
    static NSRegularExpression *regex;
    if (regex == nil) {
        NSString *pattern = @"^https?://itunes.apple.com(/.*?)?/app(/.*?)?/id\\d+";
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines error:NULL];
    }
    return regex;
}

- (BOOL)isAppStoreURLString:(NSString *)urlString {
    NSRange r = [appstore_url_regex() rangeOfFirstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    return r.location != NSNotFound;
}

+ (instancetype)webViewController {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        return [[JQWKWebViewController alloc] init];
    }
    return [[JQUIWebViewController alloc] init];
}

@end

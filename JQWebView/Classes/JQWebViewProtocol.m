//
//  JQWebViewProtocol.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 12/25/15.
//  Copyright © 2015 jqoo. All rights reserved.
//

#import "JQWebViewProtocol.h"

static NSString *JQWebViewEncodeForChar(unichar aChar) {
    switch (aChar) {
        case '\\':   return @"\\\\";
        case '\"':   return @"\\\"";
        case '\'':   return @"\\\'";
        case '\n':   return @"\\n";
        case '\r':   return @"\\r";
        case '\f':   return @"\\f";
        case 0x2028: return @"\\u2028";
        case 0x2029: return @"\\u2029";
        default:
            break;
    }
    return nil;
}

NSString *JQWebViewEncodeJSString(NSString *jsString) {
    NSMutableString *text = nil;
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"\\\"\'\n\r\f\u2028\u2029"];
    NSRange remainRange = NSMakeRange(0, [jsString length]);
    NSRange r = [jsString rangeOfCharacterFromSet:charSet options:0 range:remainRange];
    if (r.location != NSNotFound) {
        text = [NSMutableString stringWithCapacity:[jsString length]];
        do {
            [text appendString:[jsString substringWithRange:NSMakeRange(remainRange.location, r.location - remainRange.location)]];
            
            NSString *encodedString = JQWebViewEncodeForChar([jsString characterAtIndex:r.location]);
            if (encodedString) {
                [text appendString:encodedString];
            }
            remainRange.location = r.location + r.length;
            remainRange.length = [jsString length] - remainRange.location;
            if (remainRange.length == 0) {
                break;
            }
            
            r = [jsString rangeOfCharacterFromSet:charSet options:0 range:remainRange];
        } while (r.location != NSNotFound);
        if (remainRange.length > 0) {
            [text appendString:[jsString substringWithRange:remainRange]];
        }
    }
    return text ? text : jsString;
}

void JQWebViewCallJSFunction(UIView<JQWebViewProtocol> *webView, JQWebViewJSFunctionCompletionHandler completionHandler, NSString *function, ...) {
    if (webView == nil || function == nil) {
        return;
    }
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    va_list args;
    va_start(args, function);
    NSString *arg = function;
    
    while (arg) {
        arg = va_arg(args, id);
        if (![arg isKindOfClass:[NSString class]]) {
            arg = nil;
        }
        if (arg) {
            arg = [NSString stringWithFormat:@"'%@'", JQWebViewEncodeJSString(arg)];
            [mArr addObject:arg];
        }
    }
    va_end(args);
    NSString *jsCode = [NSString stringWithFormat:@"%@(%@)", function, [mArr componentsJoinedByString:@","]];
    [webView jq_evaluateJavaScript:jsCode completionHandler:completionHandler];
}

BOOL JQWebViewSchemeInBlackList(NSString *scheme) {
    return [[scheme lowercaseString] isEqualToString:@"about"];
}

extern BOOL JQWebViewIsWebScheme(NSString *scheme) {
    scheme = [scheme lowercaseString];
    return [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"file"];
}

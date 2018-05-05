//
//  JQHTTPSRequestAuthHelper.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 9/24/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JQHTTPSRequestAuthHelper : NSObject

@property (nonatomic, assign) BOOL enable;

+ (instancetype)sharedInstance;

- (BOOL)httpsAuthenticatedWithRequest:(NSURLRequest *)request;

- (void)authenticateWithRequest:(NSURLRequest *)request sender:(id)sender complete:(void (^)(BOOL success))complete;

- (void)cancelAuthenticateWithSender:(id)sender;

@end

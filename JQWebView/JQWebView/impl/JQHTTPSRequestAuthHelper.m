//
//  JQHTTPSRequestAuthHelper.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 9/24/14.
//  Copyright (c) 2014 jqoo. All rights reserved.
//

#import "JQHTTPSRequestAuthHelper.h"

@interface AuthWrapper : NSObject

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) id sender;
@property (nonatomic, copy) void (^complete)(BOOL success);

- (void)complete:(BOOL)success;

@end

@implementation AuthWrapper

- (void)complete:(BOOL)success
{
    if (_complete) {
        _complete(success);
    }
}

- (void)dealloc
{
    self.request = nil;
    self.connection = nil;
    self.complete = nil;
}

@end

@implementation JQHTTPSRequestAuthHelper
{
    NSMutableSet *_authedServerSet;
    NSMutableArray *_authWrapperArray;
}

+ (instancetype)sharedInstance
{
    static JQHTTPSRequestAuthHelper *instance = nil;
    if (instance == nil) {
        instance = [[JQHTTPSRequestAuthHelper alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _authedServerSet = [[NSMutableSet alloc] init];
        _authWrapperArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)serverForURL:(NSURL *)url
{
    NSString *server = [url host];
    NSNumber *port = [url port];
    if (port) {
        server = [server stringByAppendingFormat:@"%d", [port intValue]];
    }
    return server;
}

- (BOOL)httpsAuthenticatedWithRequest:(NSURLRequest *)request
{
    NSURL *url = request.URL;
    if (!([url.scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
        return NO;
    }
    NSString *server = [self serverForURL:url];
    if (server) {
        return [_authedServerSet containsObject:server];
    }
    return NO;
}

- (void)authenticateWithRequest:(NSURLRequest *)request sender:(id)sender complete:(void (^)(BOOL success))complete
{
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    AuthWrapper *aw = [[AuthWrapper alloc] init];
    aw.request = request;
    aw.sender = sender;
    aw.connection = connection;
    aw.complete = complete;
    [_authWrapperArray addObject:aw];
    
    [connection start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self completeWithConnection:connection success:NO];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    [self completeWithConnection:connection success:YES];
    [connection cancel];
}

- (void)completeWithConnection:(NSURLConnection *)connection success:(BOOL)success
{
//    RCTrace(@"request : %@, success : %d", connection.originalRequest, success);
    
    __block AuthWrapper *aw = nil;
    __block int index;
    [_authWrapperArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(AuthWrapper *obj, NSUInteger idx, BOOL *stop) {
        if (obj.connection == connection) {
            aw = obj;
            index = idx;
            *stop = YES;
        }
    }];
    if (aw) {
        BOOL authed = NO;
        if (success) {
            NSString *server = [self serverForURL:aw.request.URL];
            if (server) {
                authed = YES;
                [_authedServerSet addObject:server];
                [aw complete:YES];
            }
        }
        if (!authed) {
            [aw complete:NO];
        }
        [_authWrapperArray removeObjectAtIndex:index];
    }
}

- (void)cancelAuthenticateWithSender:(id)sender
{
    [_authWrapperArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(AuthWrapper *obj, NSUInteger idx, BOOL *stop) {
        if (obj.sender == sender) {
            [_authWrapperArray removeObjectAtIndex:idx];
            [obj.connection cancel];
        }
    }];
}

@end

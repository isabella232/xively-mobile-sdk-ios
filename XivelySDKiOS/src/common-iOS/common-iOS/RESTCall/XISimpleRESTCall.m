//
//  XISimpleRESTCall.m
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XISimpleRESTCall.h"
#import "XIRESTCall.h"
#import "XIRESTCallDelegate.h"
#import "XIRESTCallResponseRecognizer.h"

/**
 * @brief XIRESTCallInternal private interface.
 * @since Version 1.0
 */

@interface XISimpleRESTCall ()
/**
 * @brief The current state of the call.
 * @since Version 1.0
 */
@property(nonatomic, assign)XIRESTCallState state;

/**
 * @brief The result of the call if the call finished with success.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSData *result;

/**
 * @brief The error of the call if the call finished with error.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSError *error;

/**
 * @brief The url session to use to call HTTP requests.
 * @since Version 1.0
 */
@property(nonatomic, weak)NSURLSession *urlSession;

/**
 * @brief The currently running URL call task.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSURLSessionDataTask *task;

/**
 * @brief The provider of the default HTTP headers.
 * @since Version 1.0
 */
@property(nonatomic, strong)XIRESTDefaultHeadersProvider *defaultHeadersProvider;

/**
 * @brief Instances if \link XIRESTCallResponseRecognizer \endlink.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSArray *responseRecognizers;

/**
 * @brief Helper function for creating a REST call method string.
 * @param method The enum that converts to string.
 * @return The string equvalent for the method.
 * @since Version 1.0
 */
- (NSString *)methodStringForRESTCallMethod:(XIRESTCallMethod)method;

/**
 * @brief Creates an HTTP request from components.
 * @param urlString The string frmat of the url.
 * @param method The HTTP method to send the message.
 * @param headers The HTTP header dictionary to send.
 * @param body The body of the request.
 * @return The URL request object.
 * @since Version 1.0
 */
- (NSURLRequest *)requestWithURL:(NSString *)urlString method:(XIRESTCallMethod)method headers:(NSDictionary *)headers body:(NSData *)body;

@end

@implementation XISimpleRESTCall

@synthesize delegate = _delegate;
@synthesize state = _state;
@synthesize result = _result;
@synthesize error = _error;
@synthesize task = _task;


+ (instancetype)restCallInternalWithURLSession:(NSURLSession *)urlSession
                        defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)defaultHeadersProvider
                           responseRecognizers:(NSArray *)responseRecognizers {
    return [[[self class] alloc] initWithURLSession:urlSession defaultHeadersProvider:defaultHeadersProvider responseRecognizers:responseRecognizers];
}

- (instancetype)initWithURLSession:(NSURLSession *)urlSession
            defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)defaultHeadersProvider
               responseRecognizers:(NSArray *)responseRecognizers {
    self = [super init];
    if (self) {
        assert(urlSession);
        _urlSession = urlSession;
        self.defaultHeadersProvider = defaultHeadersProvider;
        self.responseRecognizers = responseRecognizers;
    }
    return self;
}

- (void)startWithURL:(NSString *)urlString method:(XIRESTCallMethod)method headers:(NSDictionary *)headers body:(NSData *)body {
    assert(urlString);
    assert(XIRESTCallMethodUndefined != method);
    
    if (_state != XIRESTCallStateIdle) return;
    
    NSURLRequest *request = [self requestWithURL:urlString method:method headers:(NSDictionary *)headers body:(NSData *)body];
    
    __weak __block XISimpleRESTCall *blockSelf = self;
    
    self.state = XIRESTCallStateRunning;
    
    self.task = [_urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^ { @autoreleasepool {
            self.task = nil;
            if (_state == XIRESTCallStateRunning) {
                //po [[NSString alloc] initWithData:data encoding:4] -- run in console to see the result body as a string
                if (error) {
                    blockSelf.error = error;
                    blockSelf.result = nil;
                    blockSelf.state = XIRESTCallStateFinishedWithError;
                    [blockSelf.delegate XIRESTCall:blockSelf didFinishWithError:blockSelf.error];
                } else {
                    NSInteger httpStatusCode = 200;
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)response;
                        httpStatusCode = httpUrlResponse.statusCode;
                    }
                    blockSelf.error = nil;
                    blockSelf.result = data;
                    blockSelf.state = XIRESTCallStateFinishedWithSuccess;
                    [blockSelf.delegate XIRESTCall:blockSelf didFinishWithData:blockSelf.result httpStatusCode:httpStatusCode];
                }
                //handle recognizers
                for (id<XIRESTCallResponseRecognizer> recognizer in self.responseRecognizers) {
                    [recognizer handleUrlResponse:response];
                }
            }
        }});
    }];
    [self.task resume];
}

- (void)cancel {
    if (_state == XIRESTCallStateRunning) {
        self.state = XIRESTCallStateCanceled;
        [self.task cancel];
        self.task = nil;
    }
}

- (NSURLRequest *)requestWithURL:(NSString *)urlString method:(XIRESTCallMethod)method headers:(NSDictionary *)headers body:(NSData *)body {
    NSURL *url = [NSURL URLWithString:urlString];
    assert(url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = [self methodStringForRESTCallMethod:method];
    
    //remove user overriden headers from defaults, it appends otherwise
    NSMutableDictionary *defaultHeaders = [NSMutableDictionary dictionaryWithDictionary:self.defaultHeadersProvider.defaultHeaders];
    for (NSString *key in [headers allKeys]) {
        [request addValue:headers[key] forHTTPHeaderField:key];
        [defaultHeaders removeObjectForKey:key];
    }
    
    for (NSString *key in [defaultHeaders allKeys]) {
        [request addValue:defaultHeaders[key] forHTTPHeaderField:key];
    }
    
    
    request.HTTPBody = body;
    return request;
}

- (NSString *)methodStringForRESTCallMethod:(XIRESTCallMethod)method {
    switch (method) {
        case XIRESTCallMethodPOST:
            return @"POST";
            
        case XIRESTCallMethodGET:
            return @"GET";
            
        case XIRESTCallMethodPUT:
            return @"PUT";
            
        case XIRESTCallMethodDELETE:
            return @"DELETE";
            
        default:
            assert(0);
    }
}

- (void)dealloc {
    [self cancel];
}

@end

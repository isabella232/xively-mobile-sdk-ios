//
//  XICOAuthenticationRestCall.m
//  common-iOS
//
//  Created by vfabian on 30/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XICOAuthenticationRestCall.h"
#import <XivelySDK/XIAuthenticationError.h>
#import <XivelySDK/XICommonError.h>

@interface XICOAuthenticationRestCall ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end


@implementation XICOAuthenticationRestCall

@synthesize delegate = _delegate;

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig {
    self = [super init];
    if (self) {
        self.log = logger;
        self.restCallProvider = provider;
        self.servicesConfig = servicesConfig;
    }
    return self;
}

- (void)requestLoginWithEmailAddress:(NSString *)emailAddress password:(NSString *)password accountId:(NSString *)accountId {
    [_log debug:@"Authentication Call Requested"];
    assert(emailAddress);
    assert(password);
    assert(accountId);
    NSData *restCallBody = [self restCallBodyWithEmailAddress:emailAddress password:password accountId:accountId];
    NSString *restCallUrl = [self restCallUrl];
    NSDictionary *restCallHeaders = [self restCallHeaders];
    
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodPOST
                    headers: restCallHeaders
                       body: restCallBody];
}

- (void)cancel {
    [_log debug:@"Authentication Call Canceled"];
    [self.call cancel];
}
- (NSDictionary *)restCallHeaders {
    return nil;
}

- (NSString *)restCallUrl {
    return self.servicesConfig.loginServiceUrl;
}

- (NSData *)restCallBodyWithEmailAddress:(NSString *)emailAddress password:(NSString *)password accountId:(NSString *)accountId{
    NSError *parseError = nil;
    NSDictionary *restCallBodyDict = [self restCallBodyDictWithEmailAddress:emailAddress password:password accountId:accountId];
    NSData* json = [NSJSONSerialization dataWithJSONObject: restCallBodyDict options: 0 error: &parseError];
    assert(!parseError);
    return json;
}

- (NSDictionary *)restCallBodyDictWithEmailAddress:(NSString *)emailAddress password:(NSString *)password accountId:(NSString *)accountId {
    return @{@"emailAddress" : emailAddress,
             @"password" : password,
             @"accountId" : accountId};
}

#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode {
    [_log debug:@"Authentication Call Returned"];
    [self processRestCallResultWithHttpStatusCode:httpStatusCode data:data];
}

- (void)processRestCallResultWithHttpStatusCode:(NSInteger)httpStatusCode data:(NSData *)data {
    if (httpStatusCode == 200) {
        [self processPositiveData:data];
    } else {
        [self processErrorStatus:httpStatusCode];
    }
}

- (void)processPositiveData:(NSData *)data {
    [_log debug: @"Authentication Call Success"];
    
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError] : nil;
    if (parseError || !parsedDictionary || ![parsedDictionary isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:@"Authentication" code:XIErrorInternal userInfo:nil];
        [self.delegate authenticationCall:self didFailWithError:error];
    } else {
        NSString *jwt = parsedDictionary[@"jwt"];
        [self.delegate authenticationCall:self didReceiveJwt:jwt];
    }
}

- (void)processErrorStatus:(NSInteger)httpStatusCode {
    [_log debug: @"Authentication Call Failed with code %d", httpStatusCode];
    NSInteger errorCode = XIErrorUnknown;
    switch (httpStatusCode) {
        case 401:
            errorCode = XIAuthenticationErrorInvalidCredentials;
            break;
            
        default:
            errorCode = XIErrorInternal;
            break;
    }
    NSError *error = [NSError errorWithDomain:@"Authentication" code:errorCode userInfo:nil];
    [self.delegate authenticationCall:self didFailWithError:error];
}


- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    [_log info: @"Authentication Call Error"];
    [self.delegate authenticationCall:self didFailWithError:error];
}

@end

//
//  XICOResolveUserRestCall.m
//  common-iOS
//
//  Created by vfabian on 21/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import "XICOResolveUserRestCall.h"
#import <XivelySDK/XIAuthenticationError.h>
#import <XivelySDK/XICommonError.h>
#import "NSString+XIURLEncode.h"

@interface XICOResolveUserRestCall ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end


@implementation XICOResolveUserRestCall

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

- (void)requestUserWithAccountId:(NSString *)accountId idmUserId:(NSString *)idmUserId {
    assert(accountId);
    assert(idmUserId);
    [_log debug:@"Resolve User Call Requested"];
    NSData *restCallBody = [self restCallBodyWithAccountId:accountId idmUserId:idmUserId];
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
    [_log debug:@"Resolve User Call Canceled"];
    [self.call cancel];
}
- (NSDictionary *)restCallHeaders {
    return nil;
}

- (NSString *)restCallUrl {
    return self.servicesConfig.blueprintBatchServiceUrl;
}

- (NSData *)restCallBodyWithAccountId:(NSString *)accountId idmUserId:(NSString *)idmUserId {
    
    NSDictionary *endUserQuery = @{@"method" : @"get",
                                   @"path" : [self endUserQueryUrlWithAccountId:accountId idmUserId:idmUserId]};
    
    NSDictionary *accountUserQuery = @{@"method" : @"get",
                                    @"path" : [self accountUserQueryUrlWithAccountId:accountId idmUserId:idmUserId]};
    
    NSDictionary *rootDictionary = @{@"requests" : @[endUserQuery, accountUserQuery]};
    
    NSError *parseError = nil;
    NSData* json = [NSJSONSerialization dataWithJSONObject:rootDictionary options:0 error:&parseError];
    assert(!parseError);
    return json;
}

- (NSString *)endUserQueryUrlWithAccountId:(NSString *)accountId idmUserId:(NSString *)idmUserId {
    return [self userQueryUrlWithAccountId:accountId idmUserId:idmUserId url:self.servicesConfig.blueprintEndUsersServiceUrl];
}

- (NSString *)accountUserQueryUrlWithAccountId:(NSString *)accountId idmUserId:(NSString *)idmUserId {
    return [self userQueryUrlWithAccountId:accountId idmUserId:idmUserId url:self.servicesConfig.blueprintAccountUsersServiceUrl];
}

- (NSString *)userQueryUrlWithAccountId:(NSString *)accountId idmUserId:(NSString *)idmUserId url:(NSString *)url {
#pragma warning Remove if the minimum OS is set to iOS 8
    if (NSClassFromString(@"NSURLQueryItem")) {
        NSURLComponents *components = [NSURLComponents componentsWithString:url];
        NSURLQueryItem *accountIdQI = [NSURLQueryItem queryItemWithName:@"accountId" value:accountId];
        NSURLQueryItem *accessUserIdQI = [NSURLQueryItem queryItemWithName:@"userId" value:idmUserId];
        
        components.queryItems = @[ accountIdQI, accessUserIdQI];
        NSURL *url = components.URL;
        return [url absoluteString];
    } else {
        return [NSString stringWithFormat:@"%@?accountId=%@&userId=%@",
                url,
                [accountId xiUrlEncode],
                [idmUserId xiUrlEncode]];
    }
}

#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode {
    [_log debug:@"Resolve User Call Returned"];
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
    [_log debug: @"Resolve User Call Success"];
    
    NSError *parseError = nil;
    NSArray *parsedResponses = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError] : nil;
    if (parseError || !parsedResponses || ![parsedResponses isKindOfClass:[NSArray class]]) {
        NSError *error = [NSError errorWithDomain:@"Authentication" code:XIErrorInternal userInfo:nil];
        [self.delegate resolveUserCall:self didFailWithError:error];
        
    } else {
        XICOBlueprintUserType userType = XICOBlueprintUserTypeUndefined;
        NSDictionary *fields = nil;
        [self getUserType:&userType
                   fields:&fields
                fromArray:parsedResponses];
        
        if (userType == XICOBlueprintUserTypeUndefined) {
            NSError *error = [NSError errorWithDomain:@"Authentication" code:XIErrorInternal userInfo:nil];
            [self.delegate resolveUserCall:self didFailWithError:error];
        } else {
            XICOBlueprintUser *user = [[XICOBlueprintUser alloc] initWithUserType:userType Dictionary:fields];
            [self.delegate resolveUserCall:self didReceiveUser:user];
        }
    }
}

- (void)getUserType:(XICOBlueprintUserType *)userType fields:(NSDictionary * __autoreleasing *)fields fromArray:(NSArray *)array {
    for (NSDictionary *dict in array) {
        if (dict[@"accountUsers"]) {
            NSDictionary *accountUsers = (NSDictionary *)dict[@"accountUsers"];
            NSArray *results = accountUsers[@"results"];
            if (results.count > 0) {
                if (results.count > 1) {
                    [_log debug: @"Resolve User Call - More than one account user found"];
                }
                *userType = XICOBlueprintUserTypeAccountUser;
                *fields = (NSDictionary *)results[0];
                return;
            }
            
        } else if (dict[@"endUsers"]) {
            NSDictionary *endUsers = (NSDictionary *)dict[@"endUsers"];
            NSArray *results = endUsers[@"results"];
            if (results.count > 0) {
                if (results.count > 1) {
                    [_log debug: @"Resolve User Call - More than one account user found"];
                }
                *userType = XICOBlueprintUserTypeEndUser;
                *fields = (NSDictionary *)results[0];
                return;
            }
        }
    }
}

- (void)processErrorStatus:(NSInteger)httpStatusCode {
    [_log debug: @"Resolve User Call Call Failed with code %d", httpStatusCode];
    NSInteger errorCode = httpStatusCode == 401 ? XIErrorUnauthorized : XIErrorInternal;
    NSError *error = [NSError errorWithDomain:@"Authentication" code:errorCode userInfo:nil];
    [self.delegate resolveUserCall:self didFailWithError:error];
}


- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    [_log info: @"Resolve User Call Error"];
    [self.delegate resolveUserCall:self didFailWithError:error];
}


@end

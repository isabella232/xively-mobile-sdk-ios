//
//  XIOrganizationInfoRestCall.m
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import "XIEndUserInfoRestCall.h"
#import <XivelySDK/XIEnvironment.h>
#import <XivelySDK/XISdkConfig+Selector.h>
#import "XIEndUserInfoMeta.h"
#import "XIEndUserInfo.h"
#import "XIEndUserInfo+InitWithDictionary.h"
#import <XivelySDK/XICommonError.h>
#import "NSString+XIURLEncode.h"

@interface XIEndUserInfoRestCall ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end

@implementation XIEndUserInfoRestCall

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

- (void)getRequestWithEndUserId:(NSString *)endUserId {
    [_log info: @"Organization Get Call Requested"];
    NSData *restCallBody = [self restCallBodyWithEndUser:nil];
    NSString *restCallUrl = [self restCallUrlWithEndUserId:(NSString *)endUserId];
    NSDictionary *restCallHeaders = [self restCallHeadersWithEndUser:nil];
    
    [self.call cancel];
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodGET
                    headers: restCallHeaders
                       body: restCallBody];

}

- (void)putRequestWithEndUser:(XIEndUserInfo *)endUser {
    [_log info: @"Organization Get Call Requested"];
    NSData *restCallBody = [self restCallBodyWithEndUser:endUser];
    NSString *restCallUrl = [self restCallUrlWithEndUserId:endUser.endUserId];
    NSDictionary *restCallHeaders = [self restCallHeadersWithEndUser:endUser];
    
    [self.call cancel];
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodPUT
                    headers: restCallHeaders
                       body: restCallBody];
}

- (NSDictionary *)restCallHeadersWithEndUser:(XIEndUserInfo* )endUserInfo {
    if (!endUserInfo) {
        return nil;
    }
    return @{@"etag": endUserInfo.version};
}

- (NSString *)restCallUrlWithEndUserId:(NSString *)endUserId {
    //iOS 8 check
#pragma warning Remove if the minimum OS is set to iOS 8
    if (NSClassFromString(@"NSURLQueryItem")) {
        NSURLComponents *components = [NSURLComponents componentsWithString:self.servicesConfig.blueprintEndUsersServiceUrl];
            components.path = [NSString stringWithFormat:@"%@/%@", components.path, [endUserId xiUrlEncode]];
        NSURL *url = components.URL;
        return [url absoluteString];
    } else {
        return [NSString stringWithFormat:@"%@/%@",
                self.servicesConfig.blueprintOrganizationsServiceUrl,
                [endUserId xiUrlEncode]];
    }
}

- (NSData *)restCallBodyWithEndUser:(XIEndUserInfo* )endUserInfo {
    if (!endUserInfo)
        return nil;
    NSError* err = nil;
    return [NSJSONSerialization dataWithJSONObject:[endUserInfo dictionary] options:0 error:&err];
}

- (void)cancel {
    [_log info: @"Device Info List Call Canceled"];
    [self.call cancel];
}

#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode {
    [_log info: @"Device Info List Call Returned"];
    [self processRestCallResultWithHttpStatusCode:httpStatusCode data:data];
}

- (void)processRestCallResultWithHttpStatusCode:(NSInteger)httpStatusCode data:(NSData *)data {
    if (httpStatusCode == 200) {
        [self processPositiveData:data];
    } else {
        NSLog(@"Error message: %@", [NSString stringWithUTF8String:[data bytes]]);
        [self processErrorStatus:httpStatusCode];
    }
}

- (void)processPositiveData:(NSData *)data {
    [_log info: @"Device Info List Call Success"];
    
    NSError *parseError = nil;
    NSObject *parsedDictionary = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError] : nil;
    
    if (parseError || !parsedDictionary ) {
        NSError *error = [NSError errorWithDomain:@"Organization Info" code:XIErrorInternal userInfo:nil];
        [self.delegate endUserInfoCall:self didFailWithError:error];
        return;
        
    } else {
        [self processCallResult:parsedDictionary ];
    }
}

- (void)processCallResult:(NSObject *)result {
    NSDictionary *endUserDict = ((NSDictionary*)result)[@"endUser"];
    if (endUserDict) {
        XIEndUserInfo *endUserInfo = [[XIEndUserInfo alloc] initWithDictionary:endUserDict];
        [self.delegate endUserInfoCall:self didSucceedWithEndUserInfo:endUserInfo];
    } else {
        NSError *error = [NSError errorWithDomain:@"Device Info" code:XIErrorInternal userInfo:nil];
        [self.delegate endUserInfoCall:self didFailWithError:error];
    }
}

- (void)processErrorStatus:(NSInteger)httpStatusCode {
    [_log info: @"Device Info List Call Failed with code %d", httpStatusCode];
    NSInteger errorCode = XIErrorUnknown;
    switch (httpStatusCode) {
        case 401:
            errorCode = XIErrorUnauthorized;
            break;
            
        case 400:
            errorCode = XIErrorInternal;
            break;
            
        default:
            break;
    }
    NSError *error = [NSError errorWithDomain:@"Device Info List" code:errorCode userInfo:nil];
    [self.delegate endUserInfoCall:self didFailWithError:error];
}


- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    [_log info: @"Device Info List Call Error"];
    [self.delegate endUserInfoCall:self didFailWithError:error];
}

@end

//
//  XIOrganizationInfoRestCall.m
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import "XIOrganizationInfoRestCall.h"
#import <XivelySDK/XIEnvironment.h>
#import <XivelySDK/XISdkConfig+Selector.h>
#import "XIOrganizationInfoMeta.h"
#import "XIOrganizationInfo.h"
#import "XIOrganizationInfo+InitWithDictionary.h"
#import <XivelySDK/XICommonError.h>
#import "NSString+XIURLEncode.h"

@interface XIOrganizationInfoRestCall ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end

@implementation XIOrganizationInfoRestCall

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

- (void)getListRequestWithAccountId:(NSString *)accountId {
    [_log info: @"Organization List Get Call Requested"];
    NSData *restCallBody = [self restCallBody];
    NSString *restCallUrl = [self restCallUrlWithAccountId:(NSString *)accountId];
    NSDictionary *restCallHeaders = [self restCallHeaders];
    
    [self.call cancel];
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodGET
                    headers: restCallHeaders
                       body: restCallBody];
}

- (void)getRequestWithOrganizationId:(NSString *)organizationId {
    [_log info: @"Organization Get Call Requested"];
    NSData *restCallBody = [self restCallBody];
    NSString *restCallUrl = [self restCallUrlWithOrganizationId:(NSString *)organizationId];
    NSDictionary *restCallHeaders = [self restCallHeaders];
    
    [self.call cancel];
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodGET
                    headers: restCallHeaders
                       body: restCallBody];

}

- (NSDictionary *)restCallHeaders {
        return nil;
}

- (NSString *)restCallUrlWithOrganizationId:(NSString *)organizationId {
    //iOS 8 check
#pragma warning Remove if the minimum OS is set to iOS 8
    if (NSClassFromString(@"NSURLQueryItem")) {
        NSURLComponents *components = [NSURLComponents componentsWithString:self.servicesConfig.blueprintOrganizationsServiceUrl];
            components.path = [NSString stringWithFormat:@"%@/%@", components.path, [organizationId xiUrlEncode]];
        NSURL *url = components.URL;
        return [url absoluteString];
    } else {
        return [NSString stringWithFormat:@"%@/%@",
                self.servicesConfig.blueprintOrganizationsServiceUrl,
                [organizationId xiUrlEncode]];
    }
}

- (NSString *)restCallUrlWithAccountId:(NSString *)accountId {
    //iOS 8 check
#pragma warning Remove if the minimum OS is set to iOS 8
    if (NSClassFromString(@"NSURLQueryItem")) {
        NSURLComponents *components = [NSURLComponents componentsWithString:self.servicesConfig.blueprintOrganizationsServiceUrl];
        NSURLQueryItem *accountIdQI = [NSURLQueryItem queryItemWithName:@"accountId" value:accountId];
        components.queryItems = @[ accountIdQI ];
        NSURL *url = components.URL;
        return [url absoluteString];
    } else {
        return [NSString stringWithFormat:@"%@?accountId=%@",
                self.servicesConfig.blueprintOrganizationsServiceUrl,
                [accountId xiUrlEncode]];
    }
}


- (NSData *)restCallBody {
        return nil;
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
        [self.delegate organizationInfoCall:self didFailWithError:error];
        return;
        
    } else {
        [self processCallResult:parsedDictionary ];
    }
}

- (void)processCallResult:(NSObject *)result {
    NSDictionary *organizationDict = ((NSDictionary*)result)[@"organization"];
    NSDictionary *organizationListDict = ((NSDictionary*)result)[@"organizations"];
    if (organizationDict) {
        XIOrganizationInfo *organizationInfo = [[XIOrganizationInfo alloc] initWithDictionary:organizationDict];
        [self.delegate organizationInfoCall:self didSucceedWithOrganizationInfo:organizationInfo];
    } else if (organizationListDict) {
        NSMutableArray* results = [[NSMutableArray alloc] init];
        for (NSDictionary* result in organizationListDict[@"results"]) {
            [results addObject:[[XIOrganizationInfo alloc] initWithDictionary:result]];
        }
        [self.delegate organizationInfoCall:self didSucceedWithOrganizationInfoList:results];
    } else {
        NSError *error = [NSError errorWithDomain:@"Device Info" code:XIErrorInternal userInfo:nil];
        [self.delegate organizationInfoCall:self didFailWithError:error];
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
    [self.delegate organizationInfoCall:self didFailWithError:error];
}


- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    [_log info: @"Device Info List Call Error"];
    [self.delegate organizationInfoCall:self didFailWithError:error];
}

@end

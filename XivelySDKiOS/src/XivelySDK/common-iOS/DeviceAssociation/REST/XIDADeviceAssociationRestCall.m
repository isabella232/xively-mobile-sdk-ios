//
//  XIDADeviceAssociationRestCall.m
//  common-iOS
//
//  Created by vfabian on 17/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIDADeviceAssociationRestCall.h"
#import <Internals/ServicesConfig/XIServicesConfig.h>
#import <XivelySDK/XICommonError.h>
#import <XivelySDK/DeviceAssociation/XIDeviceAssociationError.h>
#import <XivelySDK/XICommonError.h>

@interface XIDADeviceAssociationRestCall ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end

@implementation XIDADeviceAssociationRestCall

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

- (void)requestWithEndUserId:(NSString *)endUserId associationCode:(NSString *)associationCode {
    [_log info: @"Device Association Call Requested"];
    NSData *restCallBody = [self restCallBodyWithEndUserId:endUserId associationCode:associationCode];
    NSString *restCallUrl = [self restCallUrlWithAssociationCode:associationCode];
    NSDictionary *restCallHeaders = [self restCallHeaders];
    
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodPOST
                    headers: restCallHeaders
                       body: restCallBody];
}

- (NSDictionary *)restCallHeaders {
    return nil;
}

- (NSString *)restCallUrlWithAssociationCode:(NSString *)associationCode {
    return self.servicesConfig.deviceAssociationServiceUrl;
}

- (NSData *)restCallBodyWithEndUserId:(NSString *)endUserId associationCode:(NSString *)associationCode{
    NSError *parseError = nil;
    NSDictionary *restCallBodyDict = [self restCallBodyDictWithEndUserId:endUserId associationCode:associationCode];
    NSData* json = [NSJSONSerialization dataWithJSONObject: restCallBodyDict options: 0 error: &parseError];
    assert(!parseError);
    return json;
}

- (NSDictionary *)restCallBodyDictWithEndUserId:(NSString *)endUserId associationCode:(NSString *)associationCode{
    return @{@"endUserId" : endUserId, @"associationCode" : associationCode};
}

- (void)cancel {
    [_log info: @"Device Association Call Canceled"];
    [self.call cancel];
}

#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode {
    [_log info: @"Device Association Call Returned"];
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
    [_log info: @"Device Association Call Success"];
    
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError] : nil;
    
    if (parseError || !parsedDictionary || ![parsedDictionary isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:@"Device Association" code:XIErrorInternal userInfo:nil];
        [self.delegate deviceAssociationCall:self didFailWithError:error];
    } else {
        NSString *deviceId = parsedDictionary[@"deviceId"];
        [self.delegate deviceAssociationCall:self didSucceedWithDeviceId:deviceId];
    }
}

- (void)processErrorStatus:(NSInteger)httpStatusCode {
    [_log info: @"Device Association Call Failed with code %d", httpStatusCode];
    NSInteger errorCode = XIErrorUnknown;
    switch (httpStatusCode) {
        case 400:
        case 404:
            errorCode = XIDeviceAssociationErrorInvalidCode;
            break;
            
        case 401:
            errorCode = XIErrorUnauthorized;
            break;
            
        case 422:
            errorCode = XIDeviceAssociationErrorDeviceNotAssociatable;
            break;
            
        case 500:
        case 503:
            errorCode = XIErrorInternal;
            break;
            
        default:
            break;
    }
    NSError *error = [NSError errorWithDomain:@"Device Association" code:errorCode userInfo:nil];
    [self.delegate deviceAssociationCall:self didFailWithError:error];
}


- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    [_log info: @"Device Association Call Error"];
    [self.delegate deviceAssociationCall:self didFailWithError:error];
}

@end

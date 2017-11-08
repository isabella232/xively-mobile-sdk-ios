//
//  XICOCreateMqttCredentialsRestCall.m
//  common-iOS
//
//  Created by vfabian on 03/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XICOCreateMqttCredentialsRestCall.h"
#import <Internals/ServicesConfig/XIServicesConfig.h>
#import <XivelySDK/XICommonError.h>
#import <XivelySDK/XIEnvironment.h>
#import <XivelySDK/XISdkConfig+Selector.h>


@interface XICOCreateMqttCredentialsRestCall ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end


@implementation XICOCreateMqttCredentialsRestCall

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

- (void)requestWithEndUserId:(NSString *)endUserId accountId:(NSString *)accountId {
    [_log debug: @"Create MQTT Credentials Call Requested for an End User"];
    [self requestWithEntityId:endUserId accountId:accountId entityType:[self entityTypeForEndUser]];
}

- (void)requestWithAccountUserId:(NSString *)accountUserId accountId:(NSString *)accountId {
    [_log debug: @"Create MQTT Credentials Call Requested for an Account User"];
    [self requestWithEntityId:accountUserId accountId:accountId entityType:[self entityTypeForAccountUser]];
}

- (void)requestWithEntityId:(NSString *)entityId accountId:(NSString *)accountId entityType:(NSString *)entityType {
    NSData *restCallBody = [self restCallBodyWithEntityId:entityId accountId:accountId entityType:entityType];
    NSString *restCallUrl = [self restCallUrl];
    NSDictionary *restCallHeaders = [self restCallHeaders];
    
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodPOST
                    headers: restCallHeaders
                       body: restCallBody];
}

- (NSString *)entityTypeForEndUser {
    return @"endUser";
}

- (NSString *)entityTypeForAccountUser {
    return @"accountUser";
}

- (NSDictionary *)restCallHeaders {
    return nil;
}

- (NSString *)restCallUrl {
    return self.servicesConfig.createMqttCredentialsServiceUrl;
}

- (NSData *)restCallBodyWithEntityId:(NSString *)entityId accountId:(NSString *)accountId entityType:(NSString *)entityType{
    NSError *parseError = nil;
    NSDictionary *restCallBodyDict = [self restCallBodyDictWithEntityId:entityId accountId:accountId entityType:entityType];
    NSData* json = [NSJSONSerialization dataWithJSONObject: restCallBodyDict options: 0 error: &parseError];
    assert(!parseError);
    return json;
}

- (NSDictionary *)restCallBodyDictWithEntityId:(NSString *)entityId accountId:(NSString *)accountId entityType:(NSString *)entityType {
    return @{@"entityId" : entityId, @"accountId" : accountId, @"entityType": entityType};
}

- (void)cancel {
    [_log debug: @"Create MQTT Credentials Call Canceled"];
    [self.call cancel];
}

#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode {
    [_log debug: @"Create MQTT Credentials Call Returned"];
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
    [_log debug: @"Create MQTT Credentials Call Success"];
    
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError] : nil;
    if (parseError || !parsedDictionary || ![parsedDictionary isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:@"Create MQTT Credentials" code:XIErrorInternal userInfo:nil];
        [self.delegate createMqttCredentialsCall:self didFailWithError:error];
    } else {
        NSDictionary *credential = parsedDictionary[@"mqttCredential"];
        NSString *username = credential[@"entityId"];
        NSString *secret = credential[@"secret"];
        
        if (username && username.length && secret && secret.length) {
            [_log debug: @"Create MQTT Credentials Call valid username and password received"];
            [self.delegate createMqttCredentialsCall:self didSucceedWithMqttUserName:username mqttPassword:secret];
        } else {
            [_log debug: @"Create MQTT Credentials Call cannot parse username or password"];
            NSError *error = [NSError errorWithDomain:@"Create MQTT Credentials" code:XIErrorInternal userInfo:nil];
            [self.delegate createMqttCredentialsCall:self didFailWithError:error];
        }
    }
}

- (void)processErrorStatus:(NSInteger)httpStatusCode {
    [_log debug: @"Create MQTT Credentials Call Failed with code %d", httpStatusCode];
    NSInteger errorCode = XIErrorUnknown;
    switch (httpStatusCode) {
        case 400:
            errorCode = XIErrorInternal;
            break;
        case 401:
            errorCode = XIErrorUnauthorized;
            break;
            
        default:
            break;
    }
    NSError *error = [NSError errorWithDomain:@"Create MQTT Credentials" code:errorCode userInfo:nil];
    [self.delegate createMqttCredentialsCall:self didFailWithError:error];
}


- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    [_log debug: @"Create MQTT Credentials Call Error"];
    [self.delegate createMqttCredentialsCall:self didFailWithError:error];
}

@end

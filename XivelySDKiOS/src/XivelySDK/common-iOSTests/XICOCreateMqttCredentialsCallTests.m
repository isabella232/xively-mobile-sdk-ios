//
//  XICOCreateMqttCredentialsCallTests.m
//  common-iOS
//
//  Created by vfabian on 03/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XICOCreateMqttCredentialsCall.h"
#import "XICOCreateMqttCredentialsRestCall.h"
#import <XivelySDK/XICommonError.h>
#import <XivelySDK/XIEnvironment.h>
#import <XivelySDK/XISdkConfig+Selector.h>

#import "XICOCreateMqttCredentialsRestCallProvider.h"


@interface XICOCreateMqttCredentialsCallTests : XCTestCase

@property(nonatomic, strong)XICOCreateMqttCredentialsRestCall *call;
@property(nonatomic, strong)OCMockObject *mockRestCallProvider;
@property(nonatomic, strong)OCMockObject *mockServicesConfig;
@property(nonatomic, strong)OCMockObject *mockDelegate;
@property(nonatomic, strong)OCMockObject *mockRestCall;

@property(nonatomic, strong)NSString *accountId;
@property(nonatomic, strong)NSString *endUserId;
@end

@implementation XICOCreateMqttCredentialsCallTests

- (void)setUp {
    [super setUp];
    
    self.accountId = @"sdlkgfsdhkgjflsdhglgkhj";
    self.endUserId = @"dsaljfsdhlkjfdsahjfgdsklghdfslkjgdfhglkfdsjhglk";
    
    self.mockRestCallProvider = [OCMockObject mockForProtocol:@protocol(XIRESTCallProvider)];
    self.mockServicesConfig = [OCMockObject mockForClass:[XIServicesConfig class]];
    self.mockDelegate = [OCMockObject mockForProtocol:@protocol(XICOCreateMqttCredentialsCallDelegate)];
    self.mockRestCall = [OCMockObject mockForProtocol:@protocol(XIRESTCall)];
    
    self.call = [[XICOCreateMqttCredentialsRestCall alloc] initWithLogger:nil
                                              restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                servicesConfig:(XIServicesConfig *)self.mockServicesConfig];
    self.call.delegate = (id<XICOCreateMqttCredentialsCallDelegate>)self.mockDelegate;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXICOCreateMqttCredentialsCallCreation {
    // This is an example of a functional test case.
    XCTAssert(self.call, @"Creation failed");
}

- (void)testXICOCreateMqttCredentialsCallStartRequestForEndUser {
    NSString *createMqttCredentialsServiceUrl = @"https://blueprint.dev.xively.us/api/v1/blahblah";
    [[[self.mockServicesConfig expect] andReturn:createMqttCredentialsServiceUrl] createMqttCredentialsServiceUrl];
    [[[self.mockRestCallProvider expect] andReturn:self.mockRestCall] getEmptyRESTCall];
    [[self.mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];
    
    XISdkConfig *sdkConfig = [XISdkConfig configWithHTTPResponseTimeout:1 urlSession:nil mqttConnectTimeout:1 mqttRetryAttempt:1 mqttWaitOnReconnect:1 environment:XIEnvironmentLive];
    [[[self.mockServicesConfig stub] andReturn:sdkConfig] sdkConfig];
    
    [[self.mockRestCall expect] startWithURL: createMqttCredentialsServiceUrl
                                      method: XIRESTCallMethodPOST
                                     headers: [OCMArg any]
                                        body: [OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:(NSData *)obj options:0 error:&error];
        if (error) return NO;

        
        return [d[@"accountId"] isEqualToString:self.accountId] && [d[@"entityId"] isEqualToString:self.endUserId] && [d[@"entityType"] isEqualToString:@"endUser"];
    }]];
    
    [self.call requestWithEndUserId:self.endUserId accountId:self.accountId];
    
    [self.mockServicesConfig verify];
    [self.mockRestCallProvider verify];
    [self.mockRestCall verify];
}

- (void)testXICOCreateMqttCredentialsCallStartRequestForAccountUser {
    NSString *createMqttCredentialsServiceUrl = @"https://blueprint.dev.xively.us/api/v1/blahblah";
    [[[self.mockServicesConfig expect] andReturn:createMqttCredentialsServiceUrl] createMqttCredentialsServiceUrl];
    [[[self.mockRestCallProvider expect] andReturn:self.mockRestCall] getEmptyRESTCall];
    [[self.mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];
    
    XISdkConfig *sdkConfig = [XISdkConfig configWithHTTPResponseTimeout:1 urlSession:nil mqttConnectTimeout:1 mqttRetryAttempt:1 mqttWaitOnReconnect:1 environment:XIEnvironmentLive];
    [[[self.mockServicesConfig stub] andReturn:sdkConfig] sdkConfig];
    
    [[self.mockRestCall expect] startWithURL: createMqttCredentialsServiceUrl
                                      method: XIRESTCallMethodPOST
                                     headers: [OCMArg any]
                                        body: [OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:(NSData *)obj options:0 error:&error];
        if (error) return NO;
        
        
        return [d[@"accountId"] isEqualToString:self.accountId] && [d[@"entityId"] isEqualToString:self.endUserId] && [d[@"entityType"] isEqualToString:@"accountUser"];
    }]];
    
    [self.call requestWithAccountUserId:self.endUserId accountId:self.accountId];
    
    [self.mockServicesConfig verify];
    [self.mockRestCallProvider verify];
    [self.mockRestCall verify];
}


- (void)testXICOCreateMqttCredentialsCallCancelStartedRequest {
    [self testXICOCreateMqttCredentialsCallStartRequestForEndUser];
    
    [[self.mockRestCall expect] cancel];
    [self.call cancel];
    [self.mockRestCall verify];
}

- (void)testXICOCreateMqttCredentialsCallReturnedError {
    NSError *error = [NSError errorWithDomain:@"sfbg" code:38 userInfo:nil];
    
    [[self.mockDelegate expect] createMqttCredentialsCall:self.call didFailWithError:error];
    [self.call XIRESTCall:nil didFinishWithError:error];
    [self.mockDelegate verify];
}

- (void)testXICOCreateMqttCredentialsCallPositiveResponse {
    NSString *mqttUsername = @"e40cd602-e9e7-43a6-9635-9dcf98f7f763";
    NSString *mqttSecret = @"xQsfTYlEkttd6vqEYCxaMpKrheW5/DzgRFzL2GG2Nxc=";
    NSDictionary *responseDict = @{
                                   @"mqttCredential": @{
                                       @"id": @"fdslkgfds;lkgfsjg;lfsdgjfdl;gkj",
                                       @"created": @"2015-08-03T08:01:41.000Z",
                                       @"createdById": @"xi/basicAuth/00000000-0000-0000-0000-000000000000",
                                       @"lastModified": @"2015-08-03T08:04:56.000Z",
                                       @"lastModifiedById": @"xi/basicAuth/00000000-0000-0000-0000-000000000000",
                                       @"ownedById": @"00000000-0000-0000-0000-000000000000",
                                       @"version": @"qJ",
                                       @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                       @"entityId": mqttUsername,
                                       @"entityType": @"endUser",
                                       @"secret": mqttSecret
                                   }
                                   };
    NSError *error = nil;
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:&error];
    assert(responseData);
    
    [[self.mockDelegate expect] createMqttCredentialsCall:self.call didSucceedWithMqttUserName:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *s = obj;
        return [s isEqualToString:mqttUsername];
    }] mqttPassword:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *s = obj;
        return [s isEqualToString:mqttSecret];
    }]];
    
    [self.call XIRESTCall:nil didFinishWithData:responseData httpStatusCode:200];
    
    [self.mockDelegate verify];
    
}

- (void)testXICOCreateMqttCredentialsCallMalformattedResponse {
    NSDictionary *responseDict = @{
                                   @"credential": @{
                                           @"created": @"2015-08-03T08:01:41.000Z",
                                           @"createdById": @"xi/basicAuth/00000000-0000-0000-0000-000000000000",
                                           @"lastModified": @"2015-08-03T08:04:56.000Z",
                                           @"lastModifiedById": @"xi/basicAuth/00000000-0000-0000-0000-000000000000",
                                           @"ownedById": @"00000000-0000-0000-0000-000000000000",
                                           @"version": @"qJ",
                                           @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                           @"entityType": @"endUser",
                                           }
                                   };
    NSError *error = nil;
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:&error];
    assert(responseData);
    
    [[self.mockDelegate expect] createMqttCredentialsCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError *)obj;
        
        return error.code == XIErrorInternal;
    }]];
    
    [self.call XIRESTCall:nil didFinishWithData:responseData httpStatusCode:200];
    
    [self.mockDelegate verify];
    
}

- (void)testXICOCreateMqttCredentialsCallMalformattedResponseNotAJson {
    NSString *mqttUsername = @"e40cd602-e9e7-43a6-9635-9dcf98f7f763";
    NSDictionary *responseDict = @{
                                   @"credential": @{
                                           @"id": mqttUsername,
                                           @"created": @"2015-08-03T08:01:41.000Z",
                                           @"createdById": @"xi/basicAuth/00000000-0000-0000-0000-000000000000",
                                           @"lastModified": @"2015-08-03T08:04:56.000Z",
                                           @"lastModifiedById": @"xi/basicAuth/00000000-0000-0000-0000-000000000000",
                                           @"ownedById": @"00000000-0000-0000-0000-000000000000",
                                           @"version": @"qJ",
                                           @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                           @"entityId": @"afc52b93-efe1-41b7-8a8a-19da0df2b0c5",
                                           @"entityType": @"endUser",
                                           }
                                   };
    NSError *error = nil;
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:&error];
    assert(responseData);
    
    [[self.mockDelegate expect] createMqttCredentialsCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError *)obj;
        
        return error.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:[responseData subdataWithRange:NSMakeRange(0, 30)] httpStatusCode:200];
    [self.mockDelegate verify];
}

- (void)testXICOCreateMqttCredentialsCallError401 {
    
    
    [[self.mockDelegate expect] createMqttCredentialsCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError *)obj;
        
        return error.code == XIErrorUnauthorized;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:401];
    [self.mockDelegate verify];
}

- (void)testXICOCreateMqttCredentialsCallError400 {
    
    
    [[self.mockDelegate expect] createMqttCredentialsCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError *)obj;
        
        return error.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:400];
    [self.mockDelegate verify];
}

- (void)testXICOCreateMqttCredentialsCallErrorAnyOtherStatus {
    
    
    [[self.mockDelegate expect] createMqttCredentialsCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError *)obj;
        
        return error.code == XIErrorUnknown;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:99];
    [self.mockDelegate verify];
}

- (void)testXICOCreateMqttCredentialsRestCallProviderCreation {
    XICOCreateMqttCredentialsRestCallProvider *callProvider = [[XICOCreateMqttCredentialsRestCallProvider alloc] initWithLogger:nil
                                                                                                               restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                                                                                 servicesConfig:(XIServicesConfig *)self.mockServicesConfig];
    XCTAssert(callProvider, @"Call provider creation failed");
    
    id obj = [callProvider createMqttCredentialsCall];
    
    XCTAssert(obj, @"Creator creation failed");

}



@end

//
//  XICOAuthenticationRestCallTests.m
//  common-iOS
//
//  Created by vfabian on 30/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XICOAuthenticationCall.h"
#import "XICOAuthenticationRestCall.h"
#import "XIServicesConfig.h"
#import <XivelySDK/XICommonError.h>
#import <XivelySDK/XIAuthenticationError.h>

@interface XICOAuthenticationRestCallTests : XCTestCase

@property(nonatomic, strong)XICOAuthenticationRestCall *call;
@property(nonatomic, strong)OCMockObject *mockRestCallProvider;
@property(nonatomic, strong)OCMockObject *mockServicesConfig;
@property(nonatomic, strong)OCMockObject *mockDelegate;
@property(nonatomic, strong)OCMockObject *mockRestCall;

@property(nonatomic, strong)NSString *emailAddress;
@property(nonatomic, strong)NSString *password;
@property(nonatomic, strong)NSString *accountId;

@end

@implementation XICOAuthenticationRestCallTests

- (void)setUp {
    [super setUp];
    self.emailAddress = @"fgfdgfdshhjgjf";
    self.password = @"sdljfdshaklfsdhfgdsklgh";
    self.accountId = @"wefjkhklgrewjhtrewlktjhrweltkwehtrkltjh";
    
    self.mockRestCallProvider = [OCMockObject mockForProtocol:@protocol(XIRESTCallProvider)];
    self.mockServicesConfig = [OCMockObject mockForClass:[XIServicesConfig class]];
    self.mockDelegate = [OCMockObject mockForProtocol:@protocol(XICOAuthenticationCallDelegate)];
    self.mockRestCall = [OCMockObject mockForProtocol:@protocol(XIRESTCall)];
    
    self.call = [[XICOAuthenticationRestCall alloc] initWithLogger:nil
                                                  restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                    servicesConfig:(XIServicesConfig *)self.mockServicesConfig];
    self.call.delegate = (id<XICOAuthenticationCallDelegate>)self.mockDelegate;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXICOAuthenticationRestCallCreation {
    XCTAssert(self.call, @"Creation failed");
}

- (void)testXICOAuthenticationRestCallStartRequest {
    NSString *loginServiceUrl = @"https://id.dev.xively.us/api/v1/blahblah";
    [[[self.mockServicesConfig expect] andReturn:loginServiceUrl] loginServiceUrl];
    [[[self.mockRestCallProvider expect] andReturn:self.mockRestCall] getEmptyRESTCall];
    [[self.mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];
    
    [[self.mockRestCall expect] startWithURL: [OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *param = (NSString *)obj;
        return [param isEqualToString:loginServiceUrl];
    }]
                                      method: XIRESTCallMethodPOST
                                     headers: [OCMArg any]
                                        body: [OCMArg checkWithBlock:^BOOL(id obj) {
        NSData *paramData = (NSData *)obj;
        NSError *error = nil;
        NSDictionary *paramsDict = [NSJSONSerialization JSONObjectWithData:paramData options:0 error:&error];
        if (error) return NO;
        
        BOOL ret = YES;
        ret = ret && [paramsDict[@"accountId"] isEqualToString:self.accountId];
        ret = ret && [paramsDict[@"password"] isEqualToString:self.password];
        ret = ret && [paramsDict[@"accountId"] isEqualToString:self.accountId];
        return ret;
    }]];
    
    [self.call requestLoginWithEmailAddress:self.emailAddress password:self.password accountId:self.accountId];
    
    [self.mockServicesConfig verify];
    [self.mockRestCallProvider verify];
    [self.mockRestCall verify];
}

- (void)testXICOAuthenticationRestCallCancelStartedRequest {
    [self testXICOAuthenticationRestCallStartRequest];
    
    [[self.mockRestCall expect] cancel];
    [self.call cancel];
    [self.mockRestCall verify];
}

- (void)testXICOAuthenticationRestCallErrorRestCallback {
    NSError *error = [NSError errorWithDomain:@"sfbg" code:38 userInfo:nil];
    
    [[self.mockDelegate expect] authenticationCall:self.call didFailWithError:error];
    [self.call XIRESTCall:nil didFinishWithError:error];
    [self.mockDelegate verify];
}

- (void)testXICOAuthenticationRestCallJwtRetreival {
    NSString *jwt = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpZCI6ImM5NmE0YzFmLTFiYWQtNDMyNC05NjY2LTVjYzBmODJlMjViYyIsInVzZXJJZCI6ImYwNTNkODE4LTdiMGQtNDllZS1iNWM1LTcxYWFiNzUxYTNhZiIsImV4cGlyZXMiOjE0MzgyNzE5MzIwODQsInJlbmV3YWxLZXkiOiJlYjVTa05XME5SWWsrS2RXcjdOdHdBPT0iLCJhY2NvdW50SWQiOiI1ODM5YmQ1ZS1kZDU2LTQ0ODMtYmUxMC03ZTAxMmUwOTZlYTciLCJjZXJ0IjoiMmFjYWQ5ZGEtZDY0Mi00Yjc4LWI1Y2EtMDdjYTliYjdiNWQzIn0.BCIRLJElvqsY3pSg2YXbKMpTQFNP77nVKU77cJH65ZnssErsM_pDYLyT1W_u8AvcFHHidg7PRvtBJ5B5R8qBglgJ5aztt3je2iM4Zajgh2zqzqZCBf2iWiWdWwBtO85sv0pelemYbzQVDRxGo_2qUrFu8Qo6x8eISmOWaFnlwrq-MPo7SEkC1f_9bUnf5d7r-rCQ9WNSvp0PyJOEDoEylms_XD8TQAT4YP5cDZOsml7pZVfx1oDwXyfD_15bNEP23rdN5SQV5jhab1_ENjMmlggyxLALjjCfJUPj-Z6IGIaor8sLVgPY7HgY3e1xbTfxdL4uUNFNzrrOjQvva51JCg";
    NSDictionary *dict = @{@"jwt":jwt};
    NSError *error = nil;
    NSData *d = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    [[self.mockDelegate expect] authenticationCall:self.call didReceiveJwt:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *paramString = (NSString *)obj;
        return [paramString isEqualToString:jwt];
    }]];
    [self.call XIRESTCall:nil didFinishWithData:d httpStatusCode:200];
    [self.mockDelegate verify];
}


- (void)testXICOAuthenticationRestCallChunkedJwtRetreival {
    NSString *jwt = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpZCI6ImM5NmE0YzFmLTFiYWQtNDMyNC05NjY2LTVjYzBmODJlMjViYyIsInVzZXJJZCI6ImYwNTNkODE4LTdiMGQtNDllZS1iNWM1LTcxYWFiNzUxYTNhZiIsImV4cGlyZXMiOjE0MzgyNzE5MzIwODQsInJlbmV3YWxLZXkiOiJlYjVTa05XME5SWWsrS2RXcjdOdHdBPT0iLCJhY2NvdW50SWQiOiI1ODM5YmQ1ZS1kZDU2LTQ0ODMtYmUxMC03ZTAxMmUwOTZlYTciLCJjZXJ0IjoiMmFjYWQ5ZGEtZDY0Mi00Yjc4LWI1Y2EtMDdjYTliYjdiNWQzIn0.BCIRLJElvqsY3pSg2YXbKMpTQFNP77nVKU77cJH65ZnssErsM_pDYLyT1W_u8AvcFHHidg7PRvtBJ5B5R8qBglgJ5aztt3je2iM4Zajgh2zqzqZCBf2iWiWdWwBtO85sv0pelemYbzQVDRxGo_2qUrFu8Qo6x8eISmOWaFnlwrq-MPo7SEkC1f_9bUnf5d7r-rCQ9WNSvp0PyJOEDoEylms_XD8TQAT4YP5cDZOsml7pZVfx1oDwXyfD_15bNEP23rdN5SQV5jhab1_ENjMmlggyxLALjjCfJUPj-Z6IGIaor8sLVgPY7HgY3e1xbTfxdL4uUNFNzrrOjQvva51JCg";
    NSDictionary *dict = @{@"jwt":jwt};
    NSError *error = nil;
    NSData *d = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    d = [d subdataWithRange:NSMakeRange(0, 22)];
    
    [[self.mockDelegate expect] authenticationCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error2 = (NSError *)obj;
        return error2.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:d httpStatusCode:200];
    [self.mockDelegate verify];
}

- (void)testXICOAuthenticationRestCallInvalidCredentialsError {
    [[self.mockDelegate expect] authenticationCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error2 = (NSError *)obj;
        return error2.code == XIAuthenticationErrorInvalidCredentials;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:401];
    [self.mockDelegate verify];
}

- (void)testXICOAuthenticationRestCallAnyOtherStatus {
    [[self.mockDelegate expect] authenticationCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error2 = (NSError *)obj;
        return error2.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:99];
    [self.mockDelegate verify];
}

@end

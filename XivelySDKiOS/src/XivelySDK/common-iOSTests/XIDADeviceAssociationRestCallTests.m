//
//  XIDADeviceAssociationRestCallTests.m
//  common-iOS
//
//  Created by vfabian on 20/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIDADeviceAssociationRestCall.h"
#import "XIDADeviceAssociationRestCallProvider.h"
#import "XIServicesConfig.h"
#import <XivelySDK/DeviceAssociation/XIDeviceAssociationError.h>
#import <XivelySDK/XICommonError.h>


@interface XIDADeviceAssociationRestCallTests : XCTestCase

@property(nonatomic, strong)XIDADeviceAssociationRestCall *call;
@property(nonatomic, strong)OCMockObject *mockCallDelegate;
@property(nonatomic, strong)OCMockObject *mockRestCallProvider;
@property(nonatomic, strong)OCMockObject *mockServicesProvider;
@property(nonatomic, strong)NSString *endUserId;
@property(nonatomic, strong)NSString *associationCode;

@end

@implementation XIDADeviceAssociationRestCallTests

- (void)setUp {
    [super setUp];
    
    self.endUserId = @"k4wqjht5423lkjh4365lkj342h5lkj3543lk6h23lk643h5";
    self.associationCode = @"543klj6g3kl6453g6jk543hg645j6khg4jhk45g6jk453hg64j5k6hg6jkh45g6j45hg4j35khg4j645gh";
    self.mockRestCallProvider = [OCMockObject mockForProtocol:@protocol(XIRESTCallProvider)];
    self.mockServicesProvider = [OCMockObject mockForClass:[XIServicesConfig class]];
    self.mockCallDelegate = [OCMockObject mockForProtocol:@protocol(XIDADeviceAssociationCallDelegate)];
    self.call = [[XIDADeviceAssociationRestCall alloc] initWithLogger:nil
                                                     restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                       servicesConfig:(XIServicesConfig *)self.mockServicesProvider];
    self.call.delegate =(id<XIDADeviceAssociationCallDelegate>)self.mockCallDelegate;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDeviceAssociationRestCallCreation {
    XCTAssert(self.call, @"Creation failed");
}

- (void)testDeviceAssociationStartCall {
    OCMockObject *mockRestCall = [OCMockObject mockForProtocol:@protocol(XIRESTCall)];
    
    [[[self.mockRestCallProvider expect] andReturn:mockRestCall] getEmptyRESTCall];
    [[mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];
    [[mockRestCall expect] startWithURL: [OCMArg any]
                                 method: XIRESTCallMethodPOST
                                headers: [OCMArg any]
                                   body: [OCMArg any]];
    
    [[self.mockServicesProvider expect] deviceAssociationServiceUrl];
    
    [self.call requestWithEndUserId:self.endUserId associationCode:self.associationCode];
    
    [self.mockRestCallProvider verify];
    [mockRestCall verify];
    [self.mockServicesProvider verify];
}

- (void)testDeviceAssociationStartCallAndCancel {
    OCMockObject *mockRestCall = [OCMockObject mockForProtocol:@protocol(XIRESTCall)];
    
    [[[self.mockRestCallProvider expect] andReturn:mockRestCall] getEmptyRESTCall];
    [[mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];
    [[mockRestCall expect] startWithURL: [OCMArg any]
                                 method: XIRESTCallMethodPOST
                                headers: [OCMArg any]
                                   body: [OCMArg any]];
    
    [[self.mockServicesProvider expect] deviceAssociationServiceUrl];
    
    [self.call requestWithEndUserId:self.endUserId associationCode:self.associationCode];
    
    [self.mockRestCallProvider verify];
    [mockRestCall verify];
    [self.mockServicesProvider verify];
    
    [[mockRestCall expect] cancel];
    [self.call cancel];
    [mockRestCall verify];
}

- (void)testDeviceAssociationGeneralErrors {
    NSError *error = [NSError errorWithDomain:@"sfghksdfjgh" code:765 userInfo:nil];
    
    [[self.mockCallDelegate expect] deviceAssociationCall:self.call didFailWithError:error];
    [self.call XIRESTCall:nil didFinishWithError:error];
    [self.mockCallDelegate verify];
}

- (void)testDeviceAssociationError400 {
    
    [[self.mockCallDelegate expect] deviceAssociationCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *err = (NSError *)obj;
        return err.code == XIDeviceAssociationErrorInvalidCode;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:[OCMArg any] httpStatusCode:400];
    [self.mockCallDelegate verify];
}

- (void)testDeviceAssociationError404 {
    
    [[self.mockCallDelegate expect] deviceAssociationCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *err = (NSError *)obj;
        return err.code == XIDeviceAssociationErrorInvalidCode;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:[OCMArg any] httpStatusCode:404];
    [self.mockCallDelegate verify];
}

- (void)testDeviceAssociationError422 {
    
    [[self.mockCallDelegate expect] deviceAssociationCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *err = (NSError *)obj;
        return err.code == XIDeviceAssociationErrorDeviceNotAssociatable;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:[OCMArg any] httpStatusCode:422];
    [self.mockCallDelegate verify];
}

- (void)testDeviceAssociationError500 {
    
    [[self.mockCallDelegate expect] deviceAssociationCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *err = (NSError *)obj;
        return err.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:[OCMArg any] httpStatusCode:500];
    [self.mockCallDelegate verify];
}

- (void)testDeviceAssociationError503 {
    
    [[self.mockCallDelegate expect] deviceAssociationCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *err = (NSError *)obj;
        return err.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:[OCMArg any] httpStatusCode:503];
    [self.mockCallDelegate verify];
}

- (void)testDeviceAssociationInvalid200Callback {
    
    //[[self.mockCallDelegate expect] deviceAssociationCall:self.call didSucceedWithDeviceId:nil];
    
    [[self.mockCallDelegate expect] deviceAssociationCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *err = (NSError *)obj;
        return err.code == XIErrorInternal;
    }]];
    
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:200];
    [self.mockCallDelegate verify];
}

- (void)testDeviceAssociationValid200Callback {
    NSString *deviceId = @"e53c3ace-6b06-4c4a-bdf4-fc86a380641e";
    NSData* json = [NSJSONSerialization dataWithJSONObject:@{@"deviceId": deviceId} options: 0 error:nil];
    
    [[self.mockCallDelegate expect] deviceAssociationCall:self.call didSucceedWithDeviceId:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *str = (NSString *)obj;
        return [deviceId isEqualToString:str];
    }]];
    
    [self.call XIRESTCall:nil didFinishWithData:json httpStatusCode:200];
    [self.mockCallDelegate verify];
}

- (void)testDeviceAssociationRestCallProviderCreation {
    XIDADeviceAssociationRestCallProvider *provider = [[XIDADeviceAssociationRestCallProvider alloc] initWithLogger:nil
                                                                                           restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                                                                     servicesConfig:(XIServicesConfig *)self.mockServicesProvider];
    XCTAssert(provider, @"Creation failed");
}

- (void)testDeviceAssociationRestCallProviderGettingACall {
    XIDADeviceAssociationRestCallProvider *provider = [[XIDADeviceAssociationRestCallProvider alloc] initWithLogger:nil
                                                                                                   restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                                                                     servicesConfig:(XIServicesConfig *)self.mockServicesProvider];
    
    id<XIDADeviceAssociationCall> call = [provider deviceAssociationCall];
    XCTAssert(call, @"CallRetreival failed");
}



@end

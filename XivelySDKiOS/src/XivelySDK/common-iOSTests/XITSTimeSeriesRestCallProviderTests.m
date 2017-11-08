//
//  XITSTimeSeriesRestCallProviderTests.m
//  common-iOS
//
//  Created by vfabian on 15/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "XITSTimeSeriesRestCallProvider.h"

@interface XITSTimeSeriesRestCallProviderTests : XCTestCase

@property(nonatomic, strong)OCMockObject *mockRestCallProvider;
@property(nonatomic, strong)OCMockObject *mockServicesConfig;
@property(nonatomic, strong)OCMockObject *mockDelegate;
@property(nonatomic, strong)OCMockObject *mockRestCall;


@end

@implementation XITSTimeSeriesRestCallProviderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXITSTimeSeriesRestCallProviderCreation {
    self.mockRestCallProvider = [OCMockObject mockForProtocol:@protocol(XIRESTCallProvider)];
    self.mockServicesConfig = [OCMockObject mockForClass:[XIServicesConfig class]];
    self.mockRestCall = [OCMockObject mockForProtocol:@protocol(XIRESTCall)];
    
    XITSTimeSeriesRestCallProvider *provider = [[XITSTimeSeriesRestCallProvider alloc] initWithLogger:nil
                                                                                             restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                                                               servicesConfig:(XIServicesConfig *)self.mockServicesConfig];
    XCTAssert(provider, @"Creation failed");
}

- (void)testXITSTimeSeriesRestCallProviderProvision {
    self.mockRestCallProvider = [OCMockObject mockForProtocol:@protocol(XIRESTCallProvider)];
    self.mockServicesConfig = [OCMockObject mockForClass:[XIServicesConfig class]];
    self.mockRestCall = [OCMockObject mockForProtocol:@protocol(XIRESTCall)];
    
    XITSTimeSeriesRestCallProvider *provider = [[XITSTimeSeriesRestCallProvider alloc] initWithLogger:nil
                                                                                     restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                                                       servicesConfig:(XIServicesConfig *)self.mockServicesConfig];
    XCTAssert([provider timeSeriesCall], @"Provision failed");
}

@end

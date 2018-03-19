//
//  XITSTimeSeriesRestCallTests.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XITSTimeSeriesRestCall.h"
#import "NSDateFormatter+XITimeSeries.h"
#import <XivelySDK/XICommonError.h>
#import <XivelySDK/XIEnvironment.h>
#import <XivelySDK/XISdkConfig+Selector.h>


@interface XITSTimeSeriesRestCallTests : XCTestCase

@property(nonatomic, strong)XITSTimeSeriesRestCall *call;
@property(nonatomic, strong)OCMockObject *mockRestCallProvider;
@property(nonatomic, strong)OCMockObject *mockServicesConfig;
@property(nonatomic, strong)OCMockObject *mockDelegate;
@property(nonatomic, strong)OCMockObject *mockRestCall;
@property(nonatomic, strong)NSString *topic;
@property(nonatomic, strong)NSString *startDateString;
@property(nonatomic, strong)NSString *endDateString;
@property(nonatomic, strong)NSDate *startDate;
@property(nonatomic, strong)NSDate *endDate;
@property(nonatomic, assign)NSInteger pageSize;
@property(nonatomic, strong)NSString *pagingToken;
@property(nonatomic, strong)NSDateFormatter *dateFormatter;


@end

@implementation XITSTimeSeriesRestCallTests

- (void)setUp {
    [super setUp];
    
    self.dateFormatter = [NSDateFormatter timeSeriesDateFormatter];
    self.topic = @"43kjl56h432klj654h36klj543h6kl4356h534lk63/gdfg/dfgsdfgd/dfg/dfg/fdg/fdg";
    self.startDateString = @"2015-09-14T11:30:02Z";
    self.endDateString = @"2015-09-14T22:30:02Z";
    self.startDate = [self.dateFormatter dateFromString:self.startDateString];
    self.endDate = [self.dateFormatter dateFromString:self.endDateString];
    self.pageSize = 55;
    self.pagingToken = @"25lk42j5kl4325h432lkj5432k5jl43h5kl34j5h34kl5h435klj43h5";
    
    self.mockRestCallProvider = [OCMockObject mockForProtocol:@protocol(XIRESTCallProvider)];
    self.mockServicesConfig = [OCMockObject mockForClass:[XIServicesConfig class]];
    self.mockDelegate = [OCMockObject mockForProtocol:@protocol(XITSTimeSeriesCallDelegate)];
    self.mockRestCall = [OCMockObject mockForProtocol:@protocol(XIRESTCall)];
    
    self.call = [[XITSTimeSeriesRestCall alloc] initWithLogger:nil
                                                  restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                    servicesConfig:(XIServicesConfig *)self.mockServicesConfig];
    self.call.delegate = (id<XITSTimeSeriesCallDelegate>)self.mockDelegate;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testXITSTimeSeriesRestCallCreation {
    XCTAssert(self.call, @"Creation failed");
}

- (void)testXITSTimeSeriesRestCallStartRequestWithAllParams {
    NSString *tsServiceUrl = @"https://timeseries.dev.xively.us/api/v4/blahblah";
    [[[self.mockServicesConfig expect] andReturn:tsServiceUrl] timeSeriesServiceUrl];
    [[[self.mockRestCallProvider expect] andReturn:self.mockRestCall] getEmptyRESTCall];
    [[self.mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];

    XISdkConfig *sdkConfig = [XISdkConfig configWithHTTPResponseTimeout:1 urlSession:nil
                                                     mqttConnectTimeout:1 mqttRetryAttempt:1 mqttWaitOnReconnect:1 environment:XIEnvironmentLive];
    [[[self.mockServicesConfig stub] andReturn:sdkConfig] sdkConfig];
 
    [[self.mockRestCall expect] startWithURL: [OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *urlString = (NSString *)obj;
        return [urlString rangeOfString:@"pageSize=55"].location != NSNotFound &&
        [urlString rangeOfString:[NSString stringWithFormat:@"pagingToken=%@", self.pagingToken]].location != NSNotFound;
    }]
                                      method: XIRESTCallMethodGET
                                     headers: [OCMArg any]
                                        body: [OCMArg any]];
 
    [self.call requestWithTopic:self.topic startDate:self.startDate endDate:self.endDate pageSize:self.pageSize pagingToken:self.pagingToken];
 
    [self.mockServicesConfig verify];
    [self.mockRestCallProvider verify];
    [self.mockRestCall verify];
}

- (void)testXITSTimeSeriesRestCallStartRequestWithNoPagingSize {
    NSString *tsServiceUrl = @"https://timeseries.dev.xively.us/api/v4/blahblah";
    [[[self.mockServicesConfig expect] andReturn:tsServiceUrl] timeSeriesServiceUrl];
    [[[self.mockRestCallProvider expect] andReturn:self.mockRestCall] getEmptyRESTCall];
    [[self.mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];
    
    XISdkConfig *sdkConfig = [XISdkConfig configWithHTTPResponseTimeout:1 urlSession:nil
                                                     mqttConnectTimeout:1 mqttRetryAttempt:1 mqttWaitOnReconnect:1 environment:XIEnvironmentLive];
    [[[self.mockServicesConfig stub] andReturn:sdkConfig] sdkConfig];
    
    [[self.mockRestCall expect] startWithURL: [OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *urlString = (NSString *)obj;
        return [urlString rangeOfString:@"pageSize=1000"].location != NSNotFound &&
        [urlString rangeOfString:[NSString stringWithFormat:@"pagingToken=%@", self.pagingToken]].location != NSNotFound;
    }]
                                      method: XIRESTCallMethodGET
                                     headers: [OCMArg any]
                                        body: [OCMArg any]];
    
    [self.call requestWithTopic:self.topic startDate:self.startDate endDate:self.endDate pageSize:0 pagingToken:self.pagingToken];
    
    [self.mockServicesConfig verify];
    [self.mockRestCallProvider verify];
    [self.mockRestCall verify];
}

- (void)testXITSTimeSeriesRestCallStartRequestWithNoEmptyPagingToken {
    NSString *tsServiceUrl = @"https://timeseries.dev.xively.us/api/v4/blahblah";
    [[[self.mockServicesConfig expect] andReturn:tsServiceUrl] timeSeriesServiceUrl];
    [[[self.mockRestCallProvider expect] andReturn:self.mockRestCall] getEmptyRESTCall];
    [[self.mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];
    
    XISdkConfig *sdkConfig = [XISdkConfig configWithHTTPResponseTimeout:1 urlSession:nil
                                                     mqttConnectTimeout:1 mqttRetryAttempt:1 mqttWaitOnReconnect:1 environment:XIEnvironmentLive];
    [[[self.mockServicesConfig stub] andReturn:sdkConfig] sdkConfig];
    
    [[self.mockRestCall expect] startWithURL: [OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *urlString = (NSString *)obj;
        return [urlString rangeOfString:@"pagingToken"].location == NSNotFound;
    }]
                                      method: XIRESTCallMethodGET
                                     headers: [OCMArg any]
                                        body: [OCMArg any]];
    
    [self.call requestWithTopic:self.topic startDate:self.startDate endDate:self.endDate pageSize:self.pageSize pagingToken:nil];
    
    [self.mockServicesConfig verify];
    [self.mockRestCallProvider verify];
    [self.mockRestCall verify];
}
 
- (void)testXITSTimeSeriesRestCallCancelRunningRequest {
    [self testXITSTimeSeriesRestCallStartRequestWithAllParams];

    [[self.mockRestCall expect] cancel];
    [self.call cancel];
    [self.mockRestCall verify];
}

- (void)testXITSTimeSeriesRestCallErrorRestCallback {
    NSError *error = [NSError errorWithDomain:@"sfbg" code:38 userInfo:nil];

    [[self.mockDelegate expect] timeSeriesCall:self.call didFailWithError:error];
    [self.call XIRESTCall:nil didFinishWithError:error];
    [self.mockDelegate verify];
}
 

- (void)testXITSTimeSeriesRestCallPositiveResponse {
 
    NSDictionary *dict = @{
                               @"meta": @{
                                   @"timeSpent": @230,
                                   @"start": @"2015-09-14T12:55:52Z",
                                   @"end": @"2015-09-14T12:55:54Z",
                                   @"count": @3,
                                   @"pagingToken": @"ef2e90cd-5adf-11e5-a5fd-0e2dcaf01c6b"
                               },
                               @"result": @[
                                          @{
                                              @"time": @"2015-09-14T12:55:52Z",
                                              @"category": @"chat",
                                              @"stringValue": @"{\"type\":\"Message\",\"data\":{\"message\":\"g\",\"timestamp\":1442235352520,\"displayName\":\"Ben Xively\",\"messageType\":\"visitor\"},\"userId\":\"2c2535ef-8d82-4e56-8df0-3022b95d3c5c\"}"
                                          },
                                          @{
                                              @"time": @"2015-09-14T12:55:53Z",
                                              @"category": @"chat",
                                              @"stringValue": @"{\"type\":\"Message\",\"data\":{\"message\":\"h\",\"timestamp\":1442235353183,\"displayName\":\"Ben Xively\",\"messageType\":\"visitor\"},\"userId\":\"2c2535ef-8d82-4e56-8df0-3022b95d3c5c\"}"
                                          },
                                          @{
                                              @"time": @"2015-09-14T12:55:54Z",
                                              @"category": @"chat",
                                              @"stringValue": @"{\"type\":\"EndChat\",\"data\":{\"message\":\"\",\"chatId\":\"ED3239F8-5ADF-11E5-9FB0-06EEAEDEA91B\",\"timestamp\":1442235354132,\"displayName\":\"Ben Xively\"},\"userId\":\"2c2535ef-8d82-4e56-8df0-3022b95d3c5c\"}"
                                          }
                                          ]
                           };
    NSError *error = nil;
    NSData *d = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
 
    [[self.mockDelegate expect] timeSeriesCall:self.call didSucceedWithTimeSeriesItems:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSArray *array = (NSArray *)obj;
        return array.count == 3;
    }] meta:[OCMArg checkWithBlock:^BOOL(id obj) {
        XITSTimeSeriesMeta *meta = (XITSTimeSeriesMeta *)obj;
        return meta != nil;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:d httpStatusCode:200];
    [self.mockDelegate verify];
}

- (void)testXITSTimeSeriesRestCallWithInvalidPositiveResponse {
    
    NSDictionary *dict = @{
                           @"meta": @{
                                   @"timeSpent": @230,
                                   @"start": @"2015-09-14T12:55:52Z",
                                   @"end": @"2015-09-14T12:55:54Z",
                                   @"count": @3,
                                   @"pagingToken": @"ef2e90cd-5adf-11e5-a5fd-0e2dcaf01c6b"
                                   },
                           @"result": @[
                                   @{
                                       @"time": @"2015-09-14T12:55:52Z",
                                       @"category": @"chat",
                                       @"stringValue": @"{\"type\":\"Message\",\"data\":{\"message\":\"g\",\"timestamp\":1442235352520,\"displayName\":\"Ben Xively\",\"messageType\":\"visitor\"},\"userId\":\"2c2535ef-8d82-4e56-8df0-3022b95d3c5c\"}"
                                       },
                                   @{
                                       @"time": @"2015-09-14T12:55:53Z",
                                       @"category": @"chat",
                                       @"stringValue": @"{\"type\":\"Message\",\"data\":{\"message\":\"h\",\"timestamp\":1442235353183,\"displayName\":\"Ben Xively\",\"messageType\":\"visitor\"},\"userId\":\"2c2535ef-8d82-4e56-8df0-3022b95d3c5c\"}"
                                       },
                                   @{
                                       @"time": @"2015-09-14T12:55:54Z",
                                       @"category": @"chat",
                                       @"stringValue": @"{\"type\":\"EndChat\",\"data\":{\"message\":\"\",\"chatId\":\"ED3239F8-5ADF-11E5-9FB0-06EEAEDEA91B\",\"timestamp\":1442235354132,\"displayName\":\"Ben Xively\"},\"userId\":\"2c2535ef-8d82-4e56-8df0-3022b95d3c5c\"}"
                                       }
                                   ]
                           };
    NSError *error = nil;
    NSData *d = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    d = [d subdataWithRange:NSMakeRange(0, 22)];
    
    [[self.mockDelegate expect] timeSeriesCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *e = (NSError *)obj;
        return e.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:d httpStatusCode:200];
    [self.mockDelegate verify];
}

- (void)testXITSTimeSeriesRestCall404PositiveResponse {
    [[self.mockDelegate expect] timeSeriesCall:self.call didSucceedWithTimeSeriesItems:@[] meta:nil];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:404];
    [self.mockDelegate verify];
}

- (void)testXIDIDeviceInfoListRestCall400Status {
    [[self.mockDelegate expect] timeSeriesCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error2 = (NSError *)obj;
        return error2.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:400];
    [self.mockDelegate verify];
}

- (void)testXIDIDeviceInfoListRestCall401Status {
    [[self.mockDelegate expect] timeSeriesCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error2 = (NSError *)obj;
        return error2.code == XIErrorUnauthorized;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:401];
    [self.mockDelegate verify];
}

- (void)testXIDIDeviceInfoListRestCallAnyOtherStatus {
    [[self.mockDelegate expect] timeSeriesCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error2 = (NSError *)obj;
        return error2.code == XIErrorUnknown;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:99];
    [self.mockDelegate verify];
}

@end

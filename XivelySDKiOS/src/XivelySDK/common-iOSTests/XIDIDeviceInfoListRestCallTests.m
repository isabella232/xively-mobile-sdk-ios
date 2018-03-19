//
//  XIDIDeviceInfoListRestCallTests.m
//  common-iOS
//
//  Created by vfabian on 25/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIDIDeviceInfoListRestCall.h"
#import <XivelySDK/XICommonError.h>
#import <XivelySDK/XIAuthenticationError.h>
#import <XivelySDK/XIEnvironment.h>
#import <XivelySDK/XISdkConfig+Selector.h>

@interface XIDIDeviceInfoListRestCallTests : XCTestCase

@property(nonatomic, strong)XIDIDeviceInfoListRestCall *call;
@property(nonatomic, strong)OCMockObject *mockRestCallProvider;
@property(nonatomic, strong)OCMockObject *mockServicesConfig;
@property(nonatomic, strong)OCMockObject *mockDelegate;
@property(nonatomic, strong)OCMockObject *mockRestCall;
@property(nonatomic, strong)NSString *accountId;
@property(nonatomic, strong)NSString *organizationId;

@end

@implementation XIDIDeviceInfoListRestCallTests

- (void)setUp {
    [super setUp];
    
    self.accountId = @"etjklh3tkl43jh43klj543h5lkj432h6kl23j6h524kl6h45k6l";
    self.organizationId = @"23kjh4g5324jkh5g243jk5hg4325jk432g5kj432h5g43jk5hg3245jkh3g45jk34g";
    
    self.mockRestCallProvider = [OCMockObject mockForProtocol:@protocol(XIRESTCallProvider)];
    self.mockServicesConfig = [OCMockObject mockForClass:[XIServicesConfig class]];
    self.mockDelegate = [OCMockObject mockForProtocol:@protocol(XIDIDeviceInfoListCallDelegate)];
    self.mockRestCall = [OCMockObject mockForProtocol:@protocol(XIRESTCall)];
    
    self.call = [[XIDIDeviceInfoListRestCall alloc] initWithLogger:nil
                                              restCallProvider:(id<XIRESTCallProvider>)self.mockRestCallProvider
                                                servicesConfig:(XIServicesConfig *)self.mockServicesConfig];
    self.call.delegate = (id<XIDIDeviceInfoListCallDelegate>)self.mockDelegate;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIDIDeviceInfoListRestCallCreation {
    XCTAssert(self.call, @"Creation failed");
}

- (void)testXIDIDeviceInfoListRestCallStartRequest {
    NSString *loginServiceUrl = @"https://blueprint.dev.xively.us/api/v1/blahblah";
    [[[self.mockServicesConfig expect] andReturn:loginServiceUrl] blueprintDevicesServiceUrl];
    [[[self.mockRestCallProvider expect] andReturn:self.mockRestCall] getEmptyRESTCall];
    [[self.mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];
    
    XISdkConfig *sdkConfig = [XISdkConfig configWithHTTPResponseTimeout:1 urlSession:nil mqttConnectTimeout:1 mqttRetryAttempt:1 mqttWaitOnReconnect:1 environment:XIEnvironmentLive];
    [[[self.mockServicesConfig stub] andReturn:sdkConfig] sdkConfig];
    
    [[self.mockRestCall expect] startWithURL: [OCMArg any]
                                      method: XIRESTCallMethodGET
                                     headers: [OCMArg any]
                                        body: [OCMArg any]];
    
    [self.call requestWithAccountId:self.accountId organizationId:self.organizationId pageSize:10 page:1];
    
    [self.mockServicesConfig verify];
    [self.mockRestCallProvider verify];
    [self.mockRestCall verify];
}

- (void)testXIDIDeviceInfoListRestCallCancelStartedRequest {
    [self testXIDIDeviceInfoListRestCallStartRequest];
    
    [[self.mockRestCall expect] cancel];
    [self.call cancel];
    [self.mockRestCall verify];
}

- (void)testXIDIDeviceInfoListRestCallErrorRestCallback {
    NSError *error = [NSError errorWithDomain:@"sfbg" code:38 userInfo:nil];
    
    [[self.mockDelegate expect] deviceInfoListCall:self.call didFailWithError:error];
    [self.call XIRESTCall:nil didFinishWithError:error];
    [self.mockDelegate verify];
}


- (void)testXIDIDeviceInfoListRestCallPositiveResponse {
    
    NSDictionary *dict = @{
                           @"devices": @{
                               @"results": @[
                                           @{
                                               @"id": @"d310396b-8d21-4484-931c-693ff860984a",
                                               @"created": @"2015-04-01T12:55:18.000Z",
                                               @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"lastModified": @"2015-04-01T12:55:18.000Z",
                                               @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"version": @"7N",
                                               @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                               @"deviceTemplateId": @"df23460f-f590-4478-b958-c699a6c57c4f",
                                               @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
                                               @"serialNumber": @"veDnIwWJzjQ",
                                               @"provisioningState": @"defined",
                                               @"deviceVersion": [NSNull null],
                                               @"location": [NSNull null],
                                               @"name": [NSNull null],
                                               @"purchaseDate": [NSNull null],
                                               @"channels": @[
                                                            @{
                                                                @"channelTemplateId": @"ec062f13-b6b4-4b7a-8d82-3463c541ec24",
                                                                @"channelTemplateName": @"device-template",
                                                                @"persistenceType": @"simple",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/device-template"
                                                            },
                                                            @{
                                                                @"channelTemplateId": @"f1ff428c-39d3-43ae-8142-9eaf50687d8d",
                                                                @"channelTemplateName": @"device-log",
                                                                @"persistenceType": @"simple",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/device-log"
                                                            },
                                                            @{
                                                                @"channelTemplateId": @"f6e1132e-d567-41e7-94e5-892986be68fc",
                                                                @"channelTemplateName": @"control",
                                                                @"persistenceType": @"simple",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/control"
                                                            }
                                                            ]
                                           },
                                           @{
                                               @"id": @"09568054-5b66-4bc7-9b5b-7a189016ef53",
                                               @"created": @"2015-04-24T11:55:28.000Z",
                                               @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"lastModified": @"2015-04-24T11:55:28.000Z",
                                               @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"version": @"WV",
                                               @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                               @"deviceTemplateId": @"5516cc02-b27f-4ad2-9b8c-b1489b23aadc",
                                               @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
                                               @"serialNumber": @"2d7d3405-49b2-44e5-8f2b-eca0c32aebe0",
                                               @"provisioningState": @"defined",
                                               @"deviceVersion": [NSNull null],
                                               @"location": [NSNull null],
                                               @"name": [NSNull null],
                                               @"purchaseDate": [NSNull null],
                                               @"channels": @[
                                                            @{
                                                                @"channelTemplateId": @"607445df-aaf1-4bf0-9f00-5b2a4a1fac8c",
                                                                @"channelTemplateName": @"ad-hoc-topic-persistent",
                                                                @"persistenceType": @"timeSeries",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-persistent"
                                                            },
                                                            @{
                                                                @"channelTemplateId": @"ea45c846-5481-4b4e-a472-f72878a85e1c",
                                                                @"channelTemplateName": @"ad-hoc-topic-simple",
                                                                @"persistenceType": @"simple",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-simple"
                                                            }
                                                            ]
                                           }
                                           ],
                               @"meta": @{
                                   @"count": @(798),
                                   @"page": @(1),
                                   @"pageSize": @(2),
                                   @"sortOrder": @"asc"
                               }
                           }
                           };
    NSError *error = nil;
    NSData *d = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    [[self.mockDelegate expect] deviceInfoListCall:self.call didSucceedWithDeviceInfoList:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSArray *array = (NSArray *)obj;
        return array.count == 2;
        
    }] meta:[OCMArg checkWithBlock:^BOOL(id obj) {
        XIDIDeviceInfoListMeta *meta = (XIDIDeviceInfoListMeta *)obj;
        return meta != nil;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:d httpStatusCode:200];
    [self.mockDelegate verify];
}


- (void)testXIDIDeviceInfoListRestCallChunkedPositiveResponse {
    NSDictionary *dict = @{
                           @"devices": @{
                                   @"results": @[
                                           @{
                                               @"id": @"d310396b-8d21-4484-931c-693ff860984a",
                                               @"created": @"2015-04-01T12:55:18.000Z",
                                               @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"lastModified": @"2015-04-01T12:55:18.000Z",
                                               @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"version": @"7N",
                                               @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                               @"deviceTemplateId": @"df23460f-f590-4478-b958-c699a6c57c4f",
                                               @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
                                               @"serialNumber": @"veDnIwWJzjQ",
                                               @"provisioningState": @"defined",
                                               @"deviceVersion": [NSNull null],
                                               @"location": [NSNull null],
                                               @"name": [NSNull null],
                                               @"purchaseDate": [NSNull null],
                                               @"channels": @[
                                                       @{
                                                           @"channelTemplateId": @"ec062f13-b6b4-4b7a-8d82-3463c541ec24",
                                                           @"channelTemplateName": @"device-template",
                                                           @"persistenceType": @"simple",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/device-template"
                                                           },
                                                       @{
                                                           @"channelTemplateId": @"f1ff428c-39d3-43ae-8142-9eaf50687d8d",
                                                           @"channelTemplateName": @"device-log",
                                                           @"persistenceType": @"simple",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/device-log"
                                                           },
                                                       @{
                                                           @"channelTemplateId": @"f6e1132e-d567-41e7-94e5-892986be68fc",
                                                           @"channelTemplateName": @"control",
                                                           @"persistenceType": @"simple",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/control"
                                                           }
                                                       ]
                                               },
                                           @{
                                               @"id": @"09568054-5b66-4bc7-9b5b-7a189016ef53",
                                               @"created": @"2015-04-24T11:55:28.000Z",
                                               @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"lastModified": @"2015-04-24T11:55:28.000Z",
                                               @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"version": @"WV",
                                               @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                               @"deviceTemplateId": @"5516cc02-b27f-4ad2-9b8c-b1489b23aadc",
                                               @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
                                               @"serialNumber": @"2d7d3405-49b2-44e5-8f2b-eca0c32aebe0",
                                               @"provisioningState": @"defined",
                                               @"deviceVersion": [NSNull null],
                                               @"location": [NSNull null],
                                               @"name": [NSNull null],
                                               @"purchaseDate": [NSNull null],
                                               @"channels": @[
                                                       @{
                                                           @"channelTemplateId": @"607445df-aaf1-4bf0-9f00-5b2a4a1fac8c",
                                                           @"channelTemplateName": @"ad-hoc-topic-persistent",
                                                           @"persistenceType": @"timeSeries",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-persistent"
                                                           },
                                                       @{
                                                           @"channelTemplateId": @"ea45c846-5481-4b4e-a472-f72878a85e1c",
                                                           @"channelTemplateName": @"ad-hoc-topic-simple",
                                                           @"persistenceType": @"simple",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-simple"
                                                           }
                                                       ]
                                               }
                                           ],
                                   @"meta": @{
                                           @"count": @(798),
                                           @"page": @(1),
                                           @"pageSize": @(2),
                                           @"sortOrder": @"asc"
                                           }
                                   }
                           };
    NSError *error = nil;
    NSData *d = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    d = [d subdataWithRange:NSMakeRange(0, 22)];
    
    [[self.mockDelegate expect] deviceInfoListCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error2 = (NSError *)obj;
        return error2.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:d httpStatusCode:200];
    [self.mockDelegate verify];
}

- (void)testXIDIDeviceInfoListRestCallAnyOtherStatus {
    [[self.mockDelegate expect] deviceInfoListCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error2 = (NSError *)obj;
        return error2.code == XIErrorUnknown;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:nil httpStatusCode:99];
    [self.mockDelegate verify];
}

- (void)testXIDIDeviceInfoListRestCallStartBatchRequest {
    NSString *devicesServiceUrl = @"https://blueprint.dev.xively.us/api/v1/devices";
    NSString *batchServiceUrl = @"https://blueprint.dev.xively.us/api/v1/batch";
    [[[self.mockServicesConfig stub] andReturn:batchServiceUrl] blueprintBatchServiceUrl];
    [[[self.mockServicesConfig stub] andReturn:devicesServiceUrl] blueprintDevicesServiceUrl];
    [[[self.mockRestCallProvider expect] andReturn:self.mockRestCall] getEmptyRESTCall];
    [[self.mockRestCall expect] setDelegate:(id<NSFileManagerDelegate>)self.call];
    
    XISdkConfig *sdkConfig = [XISdkConfig configWithHTTPResponseTimeout:1 urlSession:nil mqttConnectTimeout:1 mqttRetryAttempt:1 mqttWaitOnReconnect:1 environment:XIEnvironmentLive];
    [[[self.mockServicesConfig stub] andReturn:sdkConfig] sdkConfig];
    
    [[self.mockRestCall expect] startWithURL: batchServiceUrl
                                      method: XIRESTCallMethodPOST
                                     headers: [OCMArg any]
                                        body: [OCMArg checkWithBlock:^BOOL(id obj) {
        NSData *data = (NSData *)obj;
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSArray *a = dict[@"requests"];
        return !error && a.count == 5;
    }]];
    
    [self.call requestWithAccountId:self.accountId organizationId:self.organizationId pageSize:1 pagesFrom:1 pagesTo:5];
    
    [self.mockServicesConfig verify];
    [self.mockRestCallProvider verify];
    [self.mockRestCall verify];
}

- (void)testXIDIDeviceInfoListRestCallCancelStartedBatchRequest {
    [self testXIDIDeviceInfoListRestCallStartBatchRequest];
    
    [[self.mockRestCall expect] cancel];
    [self.call cancel];
    [self.mockRestCall verify];
}

- (void)testXIDIDeviceInfoListRestCallBatchPositiveResponse {
    [self testXIDIDeviceInfoListRestCallStartBatchRequest];
    NSArray *array = @[
                       @{
                           @"devices": @{
                                   @"results": @[
                                           @{
                                               @"id": @"d310396b-8d21-4484-931c-693ff860984a",
                                               @"created": @"2015-04-01T12:55:18.000Z",
                                               @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"lastModified": @"2015-04-01T12:55:18.000Z",
                                               @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"version": @"7N",
                                               @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                               @"deviceTemplateId": @"df23460f-f590-4478-b958-c699a6c57c4f",
                                               @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
                                               @"serialNumber": @"veDnIwWJzjQ",
                                               @"provisioningState": @"defined",
                                               @"deviceVersion": [NSNull null],
                                               @"location": [NSNull null],
                                               @"name": [NSNull null],
                                               @"purchaseDate": [NSNull null],
                                               @"channels": @[
                                                       @{
                                                           @"channelTemplateId": @"ec062f13-b6b4-4b7a-8d82-3463c541ec24",
                                                           @"channelTemplateName": @"device-template",
                                                           @"persistenceType": @"simple",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/device-template"
                                                           },
                                                       @{
                                                           @"channelTemplateId": @"f1ff428c-39d3-43ae-8142-9eaf50687d8d",
                                                           @"channelTemplateName": @"device-log",
                                                           @"persistenceType": @"simple",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/device-log"
                                                           },
                                                       @{
                                                           @"channelTemplateId": @"f6e1132e-d567-41e7-94e5-892986be68fc",
                                                           @"channelTemplateName": @"control",
                                                           @"persistenceType": @"simple",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/control"
                                                           }
                                                       ]
                                               }
                                           ],
                                   @"meta": @{
                                           @"count": @(798),
                                           @"page": @(1),
                                           @"pageSize": @(1),
                                           @"sortOrder": @"asc"
                                           }
                                   }
                           },
                       @{
                           @"devices": @{
                                   @"results": @[
                                           @{
                                               @"id": @"09568054-5b66-4bc7-9b5b-7a189016ef53",
                                               @"created": @"2015-04-24T11:55:28.000Z",
                                               @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"lastModified": @"2015-04-24T11:55:28.000Z",
                                               @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"version": @"WV",
                                               @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                               @"deviceTemplateId": @"5516cc02-b27f-4ad2-9b8c-b1489b23aadc",
                                               @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
                                               @"serialNumber": @"2d7d3405-49b2-44e5-8f2b-eca0c32aebe0",
                                               @"provisioningState": @"defined",
                                               @"deviceVersion": [NSNull null],
                                               @"location": [NSNull null],
                                               @"name": [NSNull null],
                                               @"purchaseDate": [NSNull null],
                                               @"channels": @[
                                                       @{
                                                           @"channelTemplateId": @"607445df-aaf1-4bf0-9f00-5b2a4a1fac8c",
                                                           @"channelTemplateName": @"ad-hoc-topic-persistent",
                                                           @"persistenceType": @"timeSeries",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-persistent"
                                                           },
                                                       @{
                                                           @"channelTemplateId": @"ea45c846-5481-4b4e-a472-f72878a85e1c",
                                                           @"channelTemplateName": @"ad-hoc-topic-simple",
                                                           @"persistenceType": @"simple",
                                                           @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-simple"
                                                           }
                                                       ]
                                               }
                                           ],
                                   @"meta": @{
                                           @"count": @(798),
                                           @"page": @(2),
                                           @"pageSize": @(1),
                                           @"sortOrder": @"asc"
                                           }
                                   }
                           }
                       ];

    NSError *error = nil;
    NSData *d = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    
    [[self.mockDelegate expect] deviceInfoListCall:self.call didSucceedWithDeviceInfoList:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSArray *array = (NSArray *)obj;
        return array.count == 2;
        
    }] meta:[OCMArg checkWithBlock:^BOOL(id obj) {
        XIDIDeviceInfoListMeta *meta = (XIDIDeviceInfoListMeta *)obj;
        return meta != nil;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:d httpStatusCode:200];
    [self.mockDelegate verify];
}


- (void)testXIDIDeviceInfoListRestCallBatchChunkedPositiveResponse {
    NSArray *array = @[
                       @{
                           @"devices": @{
                               @"results": @[
                                           @{
                                               @"id": @"d310396b-8d21-4484-931c-693ff860984a",
                                               @"created": @"2015-04-01T12:55:18.000Z",
                                               @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"lastModified": @"2015-04-01T12:55:18.000Z",
                                               @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"version": @"7N",
                                               @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                               @"deviceTemplateId": @"df23460f-f590-4478-b958-c699a6c57c4f",
                                               @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
                                               @"serialNumber": @"veDnIwWJzjQ",
                                               @"provisioningState": @"defined",
                                               @"deviceVersion": [NSNull null],
                                               @"location": [NSNull null],
                                               @"name": [NSNull null],
                                               @"purchaseDate": [NSNull null],
                                               @"channels": @[
                                                            @{
                                                                @"channelTemplateId": @"ec062f13-b6b4-4b7a-8d82-3463c541ec24",
                                                                @"channelTemplateName": @"device-template",
                                                                @"persistenceType": @"simple",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/device-template"
                                                            },
                                                            @{
                                                                @"channelTemplateId": @"f1ff428c-39d3-43ae-8142-9eaf50687d8d",
                                                                @"channelTemplateName": @"device-log",
                                                                @"persistenceType": @"simple",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/device-log"
                                                            },
                                                            @{
                                                                @"channelTemplateId": @"f6e1132e-d567-41e7-94e5-892986be68fc",
                                                                @"channelTemplateName": @"control",
                                                                @"persistenceType": @"simple",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/d310396b-8d21-4484-931c-693ff860984a/control"
                                                            }
                                                            ]
                                           }
                                           ],
                               @"meta": @{
                                   @"count": @(798),
                                   @"page": @(1),
                                   @"pageSize": @(1),
                                   @"sortOrder": @"asc"
                               }
                           }
                       },
                       @{
                           @"devices": @{
                               @"results": @[
                                           @{
                                               @"id": @"09568054-5b66-4bc7-9b5b-7a189016ef53",
                                               @"created": @"2015-04-24T11:55:28.000Z",
                                               @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"lastModified": @"2015-04-24T11:55:28.000Z",
                                               @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                                               @"version": @"WV",
                                               @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                                               @"deviceTemplateId": @"5516cc02-b27f-4ad2-9b8c-b1489b23aadc",
                                               @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
                                               @"serialNumber": @"2d7d3405-49b2-44e5-8f2b-eca0c32aebe0",
                                               @"provisioningState": @"defined",
                                               @"deviceVersion": [NSNull null],
                                               @"location": [NSNull null],
                                               @"name": [NSNull null],
                                               @"purchaseDate": [NSNull null],
                                               @"channels": @[
                                                            @{
                                                                @"channelTemplateId": @"607445df-aaf1-4bf0-9f00-5b2a4a1fac8c",
                                                                @"channelTemplateName": @"ad-hoc-topic-persistent",
                                                                @"persistenceType": @"timeSeries",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-persistent"
                                                            },
                                                            @{
                                                                @"channelTemplateId": @"ea45c846-5481-4b4e-a472-f72878a85e1c",
                                                                @"channelTemplateName": @"ad-hoc-topic-simple",
                                                                @"persistenceType": @"simple",
                                                                @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-simple"
                                                            }
                                                            ]
                                           }
                                           ],
                               @"meta": @{
                                   @"count": @(798),
                                   @"page": @(2),
                                   @"pageSize": @(1),
                                   @"sortOrder": @"asc"
                               }
                           }
                       }
                       ];
    NSError *error = nil;
    NSData *d = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    d = [d subdataWithRange:NSMakeRange(0, 22)];
    
    [[self.mockDelegate expect] deviceInfoListCall:self.call didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error2 = (NSError *)obj;
        return error2.code == XIErrorInternal;
    }]];
    [self.call XIRESTCall:nil didFinishWithData:d httpStatusCode:200];
    [self.mockDelegate verify];
}

@end

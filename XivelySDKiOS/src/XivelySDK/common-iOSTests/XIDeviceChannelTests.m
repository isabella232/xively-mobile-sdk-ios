//
//  XIDeviceChannelTests.m
//  common-iOS
//
//  Created by vfabian on 25/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "XIDeviceChannel.h"
#import "XIDeviceChannel+InitWithDictionary.h"

@interface XIDeviceChannelTests : XCTestCase

@end

@implementation XIDeviceChannelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDeviceChannelCreationWithTimeSeriesChannel {
    NSString *channelId = @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/f59e7816-bf56-4cf6-825e-1fe3c1df6fec/ad-hoc-topic-persistent";
    NSDictionary *dict = @{
        @"channelTemplateId": @"607445df-aaf1-4bf0-9f00-5b2a4a1fac8c",
        @"channelTemplateName": @"ad-hoc-topic-persistent",
        @"persistenceType": @"timeSeries",
        @"channel": channelId
        };
    
    XIDeviceChannel *channel = [[XIDeviceChannel alloc] initWithDictionary:dict];
    
    XCTAssert(channel, @"Channel creation failed");
    XCTAssertEqual(channel.persistenceType, XIDeviceChannelPersistanceTypeTimeSeries, @"Invalid persistance type");
    XCTAssert([channel.channelId isEqualToString:channelId], @"channel id creation failed");
}

- (void)testDeviceChannelCreationWithSimpleChannel {
    NSString *channelId = @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/f59e7816-bf56-4cf6-825e-1fe3c1df6fec/ad-hoc-topic-persistent";
    NSDictionary *dict = @{
                           @"channelTemplateId": @"607445df-aaf1-4bf0-9f00-5b2a4a1fac8c",
                           @"channelTemplateName": @"ad-hoc-topic-persistent",
                           @"persistenceType": @"simple",
                           @"channel": channelId
                           };
    
    XIDeviceChannel *channel = [[XIDeviceChannel alloc] initWithDictionary:dict];
    
    XCTAssert(channel, @"Channel creation failed");
    XCTAssertEqual(channel.persistenceType, XIDeviceChannelPersistanceTypeSimple, @"Invalid persistance type");
    XCTAssert([channel.channelId isEqualToString:channelId], @"channel id creation failed");
}

- (void)testDeviceChannelEmptyCreation {
    NSDictionary *dict = @{
                           @"channelTemplateId": @"607445df-aaf1-4bf0-9f00-5b2a4a1fac8c",
                           @"channelTemplateName": @"ad-hoc-topic-persistent",
                           @"persistenceType": [NSNull null],
                           @"channel": [NSNull null]
                           };
    
    XIDeviceChannel *channel = [[XIDeviceChannel alloc] initWithDictionary:dict];
    
    XCTAssert(channel, @"Channel creation failed");
    XCTAssertEqual(channel.persistenceType, XIDeviceChannelPersistanceTypeSimple, @"Invalid persistance type");
    XCTAssertNil(channel.channelId, @"channel id filling failed");
}

@end

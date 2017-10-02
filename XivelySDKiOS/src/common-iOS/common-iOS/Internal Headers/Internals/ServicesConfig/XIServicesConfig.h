//
//  XIServicesConfig.h
//  common-iOS
//
//  Created by gszajko on 02/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XISdkConfig;

@interface XIServicesConfig : NSObject
@property (strong, nonatomic) XISdkConfig* sdkConfig;

@property (strong, nonatomic, readonly) NSString* loginServiceUrl;
@property (strong, nonatomic, readonly) NSString* oauthServiceUrl;
@property (strong, nonatomic, readonly) NSString* deviceAssociationServiceUrl;
@property (strong, nonatomic, readonly) NSString* mqttBrokerUrl;
@property (strong, nonatomic, readonly) NSString* blueprintEndUsersServiceUrl;
@property (strong, nonatomic, readonly) NSString* blueprintEndUsersEndpointPath;
@property (strong, nonatomic, readonly) NSString* blueprintAccountUsersServiceUrl;
@property (strong, nonatomic, readonly) NSString* blueprintAccountUsersEndpointPath;
@property (strong, nonatomic, readonly) NSString* blueprintDevicesServiceUrl;
@property (strong, nonatomic, readonly) NSString* blueprintOrganizationsServiceUrl;
@property (strong, nonatomic, readonly) NSString* blueprintBatchServiceUrl;
@property (strong, nonatomic, readonly) NSString* createMqttCredentialsServiceUrl;
@property (strong, nonatomic, readonly) NSString* timeSeriesServiceUrl;
@property (nonatomic, readonly) NSUInteger blueprintListingMaxPageSize;
@property (nonatomic, readonly) NSUInteger blueprintAggregateMaxCallCount;
@property (nonatomic, readonly) NSUInteger timeseriesPageSize;

-(instancetype) initWithSdkConfig: (XISdkConfig*) config;
-(NSURL*) composeOAuthRequestUrlWithProviderId: (NSString*) providerId accountId: (NSString*) accountId;

@end

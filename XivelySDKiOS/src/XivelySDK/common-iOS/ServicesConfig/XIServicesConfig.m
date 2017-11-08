//
//  XIServicesConfig.m
//  common-iOS
//
//  Created by gszajko on 02/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIServicesConfig.h"
#import "XISdkConfig+Selector.h"
#import "NSString+XIURLEncode.h"

@implementation XIServicesConfig
-(instancetype) initWithSdkConfig: (XISdkConfig*) config {
    if ((self = [super init])) {
        _sdkConfig = config;
        _loginServiceUrl = @"https://id.xively.com/api/v1/auth/login-user";
        _oauthServiceUrl = @"https://access.xively.com/api/authentication/oauth/authenticate";
        _deviceAssociationServiceUrl = @"https://blueprint.xively.com/api/v1/association/start-association-with-code";
        _mqttBrokerUrl = @"ssl://broker.xively.com:8883";
        _blueprintEndUsersServiceUrl = @"https://blueprint.xively.com/api/v1/end-users";
        _blueprintEndUsersEndpointPath = @"/api/v1/end-users";
        _blueprintAccountUsersServiceUrl = @"https://blueprint.xively.com/api/v1/account-users";
        _blueprintAccountUsersEndpointPath = @"/api/v1/account-users";
        _createMqttCredentialsServiceUrl = @"https://blueprint.xively.com/api/v1/access/mqtt-credentials";
        _blueprintDevicesServiceUrl = @"https://blueprint.xively.com/api/v1/devices";
        _blueprintOrganizationsServiceUrl = @"https://blueprint.xively.com/api/v1/organizations";
        _blueprintBatchServiceUrl = @"https://blueprint.xively.com/api/v1/batch";
        _timeSeriesServiceUrl = @"https://timeseries.xively.com:443/api/v4/data";
        _blueprintListingMaxPageSize = 1000;
        _blueprintAggregateMaxCallCount = 30;
        _timeseriesPageSize = 1000;
    }
    return self;
}

-(NSURL*) composeOAuthRequestUrlWithProviderId: (NSString*) providerId accountId: (NSString*) accountId {
    // TODO: keresni egy jobb url encode -ot
    return [NSURL URLWithString: [NSString stringWithFormat: @"%@?redirect_uri=xi%@&provider_id=%@",
                                  _oauthServiceUrl,
                                  [accountId xiUrlEncode],
                                  [providerId xiUrlEncode]]];
}

@end

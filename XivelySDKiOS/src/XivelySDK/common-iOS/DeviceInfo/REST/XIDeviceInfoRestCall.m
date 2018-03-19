//
//  XIDeviceInfoRestCall.m
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import "XIDeviceInfoRestCall.h"
#import <XivelySDK/XIEnvironment.h>
#import <XivelySDK/XISdkConfig+Selector.h>
#import "XIDIDeviceInfoListMeta.h"
#import "XIDeviceInfo.h"
#import "XIDeviceInfo+InitWithDictionary.h"
#import <XivelySDK/XICommonError.h>
#import "NSString+XIURLEncode.h"

@interface XIDeviceInfoRestCall ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end

@implementation XIDeviceInfoRestCall

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

- (void)getRequestWithAccountId:(NSString *)accountId
                       deviceId:(NSString *)deviceId {
    [_log info: @"Device Info Get Call Requested"];
    NSData *restCallBody = [self restCallBodyWithDeviceInfo:nil];
    NSString *restCallUrl = [self restCallUrlWithDeviceId:(NSString *)deviceId];
    NSDictionary *restCallHeaders = [self restCallHeadersWithDeviceInfo:nil];
    
    [self.call cancel];
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodGET
                    headers: restCallHeaders
                       body: restCallBody];
}

- (void)putRequestWithDeviceInfo:(XIDeviceInfo *)deviceInfo {
    [_log info: @"Device Info Put Call Requested"];
    NSData *restCallBody = [self restCallBodyWithDeviceInfo:deviceInfo];
    NSString *restCallUrl = [self restCallUrlWithDeviceId:[deviceInfo deviceId]];
    NSDictionary *restCallHeaders = [self restCallHeadersWithDeviceInfo:deviceInfo];
    
    [self.call cancel];
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodPUT
                    headers: restCallHeaders
                       body: restCallBody];
}

- (NSDictionary *)restCallHeadersWithDeviceInfo:(XIDeviceInfo* )deviceInfo {
    if (!deviceInfo) {
        return nil;
    }
    return @{@"etag": deviceInfo.version};
}

- (NSString *)restCallUrlWithDeviceId:(NSString *)deviceId {
    //iOS 8 check
#pragma warning Remove if the minimum OS is set to iOS 8
    if (NSClassFromString(@"NSURLQueryItem")) {
        NSURLComponents *components = [NSURLComponents componentsWithString:self.servicesConfig.blueprintDevicesServiceUrl];
        components.path = [NSString stringWithFormat:@"%@/%@", components.path, [deviceId xiUrlEncode]];
        NSURL *url = components.URL;
        return [url absoluteString];
    } else {
        return [NSString stringWithFormat:@"%@/%@",
                self.servicesConfig.blueprintDevicesServiceUrl,
                [deviceId xiUrlEncode]];
    }
}

- (NSData *)restCallBodyWithDeviceInfo:(XIDeviceInfo* )deviceInfo {
    if (!deviceInfo)
        return nil;
    NSError* err = nil;
    return [NSJSONSerialization dataWithJSONObject:[deviceInfo dictionary] options:0 error:&err];
}

- (void)cancel {
    [_log info: @"Device Info List Call Canceled"];
    [self.call cancel];
}

#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode {
    [_log info: @"Device Info List Call Returned"];
    [self processRestCallResultWithHttpStatusCode:httpStatusCode data:data];
}

- (void)processRestCallResultWithHttpStatusCode:(NSInteger)httpStatusCode data:(NSData *)data {
    if (httpStatusCode == 200) {
        [self processPositiveData:data];
    } else {
        NSLog(@"Error message: %@", [NSString stringWithUTF8String:[data bytes]]);
        [self processErrorStatus:httpStatusCode];
    }
}

- (void)processPositiveData:(NSData *)data {
    [_log info: @"Device Info List Call Success"];
    
    NSError *parseError = nil;
    NSObject *parsedDictionary = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError] : nil;
    
    if (parseError || !parsedDictionary ) {
        NSError *error = [NSError errorWithDomain:@"Device Info" code:XIErrorInternal userInfo:nil];
        [self.delegate deviceInfoCall:self didFailWithError:error];
        return;
        
    } else {
        [self processCallResult:parsedDictionary ];
    }
}

- (void)processCallResult:(NSObject *)result {
    NSDictionary *devicesDict = ((NSDictionary*)result)[@"device"];
    if (devicesDict) {
        XIDeviceInfo *deviceInfo = [[XIDeviceInfo alloc] initWithDictionary:devicesDict];
        [self.delegate deviceInfoCall:self
             didSucceedWithDeviceInfo:deviceInfo];
    } else {
        NSError *error = [NSError errorWithDomain:@"Device Info" code:XIErrorInternal userInfo:nil];
        [self.delegate deviceInfoCall:self didFailWithError:error];
    }
}

- (void)processErrorStatus:(NSInteger)httpStatusCode {
    [_log info: @"Device Info List Call Failed with code %d", httpStatusCode];
    NSInteger errorCode = XIErrorUnknown;
    switch (httpStatusCode) {
        case 401:
            errorCode = XIErrorUnauthorized;
            break;
            
        case 400:
            errorCode = XIErrorInternal;
            break;
            
        default:
            break;
    }
    NSError *error = [NSError errorWithDomain:@"Device Info List" code:errorCode userInfo:nil];
    [self.delegate deviceInfoCall:self didFailWithError:error];
}


- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    [_log info: @"Device Info List Call Error"];
    [self.delegate deviceInfoCall:self didFailWithError:error];
}

@end

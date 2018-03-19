//
//  XIDIDeviceInfoRestCall.m
//  common-iOS
//
//  Created by vfabian on 24/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIDIDeviceInfoListRestCall.h"
#import <XivelySDK/XIEnvironment.h>
#import <XivelySDK/XISdkConfig+Selector.h>
#import "XIDIDeviceInfoListMeta.h"
#import "XIDeviceInfo.h"
#import "XIDeviceInfo+InitWithDictionary.h"
#import <XivelySDK/XICommonError.h>
#import "NSString+XIURLEncode.h"

typedef NS_ENUM(NSUInteger, XIDIDeviceInfoListRestCallMode) {
    XIDIDeviceInfoListRestCallModeSingleCall,
    XIDIDeviceInfoListRestCallModeBatchCall,
};

@interface XIDIDeviceInfoListRestCall ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;
@property(assign, nonatomic) XIDIDeviceInfoListRestCallMode mode;

@end

@implementation XIDIDeviceInfoListRestCall

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

- (void)requestWithAccountId:(NSString *)accountId
              organizationId:(NSString *)organizationId
                    pageSize:(NSUInteger)pageSize
                        page:(NSUInteger)page {
    [_log info: @"Device Info List Call Requested"];
    NSData *restCallBody = [self restCallBody];
    NSString *restCallUrl = [self restCallUrlWithAccountId:(NSString *)accountId
                                            organizationId:(NSString *)organizationId
                                                  pageSize:(NSInteger)pageSize
                                                      page:(NSInteger)page];
    self.mode = XIDIDeviceInfoListRestCallModeSingleCall;
    NSDictionary *restCallHeaders = [self restCallHeaders];
    
    [self.call cancel];
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodGET
                    headers: restCallHeaders
                       body: restCallBody];
}

- (void)requestWithAccountId:(NSString *)accountId
              organizationId:(NSString *)organizationId
                    pageSize:(NSUInteger)pageSize
                   pagesFrom:(NSUInteger)pagesFrom
                     pagesTo:(NSUInteger)pagesTo {
    assert(pagesFrom <= pagesTo);
    [_log info: @"Device Info List Aggregated Call Requested"];
    NSData *restCallBody = [self batchRestCallBodyWithAccountId:accountId
                                                 organizationId:organizationId
                                                       pageSize:pageSize
                                                      pagesFrom:pagesFrom
                                                        pagesTo:pagesTo];
    NSString *restCallUrl = [self batchRestCallUrl];
    self.mode = XIDIDeviceInfoListRestCallModeBatchCall;
    NSDictionary *restCallHeaders = [self restCallHeaders];
    
    [self.call cancel];
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodPOST
                    headers: restCallHeaders
                       body: restCallBody];
}


- (NSDictionary *)restCallHeaders {
    return nil;
}

- (NSString *)restCallUrlWithAccountId:(NSString *)accountId
                        organizationId:(NSString *)organizationId
                              pageSize:(NSUInteger)pageSize
                                  page:(NSUInteger)page {
    //iOS 8 check
#pragma warning Remove if the minimum OS is set to iOS 8
    if (NSClassFromString(@"NSURLQueryItem")) {
        NSURLComponents *components = [NSURLComponents componentsWithString:self.servicesConfig.blueprintDevicesServiceUrl];
        NSURLQueryItem *accountIdQI = [NSURLQueryItem queryItemWithName:@"accountId" value:accountId];
        NSURLQueryItem *pageSizeQI = [NSURLQueryItem queryItemWithName:@"pageSize" value:[NSString stringWithFormat:@"%ld", (long)pageSize]];
        NSURLQueryItem *pageQI = [NSURLQueryItem queryItemWithName:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
        NSURLQueryItem *metaQI = [NSURLQueryItem queryItemWithName:@"meta" value:@"true"];
        NSURLQueryItem *resultsQI = [NSURLQueryItem queryItemWithName:@"results" value:@"true"];
        
        components.queryItems = @[ accountIdQI, pageSizeQI, pageQI, metaQI, resultsQI];
        NSURL *url = components.URL;
        return [url absoluteString];
    } else {
        return [NSString stringWithFormat:@"%@?accountId=%@&pageSize=%@&page=%@&meta=true&results=true",
                self.servicesConfig.blueprintDevicesServiceUrl,
                [accountId xiUrlEncode],
                //[organizationId xiUrlEncode],
                [NSString stringWithFormat:@"%ld", (long)pageSize],
                [NSString stringWithFormat:@"%ld", (long)page]
                ];
    }
}

- (NSString *)batchRestCallUrl {
    return self.servicesConfig.blueprintBatchServiceUrl;
}

- (NSData *)restCallBody {
    return nil;
}

- (NSData *)batchRestCallBodyWithAccountId:(NSString *)accountId
                            organizationId:(NSString *)organizationId
                                  pageSize:(NSUInteger)pageSize
                                 pagesFrom:(NSUInteger)pagesFrom
                                   pagesTo:(NSUInteger)pagesTo {
    NSMutableArray *pages = [NSMutableArray new];
    for (NSUInteger i = pagesFrom; i <= pagesTo ;i++) {
        NSString *path = [self restCallUrlWithAccountId:accountId
                                         organizationId:organizationId
                                               pageSize:pageSize
                                                   page:i];
        
        [pages addObject:@{
                           @"method" : @"get",
                           @"path" : path
                           }];
    }
    
    NSDictionary *requestsDictionary = @{@"requests" : pages};
    
    NSError *parseError = nil;
    NSData* json = [NSJSONSerialization dataWithJSONObject:requestsDictionary options:0 error:&parseError];
    assert(!parseError);
    return json;
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
        [self processErrorStatus:httpStatusCode];
    }
}

- (void)processPositiveData:(NSData *)data {
    [_log info: @"Device Info List Call Success"];
    
    NSError *parseError = nil;
    NSObject *parsedDictionary = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError] : nil;
    
    if (parseError || !parsedDictionary ) {
        NSError *error = [NSError errorWithDomain:@"Device Info List" code:XIErrorInternal userInfo:nil];
        [self.delegate deviceInfoListCall:self didFailWithError:error];
        return;
        
    } else {
        switch (self.mode) {
            case XIDIDeviceInfoListRestCallModeSingleCall:
                [self processBatchCallResultFromResults:@[parsedDictionary] ];
                break;
                
            case XIDIDeviceInfoListRestCallModeBatchCall:
                [self processBatchCallResultFromResults:(NSArray *)parsedDictionary];
                break;
                
            default:
                break;
        }
    }
}

- (void)processBatchCallResultFromResults:(NSArray *)results {
    NSMutableArray *mutableDeviceInfos = [NSMutableArray new];
    XIDIDeviceInfoListMeta *meta = nil;
    
    for (NSDictionary *singleResult in results) {
        NSDictionary *devicesDict = singleResult[@"devices"];
        meta = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:devicesDict[@"meta"]];
        NSArray *results = devicesDict[@"results"];
        
        for (NSDictionary *deviceInfoDict in results) {
            XIDeviceInfo *deviceInfo = [[XIDeviceInfo alloc] initWithDictionary:deviceInfoDict];
            [mutableDeviceInfos addObject:deviceInfo];
        }
    }
    
    [self.delegate deviceInfoListCall:self
         didSucceedWithDeviceInfoList:[mutableDeviceInfos copy]
                                 meta:meta];
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
    [self.delegate deviceInfoListCall:self didFailWithError:error];
}


- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    [_log info: @"Device Info List Call Error"];
    [self.delegate deviceInfoListCall:self didFailWithError:error];
}

@end

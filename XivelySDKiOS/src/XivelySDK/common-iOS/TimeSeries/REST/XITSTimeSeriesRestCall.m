//
//  XITSTimeSeriesRestCall.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XITSTimeSeriesRestCall.h"
#import <XivelySDK/XIEnvironment.h>
#import <XivelySDK/XISdkConfig+Selector.h>
#import "XITSTimeSeriesMeta.h"
#import "XITimeSeriesItem+Initializers.h"
#import <XivelySDK/TimeSeries/XITimeSeriesItem.h>
#import <XivelySDK/XICommonError.h>
#import "NSDateFormatter+XITimeSeries.h"
#import "NSString+XISecureTopicName.h"
#import "NSString+XIURLEncode.h"

@interface XITSTimeSeriesRestCall ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end


@implementation XITSTimeSeriesRestCall

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

- (void)requestWithTopic:(NSString *)topic
               startDate:(NSDate *)startDate
                 endDate:(NSDate *)endDate
                pageSize:(NSInteger)pageSize
             pagingToken:(NSString *)pagingToken {
    [_log info: @"Time series Call Requested"];
    
    NSString *restCallUrl = [self restCallUrlWithTopic:topic
                                             startDate:startDate
                                               endDate:endDate
                                              pageSize:(NSInteger)pageSize
                                           pagingToken:(NSString *)pagingToken];
    [self.call cancel];
    self.call = [_restCallProvider getEmptyRESTCall];
    self.call.delegate = self;
    [self.call startWithURL: restCallUrl
                     method: XIRESTCallMethodGET
                    headers: nil
                       body: nil];
}

- (NSString *)restCallUrlWithTopic:(NSString *)topic
                         startDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate
                          pageSize:(NSInteger)pageSize
                       pagingToken:(NSString *)pagingToken {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.servicesConfig.timeSeriesServiceUrl, [topic xiconvertTopicNameForUrl]];
    NSDateFormatter *dateFormatter = [NSDateFormatter timeSeriesDateFormatter];
#pragma warning Remove if the minimum OS is set to iOS 8
    if (NSClassFromString(@"NSURLQueryItem")) {

        NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
        NSURLQueryItem *startDateQI = [NSURLQueryItem queryItemWithName:@"startDateTime" value:[dateFormatter stringFromDate:startDate]];
        NSURLQueryItem *endDateQI = [NSURLQueryItem queryItemWithName:@"endDateTime" value:[dateFormatter stringFromDate:endDate]];
        NSURLQueryItem *pageSizeQI = [NSURLQueryItem queryItemWithName:@"pageSize" value:[NSString stringWithFormat:@"%ld", pageSize ? (long)pageSize : 1000]];
        
        if (pagingToken) {
            NSURLQueryItem *pagingTokenQI = [NSURLQueryItem queryItemWithName:@"pagingToken" value:[pagingToken xiUrlEncode]];
            components.queryItems = @[ startDateQI, endDateQI, pageSizeQI, pagingTokenQI];
        } else {
            components.queryItems = @[ startDateQI, endDateQI, pageSizeQI];
        }
        NSURL *url = components.URL;
        return [url absoluteString];
    } else {
        return [NSString stringWithFormat:@"%@?startDateTime=%@&endDateTime=%@&pageSize=%@%@",
                urlString,
                [dateFormatter stringFromDate:startDate],
                [dateFormatter stringFromDate:endDate],
                [NSString stringWithFormat:@"%ld", pageSize ? (long)pageSize : 1000],
                pagingToken ? [NSString stringWithFormat:@"&pagingToken=%@", [pagingToken xiUrlEncode]]: @""
                ];
    }
    return nil;
}

- (void)cancel {
    [_log info: @"Time series Call Canceled"];
    [self.call cancel];
}

#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode {
    [_log info: @"Time series Call Returned"];
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
    [_log info: @"Time series List Call Success"];
    
    NSError *parseError = nil;
    NSObject *parsedDictionary = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError] : nil;
    
    if (parseError || !parsedDictionary ) {
        NSError *error = [NSError errorWithDomain:@"Time Series Call" code:XIErrorInternal userInfo:nil];
        [self.delegate timeSeriesCall:self didFailWithError:error];
        return;
    }
    
    NSDictionary *responseDict = (NSDictionary *)parsedDictionary;
    NSDictionary *metaDict = responseDict[@"meta"];
    XITSTimeSeriesMeta *meta = [[XITSTimeSeriesMeta alloc] initWithDictionary:metaDict];
    
    NSArray *resultsArray = responseDict[@"result"];
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in resultsArray) {
        [items addObject:[[XITimeSeriesItem alloc] initWithDictionary:dict]];
    }
    
    [self.delegate timeSeriesCall:self didSucceedWithTimeSeriesItems:items meta:meta];
}

- (void)processErrorStatus:(NSInteger)httpStatusCode {
    [_log info: @"Time series Call Failed with code %d", httpStatusCode];
    
    if (httpStatusCode == 404) {
        //yep, it has positive meaning
        [self.delegate timeSeriesCall:self didSucceedWithTimeSeriesItems:@[] meta:nil];
        return;
    }
    
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
    NSError *error = [NSError errorWithDomain:@"Time Series Call" code:errorCode userInfo:nil];
    [self.delegate timeSeriesCall:self didFailWithError:error];
}


- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    [_log info: @"Time series Call Error"];
    [self.delegate timeSeriesCall:self didFailWithError:error];
}

@end
